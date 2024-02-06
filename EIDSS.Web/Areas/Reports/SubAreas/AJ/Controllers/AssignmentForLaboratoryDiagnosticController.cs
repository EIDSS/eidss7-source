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

namespace EIDSS.Web.Areas.Reports.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class AssignmentForLaboratoryDiagnosticController : ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public AssignmentForLaboratoryDiagnosticController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<AssignmentForLaboratoryDiagnosticController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "AssignmentForLaboratoryDiagnostic";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Assignment For Laboratory Diagnostic";
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
                var sendToList = new List<LABAssignmentDiagnosticAZSendToViewModel>();

            
                var assignmentForLaboratoryDiagnosticViewModel = new AssignmentForLaboratoryDiagnosticViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    LABAssignmentDiagnosticAZSendToList = sendToList,
                    LanguageId = GetCurrentLanguage(),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };
                return View(assignmentForLaboratoryDiagnosticViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(AssignmentForLaboratoryDiagnosticViewModel assignmentForLaboratoryDiagnosticViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var sendToList = new List<LABAssignmentDiagnosticAZSendToViewModel>();

                sendToList = await _reportCrossCuttingClient.GetLABAssignmentDiagnosticAZSendToList(GetCurrentLanguage(), assignmentForLaboratoryDiagnosticViewModel.CaseId);

                assignmentForLaboratoryDiagnosticViewModel.ReportLanguageModels = reportLanguageList;
                assignmentForLaboratoryDiagnosticViewModel.LABAssignmentDiagnosticAZSendToList = sendToList;
                assignmentForLaboratoryDiagnosticViewModel.ShowIncludeSignature = includeSignaturePermission;
                assignmentForLaboratoryDiagnosticViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(assignmentForLaboratoryDiagnosticViewModel);
                }
                else
                {
                    assignmentForLaboratoryDiagnosticViewModel.JavascriptToRun = "submitReport();";
                    return View(assignmentForLaboratoryDiagnosticViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] AssignmentForLaboratoryDiagnosticQueryModel reportQueryModel)
        {
            try 
            {
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("CaseID", reportQueryModel.CaseId);
                model.AddParameter("SentToID", reportQueryModel.SentTo);
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
        public async Task<IActionResult> GetLABAssignmentDiagnosticAZSendToList([FromQuery] string langId, string caseId)
        {
            var sendToList = await _reportCrossCuttingClient.GetLABAssignmentDiagnosticAZSendToList(langId,caseId);
            return Ok(sendToList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        
    }
}
