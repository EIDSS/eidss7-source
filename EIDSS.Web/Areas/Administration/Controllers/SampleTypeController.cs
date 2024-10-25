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
    public class SampleTypeController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _sampleTypePageViewModel;
        private readonly ISampleTypesClient _sampleTypesClient;
        private readonly UserPermissions userPermissions;
        private readonly IStringLocalizer _localizer;

        public SampleTypeController(ISampleTypesClient sampleTypesClient, ILogger<SampleTypeController> logger, IStringLocalizer localizer,
            ITokenService tokenService) : base(logger, tokenService)
        {
            _sampleTypePageViewModel = new BaseReferenceEditorPagesViewModel();
            _sampleTypesClient = sampleTypesClient;
            userPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables);
            _sampleTypePageViewModel.UserPermissions = userPermissions;
            _localizer = localizer;
        }

        public IActionResult Index()
        {
            _sampleTypePageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _sampleTypePageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            _sampleTypePageViewModel.Select2Configurations = new List<Select2Configruation>();
            return View(_sampleTypePageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

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

                var request = new SampleTypesEditorGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    SampleTypeSearch = referenceType.SearchBox,
                    AdvancedSearch = string.IsNullOrEmpty(referenceType.SearchBox) ? null : referenceType.SearchBox,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : EIDSSConstants.SortConstants.Ascending
                };

                //API CALL
                list = await _sampleTypesClient.GetSampleTypesReferenceList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = !list.Any() ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (!list.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;
            for (var i = 0; i < list.Count(); i++)
            {
                var cols = new List<string>()
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).KeyId.ToString(),
                    list.ElementAt(i).StrDefault,
                    list.ElementAt(i).StrName,
                    list.ElementAt(i).StrSampleCode,
                    list.ElementAt(i).LOINC_NUMBER,
                    list.ElementAt(i).StrHACodeNames,
                    list.ElementAt(i).IntOrder.ToString(),
                    list.ElementAt(i).StrHACode != null ? list.ElementAt(i).StrHACode : string.Empty,
                    "",
                    "",
                    ""
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
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
                    var intHaCodeTotal = 0;
                    if (jsonObject["StrHACodeNames"] != null)
                    {
                        for (var i = 0; i < jsonObject["StrHACodeNames"].Children().Count(); i++)
                        {
                            int.TryParse(jsonObject["StrHACodeNames"].Children().ElementAt(i)["id"]?.ToString(), out var outResult);
                            intHaCodeTotal += outResult;
                        }
                    }

                    var strSampleCode = string.Empty;
                    if (jsonObject["StrSampleCode"] != null)
                    {
                        strSampleCode = jsonObject["StrSampleCode"].ToString();
                    }

                    var intOrder = 0;
                    if (jsonObject["IntOrder"] != null)
                    {
                        intOrder = string.IsNullOrEmpty(((JValue)jsonObject["IntOrder"]).Value?.ToString()) ? 0 : int.Parse(jsonObject["IntOrder"].ToString());
                    }

                    var newSampleType = new SampleTypeSaveRequestModel
                    {
                        SampleTypeId = long.Parse(jsonObject["KeyId"].ToString()),
                        Default = jsonObject["StrDefault"]?.ToString().Trim(),
                        Name = jsonObject["StrName"]?.ToString().Trim(),
                        SampleCode = strSampleCode,
                        LOINC_NUMBER = jsonObject["LOINC_NUMBER"]?.ToString(),
                        intHACode = intHaCodeTotal,
                        intOrder = intOrder,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                    };

                    response = await _sampleTypesClient.SaveSampleType(newSampleType);
                    response.strClientPageMessage = response.ReturnMessage switch
                    {
                        "DOES EXIST" => string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                            newSampleType.Default),
                        "SUCCESS" => _localizer.GetString(
                            MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                        _ => response.strClientPageMessage
                    };
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
        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            APISaveResponseModel response;

            try
            {
                var intHaCodeTotal = 0;
                if (jsonObject["IntHACode"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["IntHACode"].ToString()))
                    {
                        // popup a modal with message "Accessory Code is mandatory. You must enter data in this field before saving the form. Do you want to correct the value?"
                        return Json("");
                    }
                    else
                    {
                        var a = JArray.Parse(jsonObject["IntHACode"].ToString());

                        intHaCodeTotal += a.Sum(t => int.Parse(t["id"]?.ToString() ?? string.Empty));
                    }
                }

                var strSampleCode = string.Empty;
                if (jsonObject["StrSampleCode"] != null)
                {
                    strSampleCode = jsonObject["StrSampleCode"].ToString();
                }

                var intOrder = 0;
                if (jsonObject["IntOrder"] != null)
                {
                    intOrder = string.IsNullOrEmpty(((JValue)jsonObject["IntOrder"]).Value?.ToString()) ? 0 : int.Parse(jsonObject["IntOrder"].ToString());
                }

                var newSampleType = new SampleTypeSaveRequestModel
                {
                    SampleTypeId = null,
                    Default = jsonObject["StrDefault"]?.ToString().Trim(),
                    Name = jsonObject["StrName"]?.ToString().Trim(),
                    SampleCode = strSampleCode,
                    LOINC_NUMBER = jsonObject["LOINC_NUMBER"]?.ToString(),
                    intHACode = intHaCodeTotal,
                    intOrder = intOrder,
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                response = await _sampleTypesClient.SaveSampleType(newSampleType);
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        newSampleType.Default),
                    "SUCCESS" => _localizer.GetString(MessageResourceKeyConstants.RecordSubmittedSuccessfullyMessage),
                    _ => response.strClientPageMessage
                };
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
            var forceDelete = false;
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["KeyId"] != null)
                {
                    if (jsonObject["ForceDelete"] != null)
                        forceDelete = !string.IsNullOrEmpty(jsonObject["ForceDelete"].ToString()) && bool.Parse(jsonObject["ForceDelete"].ToString());

                    var request = new SampleTypeSaveRequestModel
                    {
                        DeleteAnyway = forceDelete,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        SampleTypeId = long.Parse(jsonObject["KeyId"].ToString())
                    };

                    var response = await _sampleTypesClient.DeleteSampleType(request);

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
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(responsePost);
        }
    }
}
