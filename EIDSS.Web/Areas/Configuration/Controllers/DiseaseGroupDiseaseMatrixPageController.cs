using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ResponseModels;
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

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class DiseaseGroupDiseaseMatrixPageController : BaseController
    {
        private readonly ConfigurationMatrixPagesViewModel _configurationMatrixViewModel;
        private readonly IConfigurationClient _configurationClient;
        private readonly IAdminClient _adminClient;
        private readonly IDiseaseClient _diseaseClient;
        private readonly IStringLocalizer _localizer;

        public DiseaseGroupDiseaseMatrixPageController(IConfigurationClient configurationClient, IAdminClient adminClient, IStringLocalizer localizer,
            IDiseaseClient diseaseClient, ILogger<DiseaseGroupDiseaseMatrixPageController> logger, ITokenService tokenService)
            : base(logger, tokenService)
        {
            _configurationMatrixViewModel = new ConfigurationMatrixPagesViewModel();
            _configurationClient = configurationClient;
            _adminClient = adminClient;
            _diseaseClient = diseaseClient;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _configurationMatrixViewModel.UserPermissions = userPermissions;
            _localizer = localizer;
        }

        public IActionResult Index()
        {
            _configurationMatrixViewModel.Select2Configurations = new List<Select2Configruation>();
            _configurationMatrixViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            _configurationMatrixViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_configurationMatrixViewModel);
        }

        [HttpPost]
        public async Task<JsonResult> GetList([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            var postParameterDefinitions = new { PageLevelDD = "", SearchBox = "" };
            var referenceType = Newtonsoft.Json.JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

            long? id = null;
            if (referenceType.PageLevelDD != null)
            {
                if (!string.IsNullOrEmpty(referenceType.PageLevelDD))
                {
                    id = long.Parse(referenceType.PageLevelDD);
                }
            }

            var list = new List<ConfigurationMatrixViewModel>();
            if (dataTableQueryPostObj.postArgs.Length > 0)
            {
                //Sorting
                var valuePair = dataTableQueryPostObj.ReturnSortParameter();

                var strSortColumn = "intOrder";
                if (!string.IsNullOrEmpty(valuePair.Key) && valuePair.Key != "KeyId")
                {
                    strSortColumn = valuePair.Key;
                }

                var request = new DiseaseGroupDiseaseMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsDiagnosisGroup = id,
                    Page = dataTableQueryPostObj.page,
                    PageSize = dataTableQueryPostObj.length,
                    SortColumn = strSortColumn,
                    SortOrder = !string.IsNullOrEmpty(valuePair.Value) ? valuePair.Value : "asc"
                };

                list = await _configurationClient.GetDiseaseGroupDiseaseMatrixList(request);
            }

            var tableData = new TableData
            {
                data = new List<List<string>>(),
                iTotalRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                iTotalDisplayRecords = list.Count == 0 ? 0 : list.First().TotalRowCount,
                draw = dataTableQueryPostObj.draw
            };

            if (list.Count <= 0) return Json(tableData);
            var row = dataTableQueryPostObj.page > 0 ? (dataTableQueryPostObj.page - 1) * dataTableQueryPostObj.length : 0;

            for (var i = 0; i < list.Count; i++)
            {
                var cols = new List<string>
                {
                    (row + i + 1).ToString(),
                    list.ElementAt(i).KeyId.ToString(),
                    list.ElementAt(i).idfsDiagnosisGroup.ToString(),
                    list.ElementAt(i).strDiseaseName,
                    list.ElementAt(i).strUsingType,
                    list.ElementAt(i).strHACodeNames,
                    list.ElementAt(i).intOrder.ToString(),
                    ""
                };

                tableData.data.Add(cols);
            }

            return Json(tableData);
        }

        public async Task<JsonResult> Create([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            APISaveResponseModel response;

            try
            {
                if (jsonObject["PageLevelDD"] != null)
                {
                    if (string.IsNullOrEmpty(jsonObject["PageLevelDD"][0]?["id"]?.ToString()))
                    {
                        // should select a Sample Type
                        return Json("");
                    }
                }

                var request = new DiseaseGroupDiseaseMatrixSaveRequestModel
                {
                    idfDiagnosisToDiagnosisGroup = null,
                    idfsDiagnosisGroup = jsonObject["PageLevelDD"] != null ? long.Parse(jsonObject["PageLevelDD"][0]?["id"]?.ToString() ?? string.Empty) : null,
                    idfsDiagnosis = jsonObject["idfsDiagnosis"] != null ? long.Parse(jsonObject["idfsDiagnosis"][0]?["id"]?.ToString() ?? string.Empty) : null,
                    EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                    SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    LocationId = authenticatedUser.RayonId,
                    User = authenticatedUser.UserName
                };

                response = await _configurationClient.SaveDiseaseGroupDiseaseMatrix(request);
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => string.Format(
                        _localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        jsonObject["idfsDiagnosis"]?[0]?["text"]),
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
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["KeyId"] != null)
                {
                    var request = new DiseaseGroupDiseaseMatrixSaveRequestModel
                    {
                        idfDiagnosisToDiagnosisGroup = long.Parse(jsonObject["KeyId"].ToString()),
                        EventTypeId = (long)SystemEventLogTypes.MatrixChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        User = authenticatedUser.UserName
                    };
                    var response = await _configurationClient.DeleteDiseaseGroupDiseaseMatrix(request);
                    if (response.ReturnMessage == "IN USE")
                    {
                        // popup a modal with message “You are attempting to delete a reference value which is currently used in the system. Are you sure you want to delete the reference value?”
                    }

                    // reload the grid
                    //BR: System shall sequentially renumber row, when row is deleted. 
                    return Json(response);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json("");
        }

        [HttpPost]
        public async Task<IActionResult> AddDiseaseGroup([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            BaseReferenceSaveRequestResponseModel response;
            var request = new BaseReferenceSaveRequestModel
            {
                BaseReferenceId = null,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeId = 19000156,
                EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            try
            {
                if (jsonObject["strDefault"] != null)
                {
                    request.Default = jsonObject["strDefault"].ToString();
                }
                if (jsonObject["strName"] != null)
                {
                    request.Name = jsonObject["strName"].ToString();
                }

                if (jsonObject["StrHACode"] != null)
                {
                    var sumHaCode = 0;
                    for (var i = 0; i < jsonObject["StrHACode"].Children().Count(); i++)
                    {
                        int.TryParse(jsonObject["StrHACode"].Children().ElementAt(i)["id"]?.ToString(), out var outResult);
                        sumHaCode += outResult;
                    }
                    request.intHACode = sumHaCode;
                }

                if (jsonObject["IntOrder"] != null)
                {
                    int.TryParse(jsonObject["IntOrder"].ToString(), out var intOrder);
                    request.intOrder = intOrder;
                }

                response = await _adminClient.SaveBaseReference(request);
                response.strClientPageMessage = response.ReturnMessage switch
                {
                    "DOES EXIST" => string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),
                        request.Default),
                    "SUCCESS" => _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage),
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
        public async Task<IActionResult> AddDisease([FromBody] JsonElement data)
        {
            var request = new DiseaseSaveRequestModel();

            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            if (jsonObject["strHACodeNames"] != null)
            {
                var sumHaCode = 0;
                for (var i = 0; i < jsonObject["strHACodeNames"].Children().Count(); i++)
                {
                    int.TryParse(jsonObject["strHACodeNames"].Children().ElementAt(i)["id"]?.ToString(), out var outResult);
                    sumHaCode += outResult;
                }
                request.intHACode = sumHaCode;
            }

            var blnSyndrome = false;
            if (jsonObject["blnSyndrome"] != null)
            {
                var a = JArray.Parse(jsonObject["blnSyndrome"].ToString());
                blnSyndrome = a.Count == 1;
            }

            var blnZoonotic = false;
            if (jsonObject["blnZoonotic"] != null)
            {
                var a = JArray.Parse(jsonObject["blnZoonotic"].ToString());
                blnZoonotic = a.Count == 1;
            }

            var intOrder = 0;
            if (jsonObject["intOrder"] != null)
            {
                intOrder = string.IsNullOrEmpty(((JValue)jsonObject["intOrder"]).Value?.ToString()) ? 0 : int.Parse(jsonObject["intOrder"].ToString());
            }

            request.LanguageId = GetCurrentLanguage();
            request.DiagnosisId = (jsonObject["IdfsDiagnosis"] == null) ? null : long.Parse(jsonObject["IdfsDiagnosis"].ToString());
            request.UsingTypeId = (jsonObject["idfsUsingType"] == null) ? null : long.Parse(jsonObject["idfsUsingType"][0]?["id"]?.ToString() ?? string.Empty);
            request.Default = jsonObject["strDefault"]?.ToString();
            request.Name = jsonObject["strName"]?.ToString();
            request.IDC10 = jsonObject["strIDC10"]?.ToString();
            request.OIECode = jsonObject["strOIECode"]?.ToString();
            request.Zoonotic = blnZoonotic;
            request.Syndrome = blnSyndrome;
            request.intOrder = intOrder;

            var response = await _diseaseClient.SaveDisease(request);
            return Json(response);
        }
    }
}
