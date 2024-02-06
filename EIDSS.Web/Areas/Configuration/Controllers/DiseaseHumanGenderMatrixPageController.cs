using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
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
    public class DiseaseHumanGenderMatrixPageController : BaseController
    {
        private readonly BaseReferenceEditorPagesViewModel _pageViewModel;        
        private readonly IDiseaseHumanGenderMatrixClient _diseaseHumanGenderClient;
        private readonly IStringLocalizer _localizer;

        public DiseaseHumanGenderMatrixPageController(
            IDiseaseHumanGenderMatrixClient diseaseHumanGenderClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<DiseaseHumanGenderMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new BaseReferenceEditorPagesViewModel();
            _diseaseHumanGenderClient = diseaseHumanGenderClient;
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
            var postParameterDefinitions = new { ddlDisease = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            if (referenceType.ddlDisease != null)
            {
                if (!IsNullOrEmpty(referenceType.ddlDisease))
                {
                }
            }

            //Sorting
            var valuePair = dataTableQueryPostObj.ReturnSortParameter();

            var strSortColumn = "strDiseaseGroupName";
            if (!IsNullOrEmpty(valuePair.Key) && valuePair.Key != "DisgnosisGroupToGenderUID")
            {
                strSortColumn = valuePair.Key;
            }

            var request = new DiseaseHumanGenderMatrixGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),                      
                Page = dataTableQueryPostObj.page,
                PageSize = dataTableQueryPostObj.length,
                SortColumn = strSortColumn,
                SortOrder = !IsNullOrEmpty(valuePair.Value) ? valuePair.Value : SortConstants.Ascending
            };

            var response = await _diseaseHumanGenderClient.GetDiseaseHumanGenderMatrix(request);
            IEnumerable<DiseaseHumanGenderMatrixViewModel> matrixList = response;

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
                    matrixList.ElementAt(i).DisgnosisGroupToGenderUID.ToString(),                        
                    matrixList.ElementAt(i).strDiseaseGroupName ?? Empty,
                    matrixList.ElementAt(i).strGender ?? Empty,
                    true.ToString()
                };
                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        [HttpPost]
        [Route("AddDiseaseHumanGender")]
        public async Task<IActionResult> AddDiseaseHumanGender([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            DiseaseHumanGenderMatrixSaveRequestModel request = new()
            {
                DiagnosisGroupID = Parse(jsonObject["IdfsDiagnosis"]?[0]?["id"]?.ToString() ?? Empty),
                GenderID = Parse(jsonObject["IdfsBaseReference"]?[0]?["id"]?.ToString() ?? Empty),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            APISaveResponseModel response = new();

            try
            {
                response = await _diseaseHumanGenderClient.SaveDiseaseHumanGenderMatrix(request);
            }
            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex.Message);
            }

            response.strClientPageMessage = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), jsonObject["IdfsDiagnosis"]?[0]?["text"]);
            return Json(response);
        }

        [HttpPost]
        [Route("DeleteDiseaseHumanGender")]
        public async Task<JsonResult> DeleteDiseaseHumanGender([FromBody] JsonElement json)
        {
            var jsonObject = JObject.Parse(json.ToString() ?? Empty);
            var diagnosisGroupToGenderUid = Parse(jsonObject["DiagnosisGroupToGenderUID"]?.ToString() ?? Empty);

            DiseaseHumanGenderMatrixSaveRequestModel request = new()
            {
                DiagnosisGroupToGenderUID = diagnosisGroupToGenderUid,
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            var response = await _diseaseHumanGenderClient.DeleteDiseaseHumanGenderMatrix(request);
                
            return Json(response);
        }
    }
}
