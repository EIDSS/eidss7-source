using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
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
    public class ComparativeReportOfSeveralYearsByMonthsController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;

        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public ComparativeReportOfSeveralYearsByMonthsController(
            IConfiguration configuration,
            ICrossCuttingClient crossCuttingClient,
            IReportCrossCuttingClient reportCrossCuttingClient,
            ITokenService tokenService,
            ILogger<ComparativeReportOfSeveralYearsByMonthsController> logger)
            : base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "ComparativeReportOfSeveralYearsByMonths";
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
                var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounterGG(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }

                var diagnosisList = await GetDiagnosisListAsync();

                var comparativeReportOfSeveralYearsByMonthsViewModel = new ComparativeReportOfSeveralYearsByMonthsViewModel()
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
                    CounterId = new[] { counterList.FirstOrDefault().ID.ToString() },
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(comparativeReportOfSeveralYearsByMonthsViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(ComparativeReportOfSeveralYearsByMonthsViewModel comparativeReportOfSeveralYearsByMonthsViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportFirstYearList = await _crossCuttingClient.GetReportYearList();
                var reportSecondYearList = await _crossCuttingClient.GetReportYearList();
                reportFirstYearList = ReportHelper.GetFilteredYearList(reportFirstYearList, firstYearList, "desc");
                reportSecondYearList = ReportHelper.GetFilteredYearList(reportSecondYearList, secondYearList, "desc");
                var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounterGG(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(comparativeReportOfSeveralYearsByMonthsViewModel.RegionId));
                }

                var diagnosisList = await GetDiagnosisListAsync();

                comparativeReportOfSeveralYearsByMonthsViewModel.ReportLanguageModels = reportLanguageList;
                comparativeReportOfSeveralYearsByMonthsViewModel.ReportFirstYearModels = reportFirstYearList;
                comparativeReportOfSeveralYearsByMonthsViewModel.ReportSecondYearModels = reportSecondYearList;
                comparativeReportOfSeveralYearsByMonthsViewModel.GisRegionList = gisRegionList;
                comparativeReportOfSeveralYearsByMonthsViewModel.GisRayonList = gisRayonList;
                comparativeReportOfSeveralYearsByMonthsViewModel.DiagnosisList = diagnosisList;
                comparativeReportOfSeveralYearsByMonthsViewModel.CounterList = counterList;
                comparativeReportOfSeveralYearsByMonthsViewModel.ShowIncludeSignature = includeSignaturePermission;
                comparativeReportOfSeveralYearsByMonthsViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(comparativeReportOfSeveralYearsByMonthsViewModel);
                }
                else
                {
                    comparativeReportOfSeveralYearsByMonthsViewModel.JavascriptToRun = "submitReport();";
                    return View(comparativeReportOfSeveralYearsByMonthsViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }


        [HttpPost]
        public IActionResult GenerateReport([FromBody] ComparativeReportOfSeveralYearsByMonthsQueryModel reportQueryModel)
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
                if (reportQueryModel.DiagnosisId.Length == 0)
                    model.AddParameter("Diagnosis", "0"); // Default value
                else
                {
                    foreach (string disease in reportQueryModel.DiagnosisId)
                    {
                        model.AddParameter("Diagnosis", disease);
                    }
                }
                foreach (string counter in reportQueryModel.CounterId)
                {
                    model.AddParameter("Counter", counter);
                }
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
        public async Task<IActionResult> GetCounterList([FromQuery] string langId)
        {
            var counterList = await _reportCrossCuttingClient.GetHumanComparitiveCounterGG(langId);
            return Ok(counterList);
        }

        private async Task<List<FilteredDiseaseGetListViewModel>> GetDiagnosisListAsync()
        {
            var requestDiseases = new FilteredDiseaseRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = HACodeList.HumanHACode,
                UsingType = UsingType.StandardCaseType,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
            };

            return await _crossCuttingClient.GetFilteredDiseaseList(requestDiseases);
        }
    }
}
