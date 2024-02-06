using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels.Administration;
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
using static System.Int32;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class DiseaseAgeGroupMatrixPageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;
        private readonly IDiseaseAgeGroupMatrixClient _diseaseAgeGroupClient;
        private readonly IDiseaseClient _diseaseClient;
        private readonly IStringLocalizer _localizer;

        public DiseaseAgeGroupMatrixPageController(
            IDiseaseAgeGroupMatrixClient diseaseAgeGroupClient,
            IDiseaseClient diseaseClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<DiseaseAgeGroupMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _diseaseAgeGroupClient = diseaseAgeGroupClient;
            _diseaseClient = diseaseClient;
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
        //[Route("GetList")]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { ddlDisease = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? diseaseId = null;
            if (referenceType.ddlDisease != null)
            {
                if (!IsNullOrEmpty(referenceType.ddlDisease))
                {
                    diseaseId = long.Parse(referenceType.ddlDisease);
                }
            }

            //Sorting
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            var strSortColumn = "StrAgeGroupDefault";
            if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "IdfsDiagnosisAgeGroup")
            {
                strSortColumn = valuePair.Key;
            }
            
            var request = new DiseaseAgeGroupGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                IdfsDiagnosis = diseaseId,
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = strSortColumn,
                SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
            };

            var response = await _diseaseAgeGroupClient.GetDiseaseAgeGroupMatrix(request);            
            IEnumerable<DiseaseAgeGroupMatrixViewModel> matrixList = response;            
            
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
                    matrixList.ElementAt(i).IdfDiagnosisAgeGroupToDiagnosis.ToString(),
                    matrixList.ElementAt(i).IdfsDiagnosisAgeGroup.ToString(),
                    matrixList.ElementAt(i).StrAgeGroupDefault,
                    true.ToString()
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);            
        }

        [HttpPost]
        [Route("AddDiseaseAgeGroup")]
        public async Task<IActionResult> AddDiseaseAgeGroup([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            DiseaseAgeGroupSaveRequestModel request = new()
            {
                IdfDiagnosisAgeGroupToDiagnosis = null,
                IdfsDiagnosis = long.Parse(jsonObject["ddlDisease"]?[0]?["id"]?.ToString() ?? Empty),
                IdfsDiagnosisAgeGroup = long.Parse(jsonObject["IdfsDiagnosisAgeGroup"]?[0]?["id"]?.ToString() ?? Empty),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            AgeGroupSaveRequestResponseModel response = new();

            try
            {
                response = await _diseaseAgeGroupClient.SaveDiseaseAgeGroupMatrix(request);
            }
            catch(Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
            }
                                    
            response.strDuplicatedField = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), jsonObject["IdfsDiagnosisAgeGroup"]?[0]?["text"]);
            return Json(response);            
        }

        [HttpPost]
        [Route("DeleteDiseaseAgeGroup")]
        public async Task<JsonResult> DeleteDiseaseAgeGroup([FromBody] JsonElement json)
        {
            var jsonObject = JObject.Parse(json.ToString() ?? Empty);
            var idfDiagnosisAgeGroupToDiagnosis = long.Parse(jsonObject["IdfDiagnosisAgeGroupToDiagnosis"]?.ToString() ?? Empty);
            
            DiseaseAgeGroupSaveRequestModel request = new()
            {
                IdfDiagnosisAgeGroupToDiagnosis = idfDiagnosisAgeGroupToDiagnosis,
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            var response = await _diseaseAgeGroupClient.DeleteDiseaseAgeGroupMatrixRecord(request);

            return Json(response);
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
                    SimpleSearch = null,
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = SortConstants.Ascending,
                    AccessoryCode = HACodeList.HumanHACode,
                    LanguageId = GetCurrentLanguage(),
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                var list = await _diseaseClient.GetDiseasesList(request);
                list = list.Where(a => a.IdfsUsingType == UsingType.StandardCaseType).OrderBy(d => d.IntOrder).ThenBy(d => d.StrName).ToList();

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
    }
}
