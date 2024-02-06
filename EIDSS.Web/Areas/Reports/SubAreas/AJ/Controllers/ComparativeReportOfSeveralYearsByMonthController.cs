using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
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
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class ComparativeReportOfSeveralYearsByMonthController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ComparativeReportOfSeveralYearsByMonthController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<ComparativeReportOfSeveralYearsByMonthController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "ComparativeReportOfSeveralYearsByMonth";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Comparative Report Of Several Years By Month";
        public int FirstYear { get; set; } = Convert.ToInt32(DateTime.Now.AddYears(-1).ToString("yyyy")); 
        public int SecondYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));

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
                var reportFirstYearList = await _crossCuttingClient.GetReportYearList();
                var reportSecondYearList = await _crossCuttingClient.GetReportYearList();
                var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();
           
                //gisRegionList = await _crossCuttingClient.GetGisLocation(LanguageId, 1, null);
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                var comparativeReportOfSeveralYearsByMonthViewModel = new ComparativeReportOfSeveralYearsByMonthViewModel()
                {
                    //Default values assignment
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportFirstYearModels = reportFirstYearList,
                    ReportSecondYearModels = reportSecondYearList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    DiagnosisList = diagnosisList,
                    CounterList = counterList,
                    LanguageId = GetCurrentLanguage(),
                    FirstYear = FirstYear,
                    SecondYear = SecondYear,
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission,
                };

                return View(comparativeReportOfSeveralYearsByMonthViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ComparativeReportOfSeveralYearsByMonthViewModel comparativeReportOfSeveralYearsByMonthViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportFirstYearList = await _crossCuttingClient.GetReportYearList();
                var reportSecondYearList = await _crossCuttingClient.GetReportYearList();
                var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();

                //gisRegionList = await _crossCuttingClient.GetGisLocation(LanguageId, 1, null);
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(comparativeReportOfSeveralYearsByMonthViewModel.RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                comparativeReportOfSeveralYearsByMonthViewModel.ReportLanguageModels = reportLanguageList;
                comparativeReportOfSeveralYearsByMonthViewModel.ReportFirstYearModels = reportFirstYearList;
                comparativeReportOfSeveralYearsByMonthViewModel.ReportSecondYearModels = reportSecondYearList;
                comparativeReportOfSeveralYearsByMonthViewModel.GisRegionList = gisRegionList;
                comparativeReportOfSeveralYearsByMonthViewModel.GisRayonList = gisRayonList;
                comparativeReportOfSeveralYearsByMonthViewModel.DiagnosisList = diagnosisList;
                comparativeReportOfSeveralYearsByMonthViewModel.CounterList = counterList;
                comparativeReportOfSeveralYearsByMonthViewModel.ShowIncludeSignature = includeSignaturePermission;
                comparativeReportOfSeveralYearsByMonthViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(comparativeReportOfSeveralYearsByMonthViewModel);
                }
                else
                {
                    comparativeReportOfSeveralYearsByMonthViewModel.JavascriptToRun = "submitReport();";
                    return View(comparativeReportOfSeveralYearsByMonthViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ComparativeReportOfSeveralYearsByMonthQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("FirstYear", reportQueryModel.FirstYear);
                model.AddParameter("SecondYear", reportQueryModel.SecondYear);
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
                model.AddParameter("Diagnosis", reportQueryModel.DiagnosisId);
                model.AddParameter("Counter", reportQueryModel.CounterId);
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
        public async Task<IActionResult> GetRayonList(string node, string langId)
        {
            var gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(langId, node);
            return Ok(gisRayonList);
        }

        [HttpGet]
        public async Task<IActionResult> GetRegionList([FromQuery] string langId)
        {
            var gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(langId, IdfsCountryId);
            return Ok(gisRegionList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        [HttpGet]
        public async Task<IActionResult> GetDiagnosisList([FromQuery] string langId)
        {
            var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(diagnosisList);
        }

        [HttpGet]
        public async Task<IActionResult> GetCounterList([FromQuery] string langId)
        {
            var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(langId);
            return Ok(counterList);
        }
    }
}
