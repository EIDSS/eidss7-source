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
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class ZoonoticComparativeReportController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ZoonoticComparativeReportController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<ZoonoticComparativeReportController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "ZoonoticComparativeReport";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Zoonotic Comparative Report";
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
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
            
                var zoonoticComparativeReportViewModel = new ZoonoticComparativeReportViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    DiagnosisList = diagnosisList,
                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(zoonoticComparativeReportViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ZoonoticComparativeReportViewModel zoonoticComparativeReportViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(zoonoticComparativeReportViewModel.RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                zoonoticComparativeReportViewModel.ReportLanguageModels = reportLanguageList;
                zoonoticComparativeReportViewModel.ReportYearModels = reportYearList;
                zoonoticComparativeReportViewModel.GisRegionList = gisRegionList;
                zoonoticComparativeReportViewModel.GisRayonList = gisRayonList;
                zoonoticComparativeReportViewModel.DiagnosisList = diagnosisList;
                zoonoticComparativeReportViewModel.ShowIncludeSignature = includeSignaturePermission;
                zoonoticComparativeReportViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(zoonoticComparativeReportViewModel);
                }
                else
                {
                    zoonoticComparativeReportViewModel.JavascriptToRun = "submitReport();";
                    return View(zoonoticComparativeReportViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ZoonoticComparativeReportQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
                model.AddParameter("Diagnosis", reportQueryModel.DiagnosisId);
                model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
                model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                model.AddParameter("UserOrganization", string.IsNullOrEmpty(authenticatedUser.OrganizationFullName) ? "" : authenticatedUser.OrganizationFullName);
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
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
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
        public async Task<IActionResult> GetDiagnosisList([FromQuery] string langId)
        {
            var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(diagnosisList);
        }

    }
}
