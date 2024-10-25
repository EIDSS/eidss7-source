using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class VectorSpeciesTypePageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _vectorSpeciesTypePageViewModel;
        private readonly IVectorSpeciesTypeClient _vectorSpeciesTypeClient;
        private readonly IVectorTypeClient _vectorTypeClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;

        public VectorSpeciesTypePageController(IVectorSpeciesTypeClient vectorSpeciesTypeClient, IVectorTypeClient vectorTypeClient, IStringLocalizer localizer,
            ILogger<VectorSpeciesTypePageController> logger, ITokenService tokenService)
            : base(logger, tokenService)
        {
            _vectorSpeciesTypePageViewModel = new BaseReferenceEditorPagesViewModel();
            _vectorSpeciesTypeClient = vectorSpeciesTypeClient;
            _vectorTypeClient = vectorTypeClient;
            _userPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables);
            _vectorSpeciesTypePageViewModel.UserPermissions = _userPermissions;
            _localizer = localizer;
        }

        public IActionResult Index()
        {
            _vectorSpeciesTypePageViewModel.Select2Configurations = new List<Select2Configruation>();
            _vectorSpeciesTypePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _vectorSpeciesTypePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_vectorSpeciesTypePageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { ReferenceTypeDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? vectorTypeId = null;
            if (referenceType.ReferenceTypeDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.ReferenceTypeDD))
                {
                    vectorTypeId = long.Parse(referenceType.ReferenceTypeDD);
                }
            }

            var list = new List<BaseReferenceEditorsViewModel>();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "intOrder";
                if (!string.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "KeyId")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new VectorSpeciesTypesGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfsVectorType = vectorTypeId,
                    AdvancedSearch = string.IsNullOrEmpty(referenceType.SearchBox) ? null : referenceType.SearchBox,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
                };

                list = await _vectorSpeciesTypeClient.GetVectorSpeciesTypeList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (list.Any())
            {
                var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (var i = 0; i < list.Count(); i++)
                {
                    var cols = new List<string>()
                    {
                        (row + i + 1).ToString(),
                        list.ElementAt(i).KeyId.ToString(),
                        list.ElementAt(i).IdfsVectorType.ToString(),
                        list.ElementAt(i).StrDefault,
                        list.ElementAt(i).StrName,
                        list.ElementAt(i).StrCode,
                        list.ElementAt(i).IntOrder.ToString(),
                        "",
                        ""
                    };

                    tableData.data.Add(cols);
                }
            }

            return Json(tableData);
        }

        [HttpPost]
        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            APISaveResponseModel response;

            try
            {
                if (jsonObject["ReferenceTypeDD"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["ReferenceTypeDD"][0]?["id"]?.ToString()))
                    {
                        return Json("");
                    }
                }

                var strCode = string.Empty;
                if (jsonObject["StrCode"] != null)
                {
                    strCode = jsonObject["StrCode"].ToString();
                }

                var request = new VectorSpeciesTypesSaveRequestModel
                {
                    IdfsVectorSubType = null,
                    IdfsVectorType = jsonObject["ReferenceTypeDD"]?[0]?["id"] != null ? long.Parse(jsonObject["ReferenceTypeDD"]?[0]?["id"].ToString() ?? string.Empty) : null,
                    Default = jsonObject["StrDefault"]?.ToString(),
                    Name = jsonObject["StrName"]?.ToString(),
                    StrCode = strCode,
                    intOrder = !string.IsNullOrEmpty(jsonObject["IntOrder"]?.ToString()) ? int.Parse(jsonObject["IntOrder"].ToString()) : 0,
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                response = await _vectorSpeciesTypeClient.SaveVectorSpeciesType(request);
                switch (response.ReturnMessage)
                {
                    case "DOES EXIST":
                        response.StrDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                        break;
                    case "SUCCESS":
                        response.strClientPageMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(response);
        }

        [HttpPost]
        public async Task<JsonResult> Edit([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var response = new APISaveResponseModel();

            try
            {
                if (jsonObject["KeyId"] != null)
                {
                    var strCode = string.Empty;
                    if (jsonObject["StrCode"] != null)
                    {
                        strCode = jsonObject["StrCode"].ToString();
                    }

                    var request = new VectorSpeciesTypesSaveRequestModel
                    {
                        IdfsVectorSubType = long.Parse(jsonObject["KeyId"].ToString()),
                        IdfsVectorType = jsonObject["IdfsVectorType"] != null ? long.Parse(jsonObject["IdfsVectorType"].ToString()) : null,
                        Default = jsonObject["StrDefault"]?.ToString(),
                        Name = jsonObject["StrName"]?.ToString(),
                        StrCode = strCode,
                        intOrder = !string.IsNullOrEmpty(jsonObject["IntOrder"]?.ToString()) ? int.Parse(jsonObject["IntOrder"].ToString()) : 0,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                    };

                    response = await _vectorSpeciesTypeClient.SaveVectorSpeciesType(request);
                    switch (response.ReturnMessage)
                    {
                        case "DOES EXIST":
                            response.StrDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                            break;
                        case "SUCCESS":
                            response.strClientPageMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage);
                            break;
                    }

                    return Json(response);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(response);
        }

        [HttpPost]
        public async Task<JsonResult> Delete([FromBody] JsonElement data)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new VectorSpeciesTypesSaveRequestModel
                    {
                        DeleteAnyway = false,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        IdfsVectorSubType = Convert.ToInt64(jsonObject["KeyId"]?.ToString())
                    };
                    var response = await _vectorSpeciesTypeClient.DeleteVectorSpeciesType(request);

                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["KeyId"].ToString());
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
        public async Task<IActionResult> AddVectorType([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            var request = new VectorTypeSaveRequestModel
            {
                Default = jsonObject["Default"]?.ToString(),
                Name = jsonObject["Name"]?.ToString(),
                Code = jsonObject["Code"]?.ToString(),
                intOrder = !string.IsNullOrEmpty(jsonObject["Order"]?.ToString()) ? int.Parse(jsonObject["Order"].ToString()) : 0,
                CollectionByPool = false
            };

            if (jsonObject["CollectedByPool"].ToString().Contains("1"))
                request.CollectionByPool = true;
            request.LanguageId = GetCurrentLanguage();

            await _vectorTypeClient.SaveVectorType(request);
            return Json("");
        }
    }
}
