using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using JsonSerializer = System.Text.Json.JsonSerializer;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class SpeciesTypePageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _speciesTypePageViewModel;
        private readonly ISpeciesTypeClient _speciesTypeClient;
        private readonly IStringLocalizer _localizer;

        public class RootObject
        {
            public List<AddSpeciesTypeModel> response { get; set; }
        }

        public class AddSpeciesTypeModel
        {
            [JsonProperty("Default")]
            public string Default { get; set; }
            [JsonProperty("Name")]
            public string Name { get; set; }
            [JsonProperty("strCode")]
            public string strCode { get; set; }
            [JsonProperty("intOrder")]
            public int intOrder { get; set; }
        }

        public SpeciesTypePageController(ISpeciesTypeClient speciesTypeClient, ITokenService tokenService, IStringLocalizer localizer, ILogger<SpeciesTypePageController> logger) : base(logger, tokenService)
        {
            _speciesTypePageViewModel = new BaseReferenceEditorPagesViewModel
            {
                Select2Configurations = new List<Select2Configruation>()
            };
            _speciesTypeClient = speciesTypeClient;
            _localizer = localizer;
            _speciesTypePageViewModel.UserPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
        }

        public IActionResult Index()
        {
            _speciesTypePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _speciesTypePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_speciesTypePageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var iPage = dataTableQueryPostObj.page;
            var iLength = dataTableQueryPostObj.length;

            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            if (valuePair.Key == "SpeciesTypeId")
            {
                valuePair = new KeyValuePair<string, string>();
            }

            var request = new SpeciesTypeGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AdvancedSearch = JObject.Parse(dataTableQueryPostObj.postArgs)["SearchBox"]?.ToString(),
                Page = iPage,
                PageSize = iLength,
                SortColumn = !string.IsNullOrEmpty(valuePair.Key) ? valuePair.Key : "intOrder",
                SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
            };

            var response = await _speciesTypeClient.GetSpeciesTypeList(request);
            IEnumerable<BaseReferenceEditorsViewModel> speciesTypeList = response;

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                iTotalDisplayRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (response.Count <= 0) return Json(tableData);
            for (var i = 0; i < response.Count(); i++)
            {
                var cols = new List<string>()
                {
                    ((i + 1) + ((iPage - 1) * iLength)).ToString(),
                    speciesTypeList.ElementAt(i).KeyId.ToString(),
                    speciesTypeList.ElementAt(i).StrDefault,
                    speciesTypeList.ElementAt(i).StrName,
                    (speciesTypeList.ElementAt(i).StrCode == null) ? string.Empty : speciesTypeList.ElementAt(i).StrCode,
                    (speciesTypeList.ElementAt(i).StrHACode == null) ? string.Empty : speciesTypeList.ElementAt(i).StrHACode,
                    (speciesTypeList.ElementAt(i).StrHACodeNames == null) ? string.Empty : speciesTypeList.ElementAt(i).StrHACodeNames,
                    speciesTypeList.ElementAt(i).IntOrder.ToString()
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> SaveSpeciesType([FromForm] SpeciesTypeSaveRequestModel request)
        {
            var response = await _speciesTypeClient.SaveSpeciesType(request);

            var strDuplicationMessage = string.Empty;

            if (response.ReturnMessage == "DOES EXIST")
            {
                strDuplicationMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            }

            var data = new
            {
                DuplicationMessage = strDuplicationMessage,
                response.ReturnMessage,
                response.ReturnCode
            };

            return Json(data);
        }

        [HttpPost]
        public async Task<JsonResult> DeleteSpeciesType([FromBody] JsonElement data)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["SpeciesTypeId"] != null)
                {
                    var request = new SpeciesTypeSaveRequestModel
                    {
                        DeleteAnyway = true,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        SpeciesTypeId = long.Parse(jsonObject["SpeciesTypeId"].ToString())
                    };

                    var response = await _speciesTypeClient.DeleteSpeciesType(request);
                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["SpeciesTypeId"].ToString());
                    if (response.ReturnMessage == "IN USE")
                    {
                        responsePost.strClientPageMessage =
                            "You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?";
                    }

                    return Json(responsePost);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(responsePost);
        }

        [HttpPost]
        public async Task<IActionResult> AddEditSpeciesType([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var serializer = JsonSerializer.Serialize(data);

            var request = new SpeciesTypeSaveRequestModel
            {
                intHACode = Common.GetHAcodeTotal(jsonObject, "strHACodeNames", _speciesTypeClient),
                Default = jsonObject["strDefault"]?.ToString(),
                Name = jsonObject["strName"]?.ToString(),
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            if (jsonObject["intOrder"] != null)
            {
                if (!string.IsNullOrEmpty(jsonObject["intOrder"].ToString()))
                {
                    request.intOrder = int.Parse(jsonObject["intOrder"].ToString());
                }
                else
                {
                    request.intOrder = 0;
                }
            }

            request.strCode = jsonObject["strCode"]?.ToString();
            request.SpeciesTypeId = (jsonObject["SpeciesTypeId"] == null) ? null : long.Parse(jsonObject["SpeciesTypeId"].ToString());

            return Json(await SaveSpeciesType(request));
        }
    }
}
