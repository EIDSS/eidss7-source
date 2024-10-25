using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Configuration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Localization;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;


namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    //[Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage")]
    public class VeterinaryDiagnosticInvestigationMatrixPageController : BaseController
    {
        private readonly VeterinaryDiagnosticInvestigationMatrixPageViewModel _pageViewModel;
        private readonly IVeterinaryDiagnosticInvestigationMatrixClient _client;
        private readonly IAdminClient _adminClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IStringLocalizer _localizer;

        public VeterinaryDiagnosticInvestigationMatrixPageController(
            IVeterinaryDiagnosticInvestigationMatrixClient client,
            ICrossCuttingClient crossCuttingClient,
             IAdminClient adminClient,
            IStringLocalizer localizer,
            ITokenService tokenService,
            ILogger<VeterinaryDiagnosticInvestigationMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new VeterinaryDiagnosticInvestigationMatrixPageViewModel();
            _client = client;
            _adminClient = adminClient;
            _crossCuttingClient = crossCuttingClient;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);            
            _pageViewModel.UserPermissions = userPermissions;
            _localizer = localizer;
        }
        
        public async Task<ActionResult> Index()
        {            
            _pageViewModel.MatrixVersionList = await GetMatrixVersionsByType(MatrixTypes.DiagnosticInvestigations);
            _pageViewModel.DisableNewMatrix = DoesNonActiveMatrixExist(_pageViewModel.MatrixVersionList);            
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();
            return View(_pageViewModel);
        }

        [Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage/GetMatrix")]
        public async Task<IActionResult> GetMatrix(long id)
        {
            ViewBag.SelectedVersionId = id;
            _pageViewModel.MatrixVersionList = await GetMatrixVersionsByType(MatrixTypes.DiagnosticInvestigations);
            //task.Wait();
            //_pageViewModel.MatrixVersionList = task.Result;
            _pageViewModel.MatrixList = await LoadMatrixList(id);
            _pageViewModel.MatrixName = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).MatrixName;

            // activation date of the selected matrix
            var activationDate = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).DatStartDate;
            if (activationDate != null)
                _pageViewModel.ActivationDate = ((DateTime)activationDate).ToShortDateString();

            // set the "active status" of the selected matrix
            if (activationDate == null)
            {
                _pageViewModel.VersionStatus = "nonactive";
            }
            else
            {
                var blnIsActive = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).BlnIsActive;
                if (blnIsActive != null && (bool)blnIsActive)
                {
                    _pageViewModel.VersionStatus = "active";
                }
                else
                {
                    var isActive = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).BlnIsActive;
                    if (isActive != null && !(bool)isActive)
                    {
                        _pageViewModel.VersionStatus = "inactive";
                    }
                }
            }

            _pageViewModel.DisableNewMatrix = DoesNonActiveMatrixExist(_pageViewModel.MatrixVersionList);
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            _pageViewModel.Select2Configurations = new List<Select2Configruation>();

            // if we are active and we have a date then disable the calendar
            if (_pageViewModel.VersionStatus != "nonactive" && _pageViewModel.ActivationDate != null)
            {
                _pageViewModel.DisableCalendar = true;
            }

            return View("Index", _pageViewModel);
            //return new EmptyResult();
        }

        [HttpPost]
        [Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage/AddNewReferenceType")]
        public async Task<IActionResult> AddNewReferenceType([FromBody] JsonElement data)        
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            var serializer = JsonSerializer.Serialize(data);
            
            BaseReferenceSaveRequestModel baseReferenceSaveRequestModel = new()
            {
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            try
            {
                if (jsonObject["EnglishValue"] != null)
                {
                    baseReferenceSaveRequestModel.Default = jsonObject["EnglishValue"].ToString();
                }
                
                if (jsonObject["TranslatedValue"] != null)
                {
                    baseReferenceSaveRequestModel.Name = jsonObject["TranslatedValue"].ToString();
                }

                if (jsonObject["IntOrder"] != null)
                {
                    int.TryParse(jsonObject["IntOrder"].ToString(), out var intOrder);
                    baseReferenceSaveRequestModel.intOrder = intOrder;
                }

                baseReferenceSaveRequestModel.ReferenceTypeId = 19000021;

                _ = await _adminClient.SaveBaseReference(baseReferenceSaveRequestModel);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            //return new EmptyResult();
            return Json("");
        }

        [HttpPost]
        [Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage/ActivateMatrixVersion")]
        public async Task<ActionResult> ActivateMatrixVersion([FromBody] JsonElement data)
        {            
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            HumanAggregateCaseMatrixRequestModel headerModel = new()
            {
                MatrixName = jsonObject["MatrixName"]?.ToString(),
                StartDate = DateTime.Now,
                IsActive = true,
                IsDefault = false,
                MatrixTypeId = MatrixTypes.DiagnosticInvestigations,
                VersionId = Convert.ToInt64(jsonObject["IdfVersion"]),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            // save matrix header 
            _ = await _crossCuttingClient.SaveMatrixVersion(headerModel);

            return new EmptyResult();
        }      

        [HttpPost]
        [Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage/DeleteMatrixVersion")]
        public async Task<ActionResult> DeleteMatrixVersion([FromBody] JsonElement data)
        {
            try
            {
                var jObject = JObject.Parse(data.ToString() ?? string.Empty);
                var response = await _crossCuttingClient.DeleteMatrixVersion((long)jObject["IdfVersion"]);
                return new EmptyResult();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        [Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage/SaveMatrix")]
        public async Task<ActionResult> SaveMatrix([FromBody] JsonElement data)
        {
            var jsonArray = JArray.Parse(data.ToString() ?? string.Empty);
            var isEmpty = (bool)jsonArray[0]["IsEmpty"];
            var isNew = (bool)jsonArray[0]["IsNew"];            
            var activeStatus = string.Empty;
            if (jsonArray[0]["ActiveStatus"] != null) activeStatus = jsonArray[0]["ActiveStatus"].ToString();

            var isActive = !(activeStatus is "nonactive" or "inactive" || isNew);

            HumanAggregateCaseMatrixRequestModel headerModel = new()
            {
                MatrixName = jsonArray[0]["MatrixName"]?.ToString(),
                IsActive = isActive,
                IsDefault = false,
                MatrixTypeId = MatrixTypes.DiagnosticInvestigations,
                EventTypeId = null,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            if (!string.IsNullOrEmpty(jsonArray[0]["ActivationDate"]?.ToString()) && !isNew)
                headerModel.StartDate = (DateTime)jsonArray[0]["ActivationDate"];

            if (jsonArray[0]["IdfVersion"] != null)
                headerModel.VersionId = Convert.ToInt64(jsonArray[0]["IdfVersion"]);

            // save matrix header 
            var headerResponse = await _crossCuttingClient.SaveMatrixVersion(headerModel);

            if (headerResponse.ReturnMessage != "SUCCESS") return Json(headerResponse);
            if (isEmpty) return Json(headerResponse);
            MatrixViewModel request = new()
            {
                IdfVersion = headerResponse.KeyId, //Convert.ToInt64(jsonArray[0]["IdfVersion"]),
                InJsonString = data.ToString(),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            // save matrix grid     
            var response = await _client.SaveVeterinaryDiagnosticInvestigationMatrix(request);

            //if (isNew) return Json(headerResponse.KeyId);
            return Json(headerResponse);

            //this will also work because i'm reloading the page from javascript which will call GetMatrix to grab the new data
            //return new EmptyResult();
            //return Json(response);
        }

        [HttpPost]
        [Route("Configuration/VeterinaryDiagnosticInvestigationMatrixPage/DeleteMatrixRecord")]
        public async Task<ActionResult> DeleteMatrixRecord([FromBody] JsonElement data)
        {            
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

            var id = (long)jsonObject["IdfAggrDiagnosticActionMTX"];

            if (id <= 0) return new EmptyResult();
            MatrixViewModel request = new()
            {
                IdfAggrDiagnosticActionMTX = id,
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };
            var response = await _client.DeleteVeterinaryDiagnosticInvestigationMatrixRecord(request);

            return Json(response);
        }

        private async Task<List<MatrixVersionViewModel>> GetMatrixVersionsByType(long matrixType)
        {
            var versions = await _crossCuttingClient.GetMatrixVersionsByType(matrixType);

            foreach (var v in versions)
            {
                v.IsCheckmarkVisible = true;

                if (v.DatStartDate != null)
                {
                    v.ActivationDateDisplay = Convert.ToDateTime(v.DatStartDate).ToShortDateString();
                }

                if (v.BlnIsActive != null && v.DatStartDate != null && (bool)v.BlnIsActive)
                {
                    v.ActiveColor = "red";
                    ViewBag.ActiveVersionId = v.IdfVersion;
                }
                else if (v.BlnIsActive != null && v.DatStartDate != null && !(bool)v.BlnIsActive)
                {
                    v.ActiveColor = "lightgreen";
                }
                else if (v.DatStartDate == null)
                {
                    v.ActiveColor = "rgba(255, 255, 255, 0);";
                }
            }

            return versions;
        }

        private bool DoesNonActiveMatrixExist(List<MatrixVersionViewModel> versions)
        {
            // find if there is at least one nonactive matrix already 
            // prevent multiple nonactive matrix from being created (business rule)
            //_pageViewModel.DisableNewMatrix = false;
            var nonActiveMatrix = _pageViewModel.MatrixVersionList.Find(v => v.DatStartDate == null);
            return nonActiveMatrix != null;
        }

        private async Task<List<VeterinaryDiagnosticInvestigationMatrixReportModel>> LoadMatrixList(long selectedMatrixVersionId)
        {
            try
            {
                var lstInvestigationTypes = await _client.GetInvestigationTypeMatrixListAsync(EIDSSConstants.ReferenceEditorType.InvestigationTypes, null, GetCurrentLanguage());
                var lstSpecies = await _crossCuttingClient.GetSpeciesListAsync(EIDSSConstants.ReferenceEditorType.SpeciesList, (int)AccessoryCodes.LiveStockAndAvian, GetCurrentLanguage());
                var lstDiseases = await _crossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(EIDSSConstants.ReferenceEditorType.Disease, HACodeList.LiveStockAndAvian, GetCurrentLanguage());

                var request = new MatrixGetRequestModel
                {
                    MatrixId = Convert.ToInt64(selectedMatrixVersionId),
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intNumRow",
                    SortOrder = SortConstants.Ascending
                };

                var lstReport = await _client.GetVeterinaryDiagnosticInvestigationMatrixReport(request);

                if (lstReport.Count > 0)
                {
                    // if intNumRow starts with 0, increment all by 1 so that inNumRow starts at 1
                    var r = lstReport.Find(r => r.IntNumRow == 0);
                    if (r != null)
                    {
                        foreach (var report in lstReport)
                        {
                            report.IntNumRow++;
                        }
                    }
                }
                else
                {
                    var matrixDetail = new VeterinaryDiagnosticInvestigationMatrixReportModel
                        {
                            IntNumRow = 1
                        };
                    lstReport.Add(matrixDetail);

                    lstInvestigationTypes.Insert(0, new InvestigationTypeViewModel
                    {
                        StrDefault = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        StrName = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        IdfsBaseReference = 0
                    });

                    lstSpecies.Insert(0, new SpeciesViewModel()
                    {
                        StrDefault = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        StrName = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        IdfsBaseReference = 0
                    });

                    lstDiseases.Insert(0, new VeterinaryDiseaseMatrixListViewModel
                    {
                        StrDefault = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        Name = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        IdfsBaseReference = 0
                    });
                }

                foreach (var report in lstReport)
                {
                    report.InvestigationTypeList = lstInvestigationTypes;
                    report.SpeciesList = lstSpecies;
                    report.DiseaseList = lstDiseases;
                }

                return lstReport;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }      
    }
}
