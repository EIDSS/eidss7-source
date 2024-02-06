using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
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
using static System.Int64;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class ReportDiseaseGroupDiseaseMatrixPageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;
        private readonly IReportDiseaseGroupDiseaseMatrixClient _reportDiseaseGroupDiseaseClient;
        private readonly IDiseaseClient _diseaseClient;
        private readonly ICrossCuttingClient _crossCuttingClient;        
        private readonly IStringLocalizer _localizer;

        public ReportDiseaseGroupDiseaseMatrixPageController(
            IReportDiseaseGroupDiseaseMatrixClient reportDiseaseGroupDiseaseClient,
            ICrossCuttingClient crossCuttingClient,
            IDiseaseClient diseaseClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<ReportDiseaseGroupDiseaseMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();            
            _crossCuttingClient = crossCuttingClient;
            _diseaseClient = diseaseClient;
            _reportDiseaseGroupDiseaseClient = reportDiseaseGroupDiseaseClient;
            _localizer = localizer;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _pageViewModel.UserPermissions = userPermissions;
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
            var postParameterDefinitions = new { ddlCustomReportType = "", ddlReportDiseaseGroup = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long idfsCustomReportType = 0;
            if (referenceType.ddlCustomReportType != null)
            {
                if (!IsNullOrEmpty(referenceType.ddlCustomReportType))
                {
                    idfsCustomReportType = Parse(referenceType.ddlCustomReportType);
                }
            }

            long idfsReportDiagnosisGroup = 0;
            if (referenceType.ddlReportDiseaseGroup != null)
            {
                if (!IsNullOrEmpty(referenceType.ddlReportDiseaseGroup))
                {
                    idfsReportDiagnosisGroup = Parse(referenceType.ddlReportDiseaseGroup);
                }
            }

            //Sorting
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            var strSortColumn = "strDiagnosis";
            if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfDiagnosisToGroupForReportType")
            {
                strSortColumn = valuePair.Key;
            }

            var request = new ReportDiseaseGroupDiseaseMatrixGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                IdfsCustomReportType = idfsCustomReportType, 
                IdfsReportDiagnosisGroup = idfsReportDiagnosisGroup,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = strSortColumn,
                SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
            };

            var response = await _reportDiseaseGroupDiseaseClient.GetReportDiseaseGroupDiseaseMatrix(request);
            IEnumerable<ReportDiseaseGroupDiseaseMatrixViewModel> matrixList = response;            

            var tableData = new TableData
            {
                iTotalRecords = !matrixList.Any() ? 0 : matrixList.First().TotalRowCount,
                iTotalDisplayRecords = !matrixList.Any() ? 0 : matrixList.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw,
                data = new List<List<string>>()
            };

            if (!matrixList.Any()) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < matrixList.Count(); i++)
            {
                List<string> cols = new()
                {
                    (row + i + 1).ToString(),
                    matrixList.ElementAt(i).IdfDiagnosisToGroupForReportType.ToString(),
                    matrixList.ElementAt(i).StrDiagnosis ?? Empty,
                    matrixList.ElementAt(i).StrUsingType ?? Empty,
                    matrixList.ElementAt(i).StrAccessoryCode ?? Empty,
                    matrixList.ElementAt(i).StrIsDelete ?? Empty,                        
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> CustomReportTypeList(int page, string data)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            try
            {             
                var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CustomReportType, HACodeList.NoneHACode);
                list = list.OrderBy(o => o.IntOrder).ThenBy(n => n.Name).ToList();

                select2DataItems.AddRange(list.Select(item => new Select2DataItem() {id = item.IdfsBaseReference.ToString(), text = item.Name}));
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return Json(select2DataObj);
        }

        public async Task<JsonResult> ReportDiseaseGroupList(int page, string data)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ReportDiseaseGroup, HACodeList.NoneHACode);
                list = list.OrderBy(o => o.IntOrder).ThenBy(n => n.Name).ToList();

                select2DataItems.AddRange(list.Select(item => new Select2DataItem() {id = item.IdfsBaseReference.ToString(), text = item.Name}));
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return Json(select2DataObj);
        }

        public async Task<JsonResult> DiseaseList(int page, string data)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            try
            {
                var request = new DiseasesGetRequestModel
                {
                    AdvancedSearch = null,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = SortConstants.Ascending,
                    SimpleSearch = null,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                var list = await _diseaseClient.GetDiseasesList(request);
                list = list.OrderBy(d => d.IntOrder).ThenBy(d => d.StrName).ToList();

                select2DataItems.AddRange(list.Select(item => new Select2DataItem() {id = item.KeyId.ToString(), text = item.StrName}));
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return Json(select2DataObj);
        }


        [HttpPost]
        [Route("AddReportDiseaseGroupDiseaseMatrix")]
        public async Task<IActionResult> AddReportDiseaseGroupDiseaseMatrix([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            ReportDiseaseGroupDiseaseMatrixSaveRequestModel request = new()
            {
                IdfDiagnosisToGroupForReportType = null,
                IdfsCustomReportType = Parse(jsonObject["ddlCustomReportType"]?[0]?["id"]?.ToString() ?? Empty),
                IdfsReportDiagnosisGroup = Parse(jsonObject["ddlReportDiseaseGroup"]?[0]?["id"]?.ToString() ?? Empty),
                IdfsDiagnosis = Parse(jsonObject["IdfsDiagnosis"]?[0]?["id"]?.ToString() ?? Empty),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            APISaveResponseModel response = new();

            try
            {
                response = await _reportDiseaseGroupDiseaseClient.SaveReportDiseaseGroupDiseaseMatrix(request);
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
            }

            response.strClientPageMessage = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), jsonObject["IdfsDiagnosis"]?[0]?["text"]);
            return Json(response);
        }

        [HttpPost]
        [Route("DeleteReportDiseaseGroupDiseaseMatrix")]
        public async Task<JsonResult> DeleteReportDiseaseGroupDiseaseMatrix([FromBody] JsonElement json)
        {
            var jsonObject = JObject.Parse(json.ToString() ?? Empty);
            
            var idfDiagnosisToGroupForReportType = Convert.ToInt64(jsonObject["IdfDiagnosisToGroupForReportType"]?.ToString());

            ReportDiseaseGroupDiseaseMatrixSaveRequestModel request = new()
            {
                IdfDiagnosisToGroupForReportType = idfDiagnosisToGroupForReportType,
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            var response = await _reportDiseaseGroupDiseaseClient.DeleteReportDiseaseGroupDiseaseMatrix(request);

            return Json(response);
        }
    }
}
