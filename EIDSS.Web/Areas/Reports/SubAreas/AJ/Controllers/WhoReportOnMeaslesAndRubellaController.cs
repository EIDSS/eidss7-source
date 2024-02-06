using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class WhoReportOnMeaslesAndRubellaController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public WhoReportOnMeaslesAndRubellaController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<WhoReportOnMeaslesAndRubellaController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "WhoReportOnMeaslesAndRubella";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Form #1 (A4)";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
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
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisDiseaseList = new List<WhoMeaslesRubellaDiagnosisViewModel>();

                gisDiseaseList = await _reportCrossCuttingClient.GetHumanWhoMeaslesRubellaDiagnosis();
            
                var whoReportOnMeaslesAndRubellaViewModel = new WhoReportOnMeaslesAndRubellaViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportMonthNameModels = reportMonthNameList,
                    GetHumanWhoMeaslesRubellaDiagnosis = gisDiseaseList,
                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    Month = Month,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(whoReportOnMeaslesAndRubellaViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(WhoReportOnMeaslesAndRubellaViewModel whoReportOnMeaslesAndRubellaViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisDiseaseList = new List<WhoMeaslesRubellaDiagnosisViewModel>();

                gisDiseaseList = await _reportCrossCuttingClient.GetHumanWhoMeaslesRubellaDiagnosis();

                whoReportOnMeaslesAndRubellaViewModel.ReportLanguageModels = reportLanguageList;
                whoReportOnMeaslesAndRubellaViewModel.ReportYearModels = reportYearList;
                whoReportOnMeaslesAndRubellaViewModel.ReportMonthNameModels = reportMonthNameList;
                whoReportOnMeaslesAndRubellaViewModel.GetHumanWhoMeaslesRubellaDiagnosis = gisDiseaseList;
                whoReportOnMeaslesAndRubellaViewModel.ShowIncludeSignature = includeSignaturePermission;
                whoReportOnMeaslesAndRubellaViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(whoReportOnMeaslesAndRubellaViewModel);
                }
                else
                {
                    whoReportOnMeaslesAndRubellaViewModel.JavascriptToRun = "submitReport();";
                    return View(whoReportOnMeaslesAndRubellaViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] WhoReportOnMeaslesAndRubellaQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("Month", reportQueryModel.Month);
                model.AddParameter("Diagnosis", reportQueryModel.DiseaseId);
                model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
                model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                model.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);
                model.AddParameter("PrintDateTime", reportQueryModel.PrintDateTime.ToString(new CultureInfo("en-US")));

                return PartialView("~/Areas/Reports/Views/Shared/_PartialReport.cshtml", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetHumanWhoMeaslesRubellaDiagnosis([FromQuery] string langId)
        {
            var gisDiseaseList = await _reportCrossCuttingClient.GetHumanWhoMeaslesRubellaDiagnosis();
            return Ok(gisDiseaseList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        [HttpGet]
        public async Task<IActionResult> GetMonthNameList([FromQuery] string langId)
        {
            var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(langId);
            return Ok(reportMonthNameList);
        }
    }
}
