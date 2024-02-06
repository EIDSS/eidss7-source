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
using System.Linq;
using System.Threading.Tasks;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class MainIndicatorsOfAFPsurveillanceController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public MainIndicatorsOfAFPsurveillanceController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient,ITokenService tokenService, ILogger<MainIndicatorsOfAFPsurveillanceController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "MainIndicatorsOfAFPsurveillance";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Main Indicators Of AFP surveillance";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        
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
                var reportingPeriodTypeList = await _reportCrossCuttingClient.GetReportPeriodType(GetCurrentLanguage());
                var reportingPeriodList = new List<ReportingPeriodViewModel>();

                var mainIndicatorsOfAFPsurveillanceViewModel = new MainIndicatorsOfAFPsurveillanceViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportingPeriodTypeList = reportingPeriodTypeList,
                    ReportingPeriodList = reportingPeriodList,
                    LanguageId = GetCurrentLanguage(),
                    Year = reportYearList.Count > 0 ? Convert.ToInt32(reportYearList.FirstOrDefault().Year) : Convert.ToInt32(DateTime.Now.ToString("yyyy")),
                    ReportingPeriodTypeId = reportingPeriodTypeList.Count > 0 ? reportingPeriodTypeList.FirstOrDefault().StrValue : String.Empty,
                    ReportingPeriodId = reportingPeriodList.Count > 0 ? reportingPeriodList.FirstOrDefault().ID : String.Empty,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(mainIndicatorsOfAFPsurveillanceViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(MainIndicatorsOfAFPsurveillanceViewModel mainIndicatorsOfAFPsurveillanceViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportingPeriodTypeList = await _reportCrossCuttingClient.GetReportPeriodType(GetCurrentLanguage());
                var reportingPeriodList = new List<ReportingPeriodViewModel>();

                reportingPeriodList = await _reportCrossCuttingClient.GetReportPeriod(GetCurrentLanguage(), Convert.ToString(mainIndicatorsOfAFPsurveillanceViewModel.Year), mainIndicatorsOfAFPsurveillanceViewModel.ReportingPeriodTypeId);

                mainIndicatorsOfAFPsurveillanceViewModel.ReportLanguageModels = reportLanguageList;
                mainIndicatorsOfAFPsurveillanceViewModel.ReportYearModels = reportYearList;
                mainIndicatorsOfAFPsurveillanceViewModel.ReportingPeriodTypeList = reportingPeriodTypeList;
                mainIndicatorsOfAFPsurveillanceViewModel.ReportingPeriodList = reportingPeriodList;
                mainIndicatorsOfAFPsurveillanceViewModel.ShowIncludeSignature = includeSignaturePermission;
                mainIndicatorsOfAFPsurveillanceViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(mainIndicatorsOfAFPsurveillanceViewModel);
                }
                else
                {
                    mainIndicatorsOfAFPsurveillanceViewModel.JavascriptToRun = "submitReport();";
                    return View(mainIndicatorsOfAFPsurveillanceViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] MainIndicatorsOfAFPsurveillanceQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("ReportingPeriodType", reportQueryModel.ReportingPeriodTypeId);
                model.AddParameter("ReportingPeriod", (reportQueryModel.ReportingPeriodTypeId =="Year" ? reportQueryModel.Year: reportQueryModel.ReportingPeriodId));
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
        public async Task<IActionResult> ReportingPeriodList(string langId, int year, string reportPeriodType)
        {

            var reportingPeriodList = await _reportCrossCuttingClient.GetReportPeriod(langId, Convert.ToString(year), reportPeriodType);
            return Ok(reportingPeriodList);
        }

        [HttpGet]
        public async Task<IActionResult> ReportingPeriodTypeList([FromQuery] string langId)
        {
            var reportingPeriodTypeList = await _reportCrossCuttingClient.GetReportPeriodType(langId);
            return Ok(reportingPeriodTypeList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }
    }
}
