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
    public class RBEQuarterlySurveillanceSheetController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public RBEQuarterlySurveillanceSheetController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<RBEQuarterlySurveillanceSheetController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "RBEQuarterlySurveillanceSheet";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Comparative Report Of Several Years By Month";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        private int[] yearList = Enumerable.Range(2000, Convert.ToInt32(DateTime.Now.ToString("yyyy")) - 2000 + 1).ToArray();
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
                var quarterList = await _reportCrossCuttingClient.GetReportQuarterGG(GetCurrentLanguage(),Year);
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();
           
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (!string.IsNullOrEmpty(Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                var rBEQuarterlySurveillanceSheetViewModel = new RBEQuarterlySurveillanceSheetViewModel()
                {
                    //Default values assignment
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    QuarterList = quarterList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,

                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    QuarterId = new[] { quarterList.FirstOrDefault().ID.ToString()},
                    RegionId = new[] { _tokenService.GetAuthenticatedUser().RegionId.ToString()},
                    RayonId = new[] { _tokenService.GetAuthenticatedUser().RayonId.ToString()},
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(rBEQuarterlySurveillanceSheetViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(RBEQuarterlySurveillanceSheetViewModel rBEQuarterlySurveillanceSheetViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                reportYearList = ReportHelper.GetFilteredYearList(reportYearList, yearList, "desc");
                var quarterList = await _reportCrossCuttingClient.GetReportQuarterGG(GetCurrentLanguage(), rBEQuarterlySurveillanceSheetViewModel.Year);
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var diagnosisList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (!string.IsNullOrEmpty(String.Join(",", rBEQuarterlySurveillanceSheetViewModel.RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(String.Join(",", rBEQuarterlySurveillanceSheetViewModel.RegionId)));
                }
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));

                rBEQuarterlySurveillanceSheetViewModel.ReportLanguageModels = reportLanguageList;
                rBEQuarterlySurveillanceSheetViewModel.ReportYearModels = reportYearList;
                rBEQuarterlySurveillanceSheetViewModel.QuarterList = quarterList;
                rBEQuarterlySurveillanceSheetViewModel.GisRegionList = gisRegionList;
                rBEQuarterlySurveillanceSheetViewModel.GisRayonList = gisRayonList;
                rBEQuarterlySurveillanceSheetViewModel.ShowIncludeSignature = includeSignaturePermission;
                rBEQuarterlySurveillanceSheetViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(rBEQuarterlySurveillanceSheetViewModel);
                }
                else
                {
                    rBEQuarterlySurveillanceSheetViewModel.JavascriptToRun = "submitReport();";
                    return View(rBEQuarterlySurveillanceSheetViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] RBEQuarterlySurveillanceSheetQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                foreach (string quarter in reportQueryModel.QuarterId)
                {
                    model.AddParameter("ReportingPeriod", quarter);
                }
                foreach (string region in reportQueryModel.RegionId)
                {
                    model.AddParameter("RegionID", region);
                }
                foreach (string rayon in reportQueryModel.RayonId)
                {
                    model.AddParameter("RayonID", rayon);
                }
                model.AddParameter("idfPerson", Convert.ToString(authenticatedUser.PersonId));
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
        public async Task<IActionResult> GetQuarterList(string langId,string year)
        {
            var quarterList = await _reportCrossCuttingClient.GetReportQuarterGG(langId, Convert.ToInt32(year));
            return Ok(quarterList);
        }
    }
}
