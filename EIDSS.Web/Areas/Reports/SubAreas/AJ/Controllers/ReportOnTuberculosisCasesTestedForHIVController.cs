using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class ReportOnTuberculosisCasesTestedForHIVController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ReportOnTuberculosisCasesTestedForHIVController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<ReportOnTuberculosisCasesTestedForHIVController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "ReportOnTuberculosisCasesTestedForHIV";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Report On Tuberculosis Cases Tested For HIV";
        public string[] Year { get; set; } = { DateTime.Now.ToString("yyyy")};
        public long IdfsReference_FromMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));
        public long IdfsReference_ToMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));

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
                var diagnosisList  = await _reportCrossCuttingClient.GetTuberculosisDiagnosisList(GetCurrentLanguage());
            
                var reportOnTuberculosisCasesTestedForHIVViewModel = new ReportOnTuberculosisCasesTestedForHIVViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    DiagnosisList = diagnosisList,
                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    idfsReference_FromMonth = IdfsReference_FromMonth,
                    idfsReference_ToMonth = IdfsReference_ToMonth,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(reportOnTuberculosisCasesTestedForHIVViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ReportOnTuberculosisCasesTestedForHIVViewModel reportOnTuberculosisCasesTestedForHIVViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var diagnosisList = await _reportCrossCuttingClient.GetTuberculosisDiagnosisList(GetCurrentLanguage());

                reportOnTuberculosisCasesTestedForHIVViewModel.ReportLanguageModels = reportLanguageList;
                reportOnTuberculosisCasesTestedForHIVViewModel.ReportYearModels = reportYearList;
                reportOnTuberculosisCasesTestedForHIVViewModel.ReportFromMonthNameModels = reportMonthNameList;
                reportOnTuberculosisCasesTestedForHIVViewModel.ReportToMonthNameModels = reportMonthNameList;
                reportOnTuberculosisCasesTestedForHIVViewModel.DiagnosisList = diagnosisList;
                reportOnTuberculosisCasesTestedForHIVViewModel.ShowIncludeSignature = includeSignaturePermission;
                reportOnTuberculosisCasesTestedForHIVViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(reportOnTuberculosisCasesTestedForHIVViewModel);
                }
                else
                {
                    reportOnTuberculosisCasesTestedForHIVViewModel.JavascriptToRun = "submitReport();";
                    return View(reportOnTuberculosisCasesTestedForHIVViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ReportOnTuberculosisCasesTestedForHIVQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                foreach (string year in reportQueryModel.Year)
                {
                    model.AddParameter("Year", year);
                }
                model.AddParameter("FromMonth", reportQueryModel.IdfsReference_FromMonth);
                model.AddParameter("ToMonth", reportQueryModel.IdfsReference_ToMonth);
                model.AddParameter("Diagnosis", reportQueryModel.DiagnosisId);
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
        public async Task<IActionResult> GetDiagnosisList([FromQuery] string langId)
        {
            var diagnosisList = await _reportCrossCuttingClient.GetTuberculosisDiagnosisList(langId);
            return Ok(diagnosisList);
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
