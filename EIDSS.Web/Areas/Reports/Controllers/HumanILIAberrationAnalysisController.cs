using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Reports.Controllers
{
    [Area("Reports")]
    [Controller]
    public class HumanILIAberrationAnalysisController : ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        private string NoneSelected = ""; //"(None Selected)";
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public HumanILIAberrationAnalysisController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<HumanILIAberrationAnalysisController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "HumanILIAberrationAnalysis";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Human ILI Aberration Analysis";
        public string StartIssueDate { get; set; } = "";
        public string EndIssueDate { get; set; } = "";

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
                var thresholdList = GetDecimalsList(0.5, 4.0, 0.1, NoneSelected);
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var ageGroupList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.BasicSyndromicSurveillanceAggregateColumns, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var organizationList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.StatisticalPeriodType, 0);

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
            
                var humanILIAberrationAnalysisViewModel = new HumanILIAberrationAnalysisViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    AgeGroupList = ageGroupList,
                    OrganizationList = organizationList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    ThresholdList = thresholdList,
                    TimeUnitList = timeUnitList,
                    BaselineList = GetNumbersList(2, 1000, 1, NoneSelected),
                    LagList = GetNumbersList(1, 99, 1, NoneSelected),
                    LanguageId = GetCurrentLanguage(),
                    ThresholdId="2.5",
                    TimeUnitId = "10091004",
                    BaselineId="4",
                    LagId="1",
                    RegionId = _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(humanILIAberrationAnalysisViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(HumanILIAberrationAnalysisViewModel humanILIAberrationAnalysisViewModel)
        {
            try
            {
                var thresholdList = GetDecimalsList(0.5, 4.0, 0.1, NoneSelected);
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(humanILIAberrationAnalysisViewModel.LanguageId);
                var ageGroupList = await _crossCuttingClient.GetBaseReferenceList(humanILIAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.BasicSyndromicSurveillanceAggregateColumns, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var organizationList = await _crossCuttingClient.GetBaseReferenceList(humanILIAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(humanILIAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.StatisticalPeriodType, 0);

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(humanILIAberrationAnalysisViewModel.LanguageId, IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(humanILIAberrationAnalysisViewModel.LanguageId, Convert.ToString(humanILIAberrationAnalysisViewModel.RegionId));
                }


                humanILIAberrationAnalysisViewModel.ReportName = ReportName;
                humanILIAberrationAnalysisViewModel.ReportLanguageModels = reportLanguageList;
                humanILIAberrationAnalysisViewModel.AgeGroupList = ageGroupList;
                humanILIAberrationAnalysisViewModel.OrganizationList = organizationList;
                humanILIAberrationAnalysisViewModel.GisRegionList = gisRegionList;
                humanILIAberrationAnalysisViewModel.GisRayonList = gisRayonList;
                humanILIAberrationAnalysisViewModel.ThresholdList = thresholdList;
                humanILIAberrationAnalysisViewModel.TimeUnitList = timeUnitList;
                humanILIAberrationAnalysisViewModel.BaselineList = GetNumbersList(2, 1000, 1, NoneSelected);
                humanILIAberrationAnalysisViewModel.LagList = GetNumbersList(1, 99, 1, NoneSelected);
                humanILIAberrationAnalysisViewModel.RegionId = _tokenService.GetAuthenticatedUser().RegionId;
                humanILIAberrationAnalysisViewModel.RayonId = _tokenService.GetAuthenticatedUser().RayonId;
                humanILIAberrationAnalysisViewModel.ShowIncludeSignature = includeSignaturePermission;
                humanILIAberrationAnalysisViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(humanILIAberrationAnalysisViewModel);
                }
                else
                {
                    humanILIAberrationAnalysisViewModel.JavascriptToRun = "submitReport();";
                    return View(humanILIAberrationAnalysisViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public async Task<IActionResult> ChangeLanguage([FromBody] HumanILIAberrationAnalysisQueryModel reportQueryModel)
        {
            try
            {
                var thresholdList = GetDecimalsList(0.5, 4.0, 0.1, NoneSelected);
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(reportQueryModel.LanguageId);
                var ageGroupList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.BasicSyndromicSurveillanceAggregateColumns, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var organizationList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.StatisticalPeriodType, 0);

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (string.IsNullOrEmpty(reportQueryModel.RegionId))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, reportQueryModel.RegionId);
                }

                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                _ = DateTime.TryParse(reportQueryModel.StartIssueDate, out DateTime startIssueDate);
                _ = DateTime.TryParse(reportQueryModel.EndIssueDate, out DateTime endIssueDate);
                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.LanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.LanguageId);

                var humanILIAberrationAnalysisViewModel = new HumanILIAberrationAnalysisViewModel()
                {
                    IncludeSignature = Convert.ToBoolean(reportQueryModel.IncludeSignature),
                    ReportName = reportQueryModel.ReportName,
                    ReportLanguageModels = reportLanguageList,
                    AgeGroupList = ageGroupList,
                    OrganizationList = organizationList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    ThresholdList = thresholdList,
                    TimeUnitList = timeUnitList,
                    BaselineList = GetNumbersList(2, 1000, 1, NoneSelected),
                    LagList = GetNumbersList(1, 99, 1, NoneSelected),
                    LanguageId = reportQueryModel.LanguageId,
                    PriorLanguageId = reportQueryModel.LanguageId,
                    AgeGroupId = reportQueryModel.AgeGroupId,
                    AnalysisMethodId = reportQueryModel.AnalysisMethodId,
                    StartIssueDate = startIssueDate.ToShortDateString(),
                    EndIssueDate = endIssueDate.ToShortDateString(),
                    ThresholdId = reportQueryModel.ThresholdId,
                    TimeUnitId = reportQueryModel.TimeUnitId,
                    BaselineId = reportQueryModel.BaselineId,
                    LagId = reportQueryModel.LagId,
                    OrganizationId = reportQueryModel.OrganizationId,
                    RegionId = string.IsNullOrEmpty(reportQueryModel.RegionId) ? null : Convert.ToInt64(reportQueryModel.RegionId),
                    RayonId = string.IsNullOrEmpty(reportQueryModel.RayonId) ? null : Convert.ToInt64(reportQueryModel.RayonId),
                    UseArchiveData = Convert.ToBoolean(reportQueryModel.UseArchiveData),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View("Index", humanILIAberrationAnalysisViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] HumanILIAberrationAnalysisQueryModel reportQueryModel)
        {

            ReportViewModel model = new();
            model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";

            model.AddParameter("LangID", reportQueryModel.LanguageId);
            if (!string.IsNullOrEmpty(reportQueryModel.StartIssueDate))
                model.AddParameter("SD",Convert.ToDateTime(reportQueryModel.StartIssueDate).ToString("d", new CultureInfo(reportQueryModel.LanguageId)));
            if (!string.IsNullOrEmpty(reportQueryModel.EndIssueDate))
                model.AddParameter("ED", Convert.ToDateTime(reportQueryModel.EndIssueDate).ToString("d", new CultureInfo(reportQueryModel.LanguageId)));
            model.AddParameter("GroupAge", reportQueryModel.AgeGroupId);
            model.AddParameter("Hospital", reportQueryModel.OrganizationId);
            model.AddParameter("RegionID", reportQueryModel.RegionId);
            model.AddParameter("RayonID", reportQueryModel.RayonId);
            model.AddParameter("AnalysisMethod", reportQueryModel.AnalysisMethodId);
            model.AddParameter("Threshold", reportQueryModel.ThresholdId);
            model.AddParameter("MinTimeInterval", reportQueryModel.TimeUnitId);
            model.AddParameter("Baseline", reportQueryModel.BaselineId);
            model.AddParameter("Lag", reportQueryModel.LagId);
            model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));
            model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
            model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
            model.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);
            model.AddParameter("PrintDateTime", reportQueryModel.PrintDateTime.ToString(new CultureInfo(reportQueryModel.LanguageId)));

            return PartialView("~/Areas/Reports/Views/Shared/_PartialReport.cshtml", model);
        }


        [HttpGet]
        public async Task<IActionResult> GetAgeGroupList([FromQuery] string langId)
        {
            var ageGroupList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.BasicSyndromicSurveillanceAggregateColumns, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(ageGroupList);
        }

        
        [HttpGet]
        public async Task<IActionResult> GetOrganizationList([FromQuery] string langId)
        {
            var organizationList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(organizationList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        [HttpGet]
        public async Task<IActionResult> GetRegionList([FromQuery] string langId)
        {
            var gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(langId, IdfsCountryId);
            return Ok(gisRegionList);
        }

        [HttpGet]
        public async Task<IActionResult> GetRayonList(string node, string langId)
        {
            var gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(langId, node);
            return Ok(gisRayonList);
        }
 
        private List<Age> GetNumbersList(int StartNumber, int EndNumber,int Increment,string lblNoneSelected)
        {
            var ageList = new List<Age>();
            ageList.Insert(0, new Age { Id = null, Value = lblNoneSelected });
            for (int i = StartNumber; i <= EndNumber; i++)
            {
                var age = new Age();
                age.Value = i.ToString();
                age.Id = i.ToString();
                ageList.Add(age);
            }

            return ageList;
        }

        [HttpGet]
        public IActionResult GetThresholdList()
        {
            var thresholdList = GetDecimalsList(0.5, 4.0, 0.1, NoneSelected);

            return Ok(thresholdList);
        }

        public List<Age> GetDecimalsList(double StartNumber, double EndNumber, double Increment, string lblNoneSelected)
        {
            Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
            Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

            var thresholdList = new List<Age>();
            thresholdList.Insert(0, new Age { Id = null, Value = lblNoneSelected });
            for (double i = StartNumber; i <= EndNumber; i += Increment)
            {
                var threshold = new Age();
                threshold.Value = i.ToString("0.#");
                threshold.Id = i.ToString("0.#");
                thresholdList.Add(threshold);
            }

            return thresholdList;
        }

        [HttpGet]
        public async Task<IActionResult> GetTimeUnitList([FromQuery] string langId)
        {
            var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.StatisticalPeriodType, 0);
            return Ok(timeUnitList);
        }

        [HttpGet]
        public IActionResult GetBaselineList()
        {
            var baselineList = GetNumbersList(2, 10000, 1, NoneSelected);

            return Ok(baselineList);
        }

        [HttpGet]
        public IActionResult GetLagList()
        {
            var lagList = GetNumbersList(1, 99, 1, NoneSelected);

            return Ok(lagList);
        }
    }
}

