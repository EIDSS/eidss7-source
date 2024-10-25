using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class HumanCasesByRayonAndDiseaseSummaryController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public HumanCasesByRayonAndDiseaseSummaryController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<HumanCasesByRayonAndDiseaseSummaryController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "HumanCasesByRayonAndDiseaseSummary";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Human Cases by Rayon, Disease Summary Report";
        public string StartIssueDate { get; set; } = DateTime.Now.AddMonths(-1).ToShortDateString();
        public string EndIssueDate { get; set; } = DateTime.Now.ToShortDateString();

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
                var diagnosisList = new List<BaseReferenceViewModel>();

                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                var humanCasesByRayonAndDiseaseSummaryViewModel = new HumanCasesByRayonAndDiseaseSummaryViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    DiagnosisList = diagnosisList,
                    LanguageId = GetCurrentLanguage(),
                    SelectedCultureInfoName = System.Threading.Thread.CurrentThread.CurrentCulture.Name,
                    SelectedUICultureInfoName = System.Threading.Thread.CurrentThread.CurrentCulture.Name,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission,
                };

                return View(humanCasesByRayonAndDiseaseSummaryViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(HumanCasesByRayonAndDiseaseSummaryViewModel humanCasesByRayonAndDiseaseSummaryViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var diagnosisList = new List<BaseReferenceViewModel>();
                
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                humanCasesByRayonAndDiseaseSummaryViewModel.ReportLanguageModels = reportLanguageList;
                humanCasesByRayonAndDiseaseSummaryViewModel.DiagnosisList = diagnosisList;
                humanCasesByRayonAndDiseaseSummaryViewModel.ShowIncludeSignature = includeSignaturePermission;
                humanCasesByRayonAndDiseaseSummaryViewModel.ShowUseArchiveData = archivePermission;


                if (!ModelState.IsValid)
                {
                    return View(humanCasesByRayonAndDiseaseSummaryViewModel);
                }
                else
                {
                    humanCasesByRayonAndDiseaseSummaryViewModel.JavascriptToRun = "submitReport();";
                    return View(humanCasesByRayonAndDiseaseSummaryViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] HumanCasesByRayonAndDiseaseSummaryQueryModel reportQueryModel)
        {
            try
            { 
                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                _ = DateTime.TryParse(reportQueryModel.StartIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime startIssueDate);
                _ = DateTime.TryParse(reportQueryModel.EndIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime endIssueDate);
                Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("StartIssueDate", startIssueDate.ToShortDateString());
                model.AddParameter("EndIssueDate", endIssueDate.ToShortDateString());
                foreach(string disease in reportQueryModel.DiagnosisId)
                {
                    model.AddParameter("DiagnosisID", disease);
                }
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
            var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(diagnosisList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }
    }
}

