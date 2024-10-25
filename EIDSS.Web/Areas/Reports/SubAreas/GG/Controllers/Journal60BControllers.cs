using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;
using EIDSS.Web.ViewModels;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.Controllers
{
    [Area("Reports")]
    [SubArea("GG")]
    [Controller]
    public class Journal60BController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public Journal60BController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<Journal60BController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "Journal60B";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "60B Journal";
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
                
                //string minimumDateString = "2016-01-01";
                //string maximumDateString = "2100-12-31";
                //DateTime minimumIssueDate = DateTime.Parse(minimumDateString);
                //DateTime maximumIssueDate = DateTime.Parse(maximumDateString);

                var journal60BViewModel = new Journal60BViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    //MinimumStartIssueDate = minimumIssueDate.ToShortDateString(),
                    //MaximumStartIssueDate = maximumIssueDate.ToShortDateString(),
                    //MinimumEndIssueDate = minimumIssueDate.ToShortDateString(),
                    //MaximumEndIssueDate = maximumIssueDate.ToShortDateString(),
                    DiagnosisList = diagnosisList,
                    LanguageId = GetCurrentLanguage(),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(journal60BViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(Journal60BViewModel journal60BViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var diagnosisList = new List<BaseReferenceViewModel>();

                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                journal60BViewModel.ReportLanguageModels = reportLanguageList;
                journal60BViewModel.DiagnosisList = diagnosisList;
                journal60BViewModel.ShowIncludeSignature = includeSignaturePermission;
                journal60BViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(journal60BViewModel);
                }
                else
                {
                    journal60BViewModel.JavascriptToRun = "submitReport();";
                    return View(journal60BViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] Journal60BQueryModel reportQueryModel)
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
                model.AddParameter("Diagnosis", string.IsNullOrEmpty(reportQueryModel.DiagnosisId) ? "0" : reportQueryModel.DiagnosisId);
                model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
                model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                model.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);
                model.AddParameter("PrintDateTime", reportQueryModel.PrintDateTime.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("SiteID", authenticatedUser.SiteId);


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

