using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Web.Areas.Reports.ViewModels;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.Controllers
{
    [Area("Reports")]
    [SubArea("GG")]
    [Controller]
    public class ConcordanceBetweenInitialFinalDiagnosisController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;
        private readonly IStringLocalizer _localizer;

        public ConcordanceBetweenInitialFinalDiagnosisController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<ConcordanceBetweenInitialFinalDiagnosisController> logger, IStringLocalizer localizer) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "ConcordanceBetweenInitialFinalDiagnosis";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
            _localizer = localizer;
        }

        public string ReportName { get; set; } = "Comparative Report On Infectious Diseases By Months";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        private int[] yearList = Enumerable.Range(2000, Convert.ToInt32(DateTime.Now.ToString("yyyy")) - 2000 + 1).ToArray();
        public long Month { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));
 
        protected override string ReportServerUrl
        {
            get
            {
                //You don't want to put the full API path here, just the path to the report server's ReportServer directory that it creates (you should be able to access this path from your browser: https://YourReportServerUrl.com/ReportServer/ReportExecution2005.asmx )
                return _configuration.GetValue<string>("ReportServer:Url");
            }
        }

        public async Task<IActionResult> Index()
        {
            try
            { 
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                reportYearList = ReportHelper.GetFilteredYearList(reportYearList, yearList, "desc");
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var gisSettlementList = new List<GisLocationChildLevelModel>();
                var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }

                if (gisRayonList.Count > 0)
                {
                    gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RayonId));
                }

                var concordanceBetweenInitialFinalDiagnosisViewModel = new ConcordanceBetweenInitialFinalDiagnosisViewModel()
                {
                    //Default values assignment
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportMonthNameModels = reportMonthNameList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    GisSettlementList = gisSettlementList,
                    DiagnosisList = diagnosisList,
                    LanguageId = GetCurrentLanguage(),
                    ConcordanceList = GetNumbersList(0, 100, 1, ""),
                    Year = Year,
                    Month = Month,
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    SettlementId = _tokenService.GetAuthenticatedUser().Settlement,
                    ConcordanceId = "0",
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(concordanceBetweenInitialFinalDiagnosisViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ConcordanceBetweenInitialFinalDiagnosisViewModel concordanceBetweenInitialFinalDiagnosisViewModel)
        {
            try
            {
                if (concordanceBetweenInitialFinalDiagnosisViewModel.InitialDiagnosisId != null && concordanceBetweenInitialFinalDiagnosisViewModel.InitialDiagnosisId.Length > 10)
                {
                    ModelState.AddModelError("InitialDiagnosisId", _localizer.GetString(FieldLabelResourceKeyConstants.InitialDiagnosisValidationFieldLabel));
                }

                if (concordanceBetweenInitialFinalDiagnosisViewModel.FinalDiagnosisId != null && concordanceBetweenInitialFinalDiagnosisViewModel.FinalDiagnosisId.Length > 10)
                {
                    ModelState.AddModelError("FinalDiagnosisId", _localizer.GetString(FieldLabelResourceKeyConstants.FinalDiagnosisValidationFieldLabel));
                }

                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                reportYearList = ReportHelper.GetFilteredYearList(reportYearList, yearList, "desc");
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var gisSettlementList = new List<GisLocationChildLevelModel>();
                var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));


                //gisRegionList = await _crossCuttingClient.GetGisLocation(LanguageId, 1, null);
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(concordanceBetweenInitialFinalDiagnosisViewModel.RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(concordanceBetweenInitialFinalDiagnosisViewModel.RegionId));
                }

                if (gisRayonList.Count > 0)
                {
                    gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(concordanceBetweenInitialFinalDiagnosisViewModel.RayonId));
                }
                concordanceBetweenInitialFinalDiagnosisViewModel.ReportLanguageModels = reportLanguageList;
                concordanceBetweenInitialFinalDiagnosisViewModel.ReportYearModels = reportYearList;
                concordanceBetweenInitialFinalDiagnosisViewModel.ReportMonthNameModels = reportMonthNameList;
                concordanceBetweenInitialFinalDiagnosisViewModel.GisRegionList = gisRegionList;
                concordanceBetweenInitialFinalDiagnosisViewModel.GisRayonList = gisRayonList;
                concordanceBetweenInitialFinalDiagnosisViewModel.GisSettlementList = gisSettlementList;
                concordanceBetweenInitialFinalDiagnosisViewModel.DiagnosisList = diagnosisList;
                concordanceBetweenInitialFinalDiagnosisViewModel.ConcordanceList = GetNumbersList(0, 100, 1, "");
                concordanceBetweenInitialFinalDiagnosisViewModel.ShowIncludeSignature = includeSignaturePermission;
                concordanceBetweenInitialFinalDiagnosisViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(concordanceBetweenInitialFinalDiagnosisViewModel);
                }
                else
                {
                    concordanceBetweenInitialFinalDiagnosisViewModel.JavascriptToRun = "submitReport();";
                    return View(concordanceBetweenInitialFinalDiagnosisViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ConcordanceBetweenInitialFinalDiagnosisQueryModel reportQueryModel)
        {
            try
            {
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("Month", reportQueryModel.Month);
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
                model.AddParameter("SettlementID", reportQueryModel.SettlementId);
                model.AddParameter("Concordance", reportQueryModel.ConcordanceId);
                if (reportQueryModel.InitialDiagnosisId.Length == 0)
                    model.AddParameter("InitialDiagnosis", "0"); // Default value
                else
                {
                    foreach (string disease in reportQueryModel.InitialDiagnosisId)
                    {
                        model.AddParameter("InitialDiagnosis", disease);
                    }
                }
                if (reportQueryModel.FinalDiagnosisId.Length == 0)
                    model.AddParameter("FinalDiagnosis", "0"); // Default value
                else
                {
                    foreach (string disease in reportQueryModel.FinalDiagnosisId)
                    {
                        model.AddParameter("FinalDiagnosis", disease);
                    }
                }
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));
                model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
                model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                model.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);
                model.AddParameter("PrintDateTime", reportQueryModel.PrintDateTime.ToString(new CultureInfo(reportQueryModel.LanguageId)));

                return PartialView("~/Areas/Reports/Views/Shared/_PartialReport.cshtml", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetRayonList(string node, string langId)
        {
            var gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(langId, node);
            return Ok(gisRayonList);
        }

        [HttpGet]
        public async Task<IActionResult> GetRegionList([FromQuery] string langId)
        {
            var gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(langId, IdfsCountryId);
            return Ok(gisRegionList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }



        private List<Age> GetNumbersList(int StartNumber, int EndNumber, int Increment, string lblNoneSelected)
        {
            var numberList = new List<Age>();
            //numberList.Insert(0, new Age { Id = null, Value = lblNoneSelected });
            for (int i = StartNumber; i <= EndNumber; i++)
            {
                var number = new Age();
                number.Value = i.ToString();
                number.Id = i.ToString();
                numberList.Add(number);
            }

            return numberList;
        }

        [HttpGet]
        public async Task<IActionResult> GetMonthNameList([FromQuery] string langId)
        {
            var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(langId);
            return Ok(reportMonthNameList);
        }
    }
}
