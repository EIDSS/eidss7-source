using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Reports.Controllers
{
    [Area("Reports")]
    [Controller]
    public class AdministrativeReportAuditLogController : EIDSS.Web.Areas.Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public AdministrativeReportAuditLogController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<AdministrativeReportAuditLogController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "AdministrativeReportAuditLog";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string reportName { get; set; } = "Administrative Report Audit Log";
        public string startIssueDate { get; set; } = DateTime.Now.AddMonths(-1).ToShortDateString();
        public string endIssueDate { get; set; } = DateTime.Now.ToShortDateString();
            

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
            var reportsList = await _reportCrossCuttingClient.GetReportList();
  
            var administrativeReportAuditLogViewModel = new AdministrativeReportAuditLogViewModel()
            {
                ReportName = reportName,
                ReportsList = reportsList,
                StartIssueDate = startIssueDate,
                EndIssueDate = endIssueDate,
                LanguageId = GetCurrentLanguage(),
                ShowIncludeSignature = includeSignaturePermission,
                ShowUseArchiveData = archivePermission
            };
            return View(administrativeReportAuditLogViewModel);
        }

        [HttpPost]
        public async Task<IActionResult> Index(AdministrativeReportAuditLogViewModel administrativeReportAuditLogViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportsList = await _reportCrossCuttingClient.GetReportList();

                administrativeReportAuditLogViewModel.ReportName = reportName;
                administrativeReportAuditLogViewModel.ReportsList = reportsList;
                administrativeReportAuditLogViewModel.ShowIncludeSignature = includeSignaturePermission;
                administrativeReportAuditLogViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(administrativeReportAuditLogViewModel);
                }
                else
                {
                    administrativeReportAuditLogViewModel.JavascriptToRun = "submitReport();";
                    return View(administrativeReportAuditLogViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }


        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] AdministrativeReportAuditLogQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("ReportName", reportQueryModel.ReportName);
                model.AddParameter("FromDate", reportQueryModel.StartIssueDate.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("ToDate", reportQueryModel.EndIssueDate.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("FirstName", reportQueryModel.UserFirstName);
                model.AddParameter("MiddleName", reportQueryModel.UserMiddleName);
                model.AddParameter("LastName", reportQueryModel.UserLastName);
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

    }
}

