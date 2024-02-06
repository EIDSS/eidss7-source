using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;
using EIDSS.Web.ViewModels;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.Controllers
{
    [Area("Reports")]
    [SubArea("GG")]
    [Controller]
    public class IntermediateReportByMonthlyFormIV03_01_27byNController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public IntermediateReportByMonthlyFormIV03_01_27byNController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<IntermediateReportByMonthlyFormIV03_01_27byNController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "IntermediateReportByMonthlyFormIV03_01_27byN";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "60B Journal";
        public string StartIssueDate { get; set; } = "";// DateTime.Now.AddMonths(-1).ToShortDateString();
        public string EndIssueDate { get; set; } = "";// DateTime.Now.ToShortDateString();

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
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);

                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }

                string minimumDateString = "2012-06-01"; 
                string maximumDateString = "2014-11-30"; 
                DateTime minimumIssueDate = DateTime.Parse(minimumDateString);
                DateTime maximumIssueDate = DateTime.Parse(maximumDateString);

                var intermediateReportByMonthlyFormIV03_01_27byNViewModel = new IntermediateReportByMonthlyFormIV03_01_27byNViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    MinimumStartIssueDate = minimumIssueDate.ToShortDateString(),
                    MaximumStartIssueDate = maximumIssueDate.ToShortDateString(),
                    MinimumEndIssueDate = minimumIssueDate.ToShortDateString(),
                    MaximumEndIssueDate = maximumIssueDate.ToShortDateString(),
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    LanguageId = GetCurrentLanguage(),
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(intermediateReportByMonthlyFormIV03_01_27byNViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(IntermediateReportByMonthlyFormIV03_01_27byNViewModel intermediateReportByMonthlyFormIV03_01_27byNViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(intermediateReportByMonthlyFormIV03_01_27byNViewModel.RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(intermediateReportByMonthlyFormIV03_01_27byNViewModel.RegionId));
                }

                intermediateReportByMonthlyFormIV03_01_27byNViewModel.ReportLanguageModels = reportLanguageList;
                intermediateReportByMonthlyFormIV03_01_27byNViewModel.GisRegionList = gisRegionList;
                intermediateReportByMonthlyFormIV03_01_27byNViewModel.GisRayonList = gisRayonList;
                intermediateReportByMonthlyFormIV03_01_27byNViewModel.ShowIncludeSignature = includeSignaturePermission;
                intermediateReportByMonthlyFormIV03_01_27byNViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(intermediateReportByMonthlyFormIV03_01_27byNViewModel);
                }
                else
                {
                    intermediateReportByMonthlyFormIV03_01_27byNViewModel.JavascriptToRun = "submitReport();";
                    return View(intermediateReportByMonthlyFormIV03_01_27byNViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] IntermediateReportByMonthlyFormIV03_01_27byNQueryModel reportQueryModel)
        {
            try
            { 
                //Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                //Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                //_ = DateTime.TryParse(reportQueryModel.StartIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime startIssueDate);
                //_ = DateTime.TryParse(reportQueryModel.EndIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime endIssueDate);
                //Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                //Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("StartIssueDate", reportQueryModel.StartIssueDate.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("EndIssueDate", reportQueryModel.EndIssueDate.ToString(new CultureInfo(reportQueryModel.LanguageId)));
                model.AddParameter("RegionID", reportQueryModel.RegionId);
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
    }
}

