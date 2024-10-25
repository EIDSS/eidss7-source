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
    public class ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService,  ILogger<ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNController> logger) : 
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byN";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Form #1 (A3)";
        private int[] yearList = Enumerable.Range(2012, 3).ToArray();
        private int[] monthsList2012 = Enumerable.Range(6, 7).ToArray(); 
        private int[] monthsList2014 = Enumerable.Range(1, 11).ToArray();
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

                gisRayonList = await _crossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), 2,false);
           
                var reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel = new ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportMonthNameModels = reportMonthNameList,
                    GisRayonList = gisRayonList,
                    LanguageId = GetCurrentLanguage(),
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                reportYearList = ReportHelper.GetFilteredYearList(reportYearList, yearList, "desc");
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRayonList = new List<GisLocationCurrentLevelModel>();

                gisRayonList = await _crossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), 2, false) ;
                    
                reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.ReportLanguageModels = reportLanguageList;
                reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.ReportYearModels = reportYearList;
                reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.ReportMonthNameModels = reportMonthNameList;
                reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.GisRayonList = gisRayonList;
                reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.ShowIncludeSignature = includeSignaturePermission;
                reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel);
                }
                else
                {
                    reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel.JavascriptToRun = "submitReport();";
                    return View(reportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }


        [HttpPost]
        public IActionResult GenerateReport([FromBody] ReportOnCertainDiseasesConditionsMonthlyFormIV03_01_27byNQueryModel  reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("Month", reportQueryModel.Month);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
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
        public async Task<IActionResult> GetRayonList([FromQuery] string langId)
        {
            var gisRayonList = await _crossCuttingClient.GetGisLocationCurrentLevel(langId, 2,false);
            return Ok(gisRayonList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        [HttpGet]
        public async Task<IActionResult> GetMonthNameList(string langId, string year)
        {
            var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(langId);
            reportMonthNameList = year == "2012" ? ReportHelper.GetFilteredMonthsList(reportMonthNameList, monthsList2012) : (year == "2014" ? ReportHelper.GetFilteredMonthsList(reportMonthNameList, monthsList2014) : reportMonthNameList);
            return Ok(reportMonthNameList);
        }
    }   
}
