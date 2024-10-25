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
    public class MeasuresPageController : BaseController
    {
        readonly BaseReferenceEditorPagesViewModel _pageViewModel;
        private readonly IMeasuresClient _measuresClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;

        public MeasuresPageController(
            IMeasuresClient measuresClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<MeasuresPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _measuresClient = measuresClient;
            _localizer = localizer;
            _userPermissions = GetUserPermissions(PagePermission.CanManageBaseReferencePage);
            _pageViewModel.UserPermissions = _userPermissions;
        }

        public IActionResult Index()
        {
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { ddlMeasureType = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? measureTypeId = null;
            if (referenceType.ddlMeasureType != null)
            {
                if (!string.IsNullOrEmpty(referenceType.ddlMeasureType))
                {
                    measureTypeId = long.Parse(referenceType.ddlMeasureType);
                }
            }

            //Sorting
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            var strSortColumn = "intOrder";
            if (!string.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "MeasureId")
            {
                strSortColumn = valuePair.Key;
            }

            var request = new MeasuresGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AdvancedSearch = string.IsNullOrEmpty(referenceType.SearchBox) ? null : referenceType.SearchBox,
                IdfsActionList = measureTypeId,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = strSortColumn,
                SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
            };

            var response = await _measuresClient.GetMeasuresList(request);
            IEnumerable<BaseReferenceEditorsViewModel> measuresList = response;

            measuresList = strSortColumn switch
            {
                "intOrder" when request.SortOrder == EIDSSConstants.SortConstants.Descending => measuresList
                    .OrderByDescending(o => o.IntOrder)
                    .ThenBy(n => n.StrName),
                "intOrder" when request.SortOrder == EIDSSConstants.SortConstants.Ascending => measuresList.OrderBy(o => o.IntOrder)
                    .ThenBy(n => n.StrName),
                _ => measuresList
            };

            TableData tableData = new()
            {
                data = new List<List<string>>(),
                iTotalRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                iTotalDisplayRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < response.Count(); i++)
            {
                List<string> cols = new()
                {
                    (row + i + 1).ToString(),
                    measuresList.ElementAt(i).KeyId.ToString(),
                    measureTypeId.ToString(),
                    measuresList.ElementAt(i).StrDefault ?? string.Empty, // English Value
                    measuresList.ElementAt(i).StrName ?? string.Empty,  // Translated Value                  
                    measuresList.ElementAt(i).StrActionCode ?? string.Empty,
                    measuresList.ElementAt(i).IntOrder.ToString()
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        [HttpPost]
        [Route("AddMeasure")]
        public async Task<IActionResult> AddMeasure([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            MeasuresSaveRequestModel request = new()
            {
                Default = jsonObject["Default"]?.ToString().Trim(),
                Name = jsonObject["Name"]?.ToString().Trim(),
                StrActionCode = jsonObject["Code"]?.ToString(),
                intOrder = !string.IsNullOrEmpty(jsonObject["Order"]?.ToString()) ? int.Parse(jsonObject["Order"].ToString()) : 0,
                IdfsReferenceType = long.Parse(jsonObject["ddlMeasureType"]?[0]?["id"]?.ToString() ?? string.Empty),
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            var response = await _measuresClient.SaveMeasure(request);
            response.StrDuplicatedField = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
            return Json(response);
        }

        [HttpPost]
        public async Task<JsonResult> EditMeasure([FromBody] JsonElement json)
        {
            try
            {
                var jsonObject = JObject.Parse(json.ToString() ?? string.Empty);

                MeasuresSaveRequestModel request = new()
                {
                    Default = jsonObject["StrDefault"]?.ToString().Trim(),
                    Name = jsonObject["StrName"]?.ToString().Trim(),
                    StrActionCode = jsonObject["StrCode"]?.ToString(),
                    intOrder = !string.IsNullOrEmpty(jsonObject["IntOrder"]?.ToString())
                        ? int.Parse(jsonObject["IntOrder"].ToString())
                        : 0,
                    IdfsBaseReference = Convert.ToInt64(jsonObject["MeasureId"]),
                    IdfsReferenceType = long.Parse(jsonObject["ReferenceTypeId"]?.ToString() ?? string.Empty),
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                var response = await _measuresClient.SaveMeasure(request);
                response.StrDuplicatedField =
                    string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("DeleteMeasure")]
        public async Task<JsonResult> DeleteMeasure([FromBody] JsonElement json)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(json.ToString() ?? string.Empty);
                if (jsonObject["ReferenceTypeId"] != null)
                {
                    var request = new MeasuresSaveRequestModel
                    {
                        IdfsAction = long.Parse(jsonObject["MeasureId"]?.ToString() ?? string.Empty),
                        IdfsMeasureList = Convert.ToInt64(jsonObject["ReferenceTypeId"]?.ToString()),
                        DeleteAnyway = true,
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                    };

                    var response = await _measuresClient.DeleteMeasure(request);

                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["ReferenceTypeId"]?.ToString() ?? string.Empty);

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
                _logger.LogError(ex.Message);
                throw;
            }

            return Json("");
        }

        public async Task<JsonResult> MeasuresTypeList(int page, string data, string term)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            try
            {
                var list = await _measuresClient.GetMeasuresDropDownList(GetCurrentLanguage());

                if (!string.IsNullOrEmpty(term))
                {
                    List<BaseReferenceEditorsViewModel> toList = list.Where(c => c.StrReferenceTypeName != null && c.StrReferenceTypeName.Contains(term, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    list = toList;
                }

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.IdfsReferenceType.ToString(), text = item.StrReferenceTypeName }));
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return Json(select2DataObj);
        }
    }
}
