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
    public class ReportOnCasesOfAnnualFormIV03Controller : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ReportOnCasesOfAnnualFormIV03Controller(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService,  ILogger<ReportOnCasesOfAnnualFormIV03Controller> logger) : 
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "ReportOnCasesOfAnnualFormIV03";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Form #1 (A3)";
        private int[] yearList = Enumerable.Range(2005, 8).ToArray();

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
                var gisRayonList = new List<GisLocationCurrentLevelModel>();

                gisRayonList = await _crossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), 2,false);
           
                var reportOnCasesOfAnnualFormIV03ViewModel = new ReportOnCasesOfAnnualFormIV03ViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    GisRayonList = gisRayonList,
                    LanguageId = GetCurrentLanguage(),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(reportOnCasesOfAnnualFormIV03ViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ReportOnCasesOfAnnualFormIV03ViewModel reportOnCasesOfAnnualFormIV03ViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                reportYearList = ReportHelper.GetFilteredYearList(reportYearList, yearList, "desc");
                var gisRayonList = new List<GisLocationCurrentLevelModel>();
 
                gisRayonList = await _crossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), 2,false);
                    
                reportOnCasesOfAnnualFormIV03ViewModel.ReportLanguageModels = reportLanguageList;
                reportOnCasesOfAnnualFormIV03ViewModel.ReportYearModels = reportYearList;
                reportOnCasesOfAnnualFormIV03ViewModel.GisRayonList = gisRayonList;
                reportOnCasesOfAnnualFormIV03ViewModel.ShowIncludeSignature = includeSignaturePermission;
                reportOnCasesOfAnnualFormIV03ViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(reportOnCasesOfAnnualFormIV03ViewModel);
                }
                else
                {
                    reportOnCasesOfAnnualFormIV03ViewModel.JavascriptToRun = "submitReport();";
                    return View(reportOnCasesOfAnnualFormIV03ViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ReportOnCasesOfAnnualFormIV03QueryModel  reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
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
    }   
}
