using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Globalization;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.Controllers
{
    [Area("Reports")]
    [SubArea("GG")]
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
            ReportFileName = "WhoReport";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Who Report";
        public string DateFrom { get; set; } = "";// DateTime.Now.AddMonths(-1).ToShortDateString();
        public string DateTo { get; set; } = "";// DateTime.Now.ToShortDateString();

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
                var gisDiseaseList = new List<WhoMeaslesRubellaDiagnosisViewModel>();

                gisDiseaseList = await _reportCrossCuttingClient.GetHumanWhoMeaslesRubellaDiagnosis();
                var whoReportOnMeaslesAndRubellaViewModel = new WhoReportOnMeaslesAndRubellaViewModel()
                {
                    ReportName = ReportName,                   
                    LanguageId = "en-US",
                    DateFrom = DateFrom,
                    DateTo = DateTo,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };
                if (gisDiseaseList != null)
                {
                    whoReportOnMeaslesAndRubellaViewModel.GetHumanWhoMeaslesRubellaDiagnosis = gisDiseaseList.Where(x => x.idfsDiagnosis > 0).ToList();  
                }
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
                var gisDiseaseList = new List<WhoMeaslesRubellaDiagnosisViewModel>();

                gisDiseaseList = await _reportCrossCuttingClient.GetHumanWhoMeaslesRubellaDiagnosis();

                //whoReportOnMeaslesAndRubellaViewModel.ReportLanguageModels = reportLanguageList;
                whoReportOnMeaslesAndRubellaViewModel.GetHumanWhoMeaslesRubellaDiagnosis = gisDiseaseList;
                whoReportOnMeaslesAndRubellaViewModel.ShowIncludeSignature = includeSignaturePermission;
                whoReportOnMeaslesAndRubellaViewModel.ShowUseArchiveData = archivePermission;
                whoReportOnMeaslesAndRubellaViewModel.LanguageId = "en-US";
                whoReportOnMeaslesAndRubellaViewModel.PriorLanguageId = "en-US";

                if (ModelState != null)
                {
                    var skipped = ModelState.Keys.Where(key => key.StartsWith("LanguageId"));
                    foreach (var key in skipped)
                        ModelState.Remove(key);
                    
                }

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
                model.AddParameter("LangID", "en-US");
                model.AddParameter("StartDate", reportQueryModel.DateFrom);
                model.AddParameter("EndDate", reportQueryModel.DateTo);
                model.AddParameter("Diagnosis", reportQueryModel.DiseaseId);
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
        public async Task<IActionResult> GetHumanWhoMeaslesRubellaDiagnosis([FromQuery] string langId)
        {
            var gisDiseaseList = await _reportCrossCuttingClient.GetHumanWhoMeaslesRubellaDiagnosis();
            gisDiseaseList= gisDiseaseList.Where(x => x.idfsDiagnosis>0).ToList(); 
            return Ok(gisDiseaseList);
        }
    }
}
