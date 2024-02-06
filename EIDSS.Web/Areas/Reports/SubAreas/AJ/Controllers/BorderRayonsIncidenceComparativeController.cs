using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class BorderRayonsIncidenceComparativeController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public BorderRayonsIncidenceComparativeController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<BorderRayonsIncidenceComparativeController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "BorderRayonsIncidenceComparativeReport";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Border Rayons Incidence Comparative Report";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public long IdfsReference_FromMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));
        public long IdfsReference_ToMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));

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
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var counterList = new List<HumanComparitiveCounterViewModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
                counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(GetCurrentLanguage());

                var borderRayonsIncidenceComparativeViewModel = new BorderRayonsIncidenceComparativeViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    DiagnosisList = diagnosisList,
                    CounterList = counterList,
                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    idfsReference_FromMonth = IdfsReference_FromMonth,
                    idfsReference_ToMonth = IdfsReference_ToMonth,
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };
                return View(borderRayonsIncidenceComparativeViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(BorderRayonsIncidenceComparativeViewModel borderRayonsIncidenceComparativeViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var counterList = new List<HumanComparitiveCounterViewModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(borderRayonsIncidenceComparativeViewModel.RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(borderRayonsIncidenceComparativeViewModel.RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
                counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(GetCurrentLanguage());

                borderRayonsIncidenceComparativeViewModel.ReportLanguageModels = reportLanguageList;
                borderRayonsIncidenceComparativeViewModel.ReportYearModels = reportYearList;
                borderRayonsIncidenceComparativeViewModel.ReportFromMonthNameModels = reportMonthNameList;
                borderRayonsIncidenceComparativeViewModel.ReportToMonthNameModels = reportMonthNameList;
                borderRayonsIncidenceComparativeViewModel.GisRegionList = gisRegionList;
                borderRayonsIncidenceComparativeViewModel.GisRayonList = gisRayonList;
                borderRayonsIncidenceComparativeViewModel.DiagnosisList = diagnosisList;
                borderRayonsIncidenceComparativeViewModel.CounterList = counterList;
                borderRayonsIncidenceComparativeViewModel.ShowIncludeSignature = includeSignaturePermission;
                borderRayonsIncidenceComparativeViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(borderRayonsIncidenceComparativeViewModel);
                }
                else
                {
                    borderRayonsIncidenceComparativeViewModel.JavascriptToRun = "submitReport();";
                    return View(borderRayonsIncidenceComparativeViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] BorderRayonsIncidenceComparativeQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("FromMonth", reportQueryModel.IdfsReference_FromMonth);
                model.AddParameter("ToMonth", reportQueryModel.IdfsReference_ToMonth);
                if (reportQueryModel.DiagnosisId.Length == 0)
                    model.AddParameter("Diagnosis", "0");
                else
                {
                    foreach (string disease in reportQueryModel.DiagnosisId)
                    {
                        model.AddParameter("Diagnosis", disease);
                    }
                }
                model.AddParameter("Counter", reportQueryModel.CounterId);
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
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

        [HttpGet]
        public async Task<IActionResult> GetMonthNameList([FromQuery] string langId)
        {
            var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(langId);
            return Ok(reportMonthNameList);
        }

        [HttpGet]
        public async Task<IActionResult> GetCounterList([FromQuery] string langId)
        {
            var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(langId);
            return Ok(counterList);
        }
    }
}
