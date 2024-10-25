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

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.Controllers
{
    [Area("Reports")]
    [SubArea("GG")]
    [Controller]
    public class HumanMonthlyMorbidityMortalityController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public HumanMonthlyMorbidityMortalityController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService,  ILogger<HumanMonthlyMorbidityMortalityController> logger) : 
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "HumanMonthlyMorbidityMortality";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Form #1 (A3)";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        private int[] yearList = Enumerable.Range(2000, Convert.ToInt32(DateTime.Now.ToString("yyyy")) - 2000+1).ToArray();
        //public long Month { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));

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
                var gisRayonList = new List<GisLocationCurrentLevelModel>();

                gisRayonList = await _crossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), 3,false);
           
                var humanMonthlyMorbidityMortalityViewModel = new HumanMonthlyMorbidityMortalityViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportMonthNameModels = reportMonthNameList,
                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    //Month= Month,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(humanMonthlyMorbidityMortalityViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(HumanMonthlyMorbidityMortalityViewModel humanMonthlyMorbidityMortalityViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                reportYearList = ReportHelper.GetFilteredYearList(reportYearList, yearList, "desc");
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                    
                humanMonthlyMorbidityMortalityViewModel.ReportLanguageModels = reportLanguageList;
                humanMonthlyMorbidityMortalityViewModel.ReportYearModels = reportYearList;
                humanMonthlyMorbidityMortalityViewModel.ReportMonthNameModels = reportMonthNameList;
                humanMonthlyMorbidityMortalityViewModel.ShowIncludeSignature = includeSignaturePermission;
                humanMonthlyMorbidityMortalityViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(humanMonthlyMorbidityMortalityViewModel);
                }
                else
                {
                    humanMonthlyMorbidityMortalityViewModel.JavascriptToRun = "submitReport();";
                    return View(humanMonthlyMorbidityMortalityViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] HumanMonthlyMorbidityMortalityQueryModel  reportQueryModel)
        {
            try { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("Month", string.IsNullOrEmpty(reportQueryModel.Month) ? "0": reportQueryModel.Month);
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
