using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
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
using EIDSS.Domain.ResponseModels;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class ReportDiseaseGroupPageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;
        private readonly IReportDiseaseGroupClient _reportDiseaseGroupClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;

        public ReportDiseaseGroupPageController(
            IReportDiseaseGroupClient reportDiseaseGroupClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<ReportDiseaseGroupPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _reportDiseaseGroupClient = reportDiseaseGroupClient;
            _localizer = localizer;
            _userPermissions = GetUserPermissions(PagePermission.CanManageBaseReferencePage);
            _pageViewModel.UserPermissions = _userPermissions;
        }

        public IActionResult Index()
        {
            _pageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_pageViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var postParameterDefinitions = new { SearchBox = "" };
                var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "StrName";
                if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "ReportDiseaseGroupId")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new ReportDiseaseGroupsGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    StrSearch = referenceType.SearchBox.Trim(),
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
                };

                var response = await _reportDiseaseGroupClient.GetReportDiseaseGroupsList(request);
                IEnumerable<BaseReferenceEditorsViewModel> reportDiseaseGroupsList = response;

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                    iTotalDisplayRecords = response.Count == 0 ? 0 : response[0].TotalRowCount,
                    draw = dataTableQueryPostObj.draw
                };


                var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

                for (var i = 0; i < reportDiseaseGroupsList.Count(); i++)
                {
                    List<string> cols = new()
                    {
                        (row + i + 1).ToString(),
                        reportDiseaseGroupsList.ElementAt(i).KeyId.ToString(),
                        reportDiseaseGroupsList.ElementAt(i).StrDefault ?? Empty, // English Value
                        reportDiseaseGroupsList.ElementAt(i).StrName ?? Empty,  // Translated Value
                        reportDiseaseGroupsList.ElementAt(i).StrCode ?? Empty,  // ICD-10
                    };
                    tableData.data.Add(cols);
                }

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("AddReportDiseaseGroup")]
        public async Task<IActionResult> AddReportDiseaseGroup([FromBody] JsonElement jsonElement)
        {
            try
            {
                var jsonObject = JObject.Parse(jsonElement.ToString() ?? Empty);
                var request = new ReportDiseaseGroupsSaveRequestModel
                {
                    Default = jsonObject["Default"]?.ToString().Trim(),
                    Name = jsonObject["Name"]?.ToString().Trim(),
                    StrCode = jsonObject["ICD10"]?.ToString().Trim(),
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                var response = await _reportDiseaseGroupClient.SaveReportDiseaseGroup(request);
                response.StrDuplicatedField = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("EditReportDiseaseGroup")]
        public async Task<JsonResult> EditReportDiseaseGroup([FromBody] JsonElement jsonElement)
        {
            try
            {
                var jsonObject = JObject.Parse(jsonElement.ToString() ?? Empty);
                var request = new ReportDiseaseGroupsSaveRequestModel
                {
                    IdfsReportDiagnosisGroup = Convert.ToInt64(jsonObject["ReportDiseaseGroupId"]?.ToString()),
                    Default = jsonObject["StrDefault"]?.ToString().Trim(),
                    Name = jsonObject["StrName"]?.ToString().Trim(),
                    StrCode = jsonObject["StrCode"]?.ToString().Trim(),
                    LanguageId = GetCurrentLanguage(),
                    EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                    AuditUserName = authenticatedUser.UserName,
                    LocationId = authenticatedUser.RayonId,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                };

                var response = await _reportDiseaseGroupClient.SaveReportDiseaseGroup(request);
                response.StrDuplicatedField = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), request.Default);
                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        [Route("DeleteReportDiseaseGroup")]
        public async Task<JsonResult> DeleteReportDiseaseGroup([FromBody] JsonElement jsonElement)
        {
            var responsePost = new APISaveResponseModel();

            try
            {
                var jsonObject = JObject.Parse(jsonElement.ToString() ?? Empty);

                if (jsonObject["ReportDiseaseGroupId"] != null)
                {
                    ReportDiseaseGroupsSaveRequestModel request = new()
                    {
                        DeleteAnyway = true,
                        LanguageId = GetCurrentLanguage(),
                        EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        IdfsReportDiagnosisGroup = long.Parse(jsonObject["ReportDiseaseGroupId"].ToString())
                    };

                    var response = await _reportDiseaseGroupClient.DeleteReportDiseaseGroup(request);

                    responsePost.ReturnMessage = response.ReturnMessage;
                    responsePost.KeyId = long.Parse(jsonObject["ReportDiseaseGroupId"].ToString());
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
    }
}