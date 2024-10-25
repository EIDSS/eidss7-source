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
    public class ComparativeReportOnInfectiousDiseasesByMonthsController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ComparativeReportOnInfectiousDiseasesByMonthsController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<ComparativeReportOnInfectiousDiseasesByMonthsController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "ComparativeReportOnInfectiousDiseasesByMonths";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Comparative Report On Infectious Diseases By Months";
        public int FirstYear { get; set; } = Convert.ToInt32(DateTime.Now.AddYears(-1).ToString("yyyy"));
        public int SecondYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public long IdfsReference_FromMonth { get; set; } = 1;
        public long IdfsReference_ToMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));
        private int[] firstYearList = Enumerable.Range(2012, Convert.ToInt32(DateTime.Now.AddYears(-1).ToString("yyyy")) - 2012 + 1).ToArray();
        private int[] secondYearList = Enumerable.Range(2013, Convert.ToInt32(DateTime.Now.ToString("yyyy")) - 2013 + 1).ToArray();

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
                reportFirstYearList = ReportHelper.GetFilteredYearList(reportFirstYearList, firstYearList, "desc");
                reportSecondYearList = ReportHelper.GetFilteredYearList(reportSecondYearList, secondYearList, "desc");
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
            
                var comparativeReportOnInfectiousDiseasesByMonthsViewModel = new ComparativeReportOnInfectiousDiseasesByMonthsViewModel()
                {
                    //Default values assignment
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportFirstYearModels = reportFirstYearList,
                    ReportSecondYearModels = reportSecondYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    LanguageId = GetCurrentLanguage(),
                    FirstYear = FirstYear,
                    SecondYear = SecondYear,
                    idfsReference_FromMonth = IdfsReference_FromMonth,
                    idfsReference_ToMonth = IdfsReference_ToMonth,
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(comparativeReportOnInfectiousDiseasesByMonthsViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ComparativeReportOnInfectiousDiseasesByMonthsViewModel comparativeReportOnInfectiousDiseasesByMonthsViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportFirstYearList = await _crossCuttingClient.GetReportYearList();
                var reportSecondYearList = await _crossCuttingClient.GetReportYearList();
                reportFirstYearList = ReportHelper.GetFilteredYearList(reportFirstYearList, firstYearList, "desc");
                reportSecondYearList = ReportHelper.GetFilteredYearList(reportSecondYearList, secondYearList, "desc");
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();

                //gisRegionList = await _crossCuttingClient.GetGisLocation(LanguageId, 1, null);
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(comparativeReportOnInfectiousDiseasesByMonthsViewModel.RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(comparativeReportOnInfectiousDiseasesByMonthsViewModel.RegionId));
                }

                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ReportLanguageModels = reportLanguageList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ReportFirstYearModels = reportFirstYearList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ReportSecondYearModels = reportSecondYearList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ReportFromMonthNameModels = reportMonthNameList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ReportToMonthNameModels = reportMonthNameList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.GisRegionList = gisRegionList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.GisRayonList = gisRayonList;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ShowIncludeSignature = includeSignaturePermission;
                comparativeReportOnInfectiousDiseasesByMonthsViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(comparativeReportOnInfectiousDiseasesByMonthsViewModel);
                }
                else
                {
                    comparativeReportOnInfectiousDiseasesByMonthsViewModel.JavascriptToRun = "submitReport();";
                    return View(comparativeReportOnInfectiousDiseasesByMonthsViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] ComparativeReportOnInfectiousDiseasesByMonthsQueryModel reportQueryModel)
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
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
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
        public async Task<IActionResult> GetMonthNameList([FromQuery] string langId)
        {
            var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(langId);
            return Ok(reportMonthNameList);
        }
    }
}
