using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class CaseClassificationPageController : BaseController
    {
        private readonly ICaseClassificationClient _caseClassificationClient;
        private readonly IStringLocalizer _localizer;
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;

        public CaseClassificationPageController(ICaseClassificationClient caseClassificationClient,
            IStringLocalizer localizer, ILogger<CaseClassificationPageController> logger, ITokenService tokenService)
            : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _caseClassificationClient = caseClassificationClient;
            var userPermissions = GetUserPermissions(PagePermission.CanManageCaseClassificationPage);
            _pageViewModel.UserPermissions = userPermissions;
            _localizer = localizer;
        }

        public IActionResult Index()
        {
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();
            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var list = new List<BaseReferenceEditorsViewModel>();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "intOrder";
                if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "KeyId") strSortColumn = valuePair.Key;

                var request = new CaseClassificationGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    AdvancedSearch = null,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
                };

                list = await _caseClassificationClient.GetCaseClassificationList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (list.Count <= 0) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0
                ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length
                : 0;

            for (var i = 0; i < list.Count; i++)
            {
                var cols = new List<string>
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).KeyId.ToString(),
                    list.ElementAt(i).StrDefault,
                    list.ElementAt(i).StrName,
                    list.ElementAt(i).StrHACodeNames,
                    list.ElementAt(i).blnInitialHumanCaseClassification.ToString(),
                    list.ElementAt(i).blnFinalHumanCaseClassification.ToString(),
                    list.ElementAt(i).IntOrder.ToString(),
                    list.ElementAt(i).StrHACode != null ? list.ElementAt(i).StrHACode : Empty,
                    "",
                    ""
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        [HttpPost]
        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            var response = new APISaveResponseModel();

            try
            {
                var intHaCodeTotal = 0;
                if (jsonObject["IntHACode"] != null)
                {
                    if (IsNullOrEmpty(jsonObject["IntHACode"].ToString()))
                        // popup a modal with message "Accessory Code is mandatory. You must enter data in this field before saving the form. Do you want to correct the value?"
                        return Json("");

                    var a = JArray.Parse(jsonObject["IntHACode"].ToString());

                    intHaCodeTotal += a.Sum(t => int.Parse(t["id"]?.ToString() ?? Empty));
                }

                var blnInitialHumanCaseClassification = false;
                if (jsonObject["blnInitialHumanCaseClassification"] != null)
                {
                    var a = JArray.Parse(jsonObject["blnInitialHumanCaseClassification"].ToString());
                    blnInitialHumanCaseClassification = a.Count == 1;
                }

                var blnFinalHumanCaseClassification = false;
                if (jsonObject["blnFinalHumanCaseClassification"] != null)
                {
                    var a = JArray.Parse(jsonObject["blnFinalHumanCaseClassification"].ToString());
                    blnFinalHumanCaseClassification = a.Count == 1;
                }

                var request = new CaseClassificationSaveRequestModel
                {
                    IdfsCaseClassification = null,
                    Default = jsonObject["StrDefault"]?.ToString(),
                    Name = jsonObject["StrName"]?.ToString(),
                    BlnInitialHumanCaseClassification = blnInitialHumanCaseClassification,
                    BlnFinalHumanCaseClassification = blnFinalHumanCaseClassification,
                    intHACode = intHaCodeTotal,
                    intOrder = !IsNullOrEmpty(jsonObject["IntOrder"]?.ToString())
                        ? int.Parse(jsonObject["IntOrder"].ToString())
                        : 0,
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                response = await _caseClassificationClient.SaveCaseClassification(request);
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        request.Default),
                    "SUCCESS" => _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                    _ => response.strClientPageMessage
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(response);
        }

        [HttpPost]
        public async Task<JsonResult> Edit([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);
            var response = new APISaveResponseModel();

            try
            {
                if (jsonObject["KeyId"] != null)
                {
                    var intHaCodeTotal = 0;
                    if (jsonObject["StrHACodeNames"] != null)
                        for (var i = 0; i < jsonObject["StrHACodeNames"].Children().Count(); i++)
                        {
                            int.TryParse(jsonObject["StrHACodeNames"].Children().ElementAt(i)["id"]?.ToString(),
                                out var outResult);
                            intHaCodeTotal += outResult;
                        }

                    var blnInitialHumanCaseClassification = false;
                    if (jsonObject["blnInitialHumanCaseClassification"] != null)
                        blnInitialHumanCaseClassification =
                            jsonObject["blnInitialHumanCaseClassification"].ToString() == "True";

                    var blnFinalHumanCaseClassification = false;
                    if (jsonObject["blnFinalHumanCaseClassification"] != null)
                        blnFinalHumanCaseClassification =
                            jsonObject["blnFinalHumanCaseClassification"].ToString() == "True";

                    var request = new CaseClassificationSaveRequestModel
                    {
                        IdfsCaseClassification = long.Parse(jsonObject["KeyId"].ToString()),
                        Default = jsonObject["StrDefault"]?.ToString(),
                        Name = jsonObject["StrName"]?.ToString(),
                        BlnInitialHumanCaseClassification = blnInitialHumanCaseClassification,
                        BlnFinalHumanCaseClassification = blnFinalHumanCaseClassification,
                        intHACode = intHaCodeTotal,
                        intOrder = !IsNullOrEmpty(jsonObject["IntOrder"]?.ToString())
                            ? int.Parse(jsonObject["IntOrder"].ToString())
                            : 0,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                    };

                    response = await _caseClassificationClient.SaveCaseClassification(request);
                    response.strClientPageMessage = response.ReturnMessage switch
                    {
                        "DOES EXIST" => Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                            request.Default),
                        "SUCCESS" => _localizer.GetString(
                            MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                        _ => response.strClientPageMessage
                    };

                    return Json(response);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
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
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new CaseClassificationSaveRequestModel
                    {
                        DeleteAnyway = true, 
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        IdfsCaseClassification = long.Parse(jsonObject["KeyId"].ToString())
                    };

                    var response =
                        await _caseClassificationClient.DeleteCaseClassification(request);

                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["KeyId"].ToString());

                    if (response.ReturnMessage == "IN USE")
                    {
                        responsePost.strClientPageMessage = "You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?";
                    }

                    return Json(responsePost);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            return Json(responsePost);
        }
    }
}