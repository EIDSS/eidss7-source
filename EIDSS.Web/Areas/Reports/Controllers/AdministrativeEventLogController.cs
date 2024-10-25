using EIDSS.ClientLibrary.ApiClients.CrossCutting;
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

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [Controller]
    public class AdministrativeEventLogController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public AdministrativeEventLogController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<AdministrativeEventLogController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "AdministrativeEventLog";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Administrative Event Log";
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
  
                var administrativeEventLogViewModel = new AdministrativeEventLogViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    LanguageId = GetCurrentLanguage(),
                    PriorLanguageId = GetCurrentLanguage(),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(administrativeEventLogViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(AdministrativeEventLogViewModel administrativeEventLogViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(administrativeEventLogViewModel.LanguageId);

                administrativeEventLogViewModel.ReportName = ReportName;
                administrativeEventLogViewModel.ReportLanguageModels = reportLanguageList;
                administrativeEventLogViewModel.ShowIncludeSignature = includeSignaturePermission;
                administrativeEventLogViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(administrativeEventLogViewModel);
                }
                else
                {
                    administrativeEventLogViewModel.JavascriptToRun = "submitReport();";
                    return View(administrativeEventLogViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }


        }

        [HttpPost]
        public async Task<IActionResult> ChangeLanguage([FromBody] AdministrativeEventLogQueryModel reportQueryModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(reportQueryModel.LanguageId);

                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                _ = DateTime.TryParse(reportQueryModel.StartIssueDate, out DateTime startIssueDate);
                _ = DateTime.TryParse(reportQueryModel.EndIssueDate, out DateTime endIssueDate);
                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.LanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.LanguageId);

                var administrativeEventLogViewModel = new AdministrativeEventLogViewModel()
                {
                    IncludeSignature = Convert.ToBoolean(reportQueryModel.IncludeSignature),
                    ReportName = reportQueryModel.ReportName,
                    ReportLanguageModels = reportLanguageList,
                    LanguageId = reportQueryModel.LanguageId,
                    PriorLanguageId = reportQueryModel.LanguageId,
                    StartIssueDate = startIssueDate.ToShortDateString(),
                    EndIssueDate = endIssueDate.ToShortDateString(),
                    UseArchiveData = Convert.ToBoolean(reportQueryModel.UseArchiveData),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View("Index", administrativeEventLogViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] AdministrativeEventLogQueryModel reportQueryModel)
        {
            try
            {
                //Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                //Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                //_ = DateTime.TryParse(reportQueryModel.StartIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime startIssueDate);
                //_ = DateTime.TryParse(reportQueryModel.EndIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime endIssueDate);
                //Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                //Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("StartIssueDate", reportQueryModel.StartIssueDate.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("EndIssueDate", reportQueryModel.EndIssueDate.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));
                model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
                model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                model.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);
                model.AddParameter("PrintDateTime", reportQueryModel.PrintDateTime.ToString(new CultureInfo(reportQueryModel.LanguageId)));

                return PartialView("~/Areas/Reports/Views/Shared/_PartialReport.cshtml", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }
    }
}

