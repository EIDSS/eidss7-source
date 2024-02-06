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
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class ComparativeReportController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ComparativeReportController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<ComparativeReportController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "ComparativeReport";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Comparative Report";
        public int FirstYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public int SecondYear { get; set; } = Convert.ToInt32(DateTime.Now.AddYears(-1).ToString("yyyy"));
        public long IdfsReference_FromMonth { get; set; } = 1;
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
                var reportFirstYearList = await _crossCuttingClient.GetReportYearList();
                var reportSecondYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var humanComparitiveCounterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(GetCurrentLanguage());
                var gisRegion1List = new List<GisLocationChildLevelModel>();
                var gisRayon1List = new List<GisLocationChildLevelModel>();
                var gisRegion2List = new List<GisLocationChildLevelModel>();
                var gisRayon2List = new List<GisLocationChildLevelModel>();
                var organiztionList = new List<BaseReferenceViewModel>();

                //Region 1
                gisRegion1List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegion1List.Count > 0)
                {
                    if (!string.IsNullOrEmpty(Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId)))
                        gisRayon1List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
                //Region 2
                gisRegion2List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegion2List.Count > 0)
                {
                    gisRayon2List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegion2List.FirstOrDefault().idfsReference));
                }
                organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                var comparativeReportViewModel = new ComparativeReportViewModel()
                {
                    //default values assignment
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportFirstYearModels = reportFirstYearList,
                    ReportSecondYearModels = reportSecondYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    HumanComparitiveCounterList = humanComparitiveCounterList,
                    GisRegion1List = gisRegion1List,
                    GisRayon1List = gisRayon1List,
                    GisRegion2List = gisRegion2List,
                    GisRayon2List = gisRayon2List,
                    OrganizationList = organiztionList,
                    LanguageId = GetCurrentLanguage(),
                    FirstYear = FirstYear,
                    SecondYear = SecondYear,
                    idfsReference_FromMonth = IdfsReference_FromMonth,
                    idfsReference_ToMonth = IdfsReference_ToMonth,
                    Region1Id = _tokenService.GetAuthenticatedUser().RegionId,
                    Rayon1Id = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(comparativeReportViewModel);
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ComparativeReportViewModel comparativeReportViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportFirstYearList = await _crossCuttingClient.GetReportYearList();
                var reportSecondYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var humanComparitiveCounterList = await _reportCrossCuttingClient.GetHumanComparitiveCounter(GetCurrentLanguage());
                var gisRegion1List = new List<GisLocationChildLevelModel>();
                var gisRayon1List = new List<GisLocationChildLevelModel>();
                var gisRegion2List = new List<GisLocationChildLevelModel>();
                var gisRayon2List = new List<GisLocationChildLevelModel>();
                var organiztionList = new List<BaseReferenceViewModel>();

                //Region 1
                gisRegion1List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegion1List.Count > 0)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(comparativeReportViewModel.Region1Id)))
                        gisRayon1List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegion1List.FirstOrDefault().idfsReference));
                    else
                        gisRayon1List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(comparativeReportViewModel.Region1Id));
                }
                //Region 2
                gisRegion2List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegion2List.Count > 0)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(comparativeReportViewModel.Region2Id)))
                        gisRayon2List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegion2List.FirstOrDefault().idfsReference));
                    else
                        gisRayon2List = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(comparativeReportViewModel.Region2Id));
                }
                organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                comparativeReportViewModel.ReportLanguageModels = reportLanguageList;
                comparativeReportViewModel.ReportFirstYearModels = reportFirstYearList;
                comparativeReportViewModel.ReportSecondYearModels = reportSecondYearList;
                comparativeReportViewModel.ReportFromMonthNameModels = reportMonthNameList;
                comparativeReportViewModel.ReportToMonthNameModels = reportMonthNameList;
                comparativeReportViewModel.HumanComparitiveCounterList = humanComparitiveCounterList;
                comparativeReportViewModel.GisRegion1List = gisRegion1List;
                comparativeReportViewModel.GisRayon1List = gisRayon1List;
                comparativeReportViewModel.GisRegion2List = gisRegion2List;
                comparativeReportViewModel.GisRayon2List = gisRayon2List;
                comparativeReportViewModel.OrganizationList = organiztionList;
                comparativeReportViewModel.ShowIncludeSignature = includeSignaturePermission;
                comparativeReportViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(comparativeReportViewModel);
                }
                else
                {
                    comparativeReportViewModel.JavascriptToRun = "submitReport();";
                    return View(comparativeReportViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ComparativeReportQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("FirstYear", reportQueryModel.FirstYear);
                model.AddParameter("SecondYear", reportQueryModel.SecondYear);
                model.AddParameter("StartMonth", reportQueryModel.idfsReference_FromMonth);
                model.AddParameter("EndMonth", reportQueryModel.idfsReference_ToMonth);
                model.AddParameter("FirstRegionID", reportQueryModel.Region1Id);
                model.AddParameter("FirstRayonID", reportQueryModel.Rayon1Id);
                model.AddParameter("Counter", reportQueryModel.CounterId);
                model.AddParameter("OrganizationID", reportQueryModel.EnterByOrganizationId);
                model.AddParameter("SecondRegionID", reportQueryModel.Region2Id);
                model.AddParameter("SecondRayonID", reportQueryModel.Rayon2Id);
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
        public async Task<IActionResult> GetRayon1List(string node, string langId)
        {
            var gisRayon1List = await _crossCuttingClient.GetGisLocationChildLevel(langId, node);
            return Ok(gisRayon1List);
        }

        [HttpGet]
        public async Task<IActionResult> GetRegion1List([FromQuery] string langId)
        {
            var gisRegion1List = await _crossCuttingClient.GetGisLocationChildLevel(langId, IdfsCountryId);
            return Ok(gisRegion1List);
        }

        [HttpGet]
        public async Task<IActionResult> GetRayon2List(string node, string langId)
        {
            var gisRayon2List = await _crossCuttingClient.GetGisLocationChildLevel(langId, node);
            return Ok(gisRayon2List);
        }

        [HttpGet]
        public async Task<IActionResult> GetRegion2List([FromQuery] string langId)
        {
            var gisRegion2List = await _crossCuttingClient.GetGisLocationChildLevel(langId, IdfsCountryId);
            return Ok(gisRegion2List);
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
        public async Task<IActionResult> GetHumanComparitiveCounter([FromQuery] string langId)
        {
            var humanComparitiveCounter = await _reportCrossCuttingClient.GetHumanComparitiveCounter(langId);
            return Ok(humanComparitiveCounter);
        }
    }
}
