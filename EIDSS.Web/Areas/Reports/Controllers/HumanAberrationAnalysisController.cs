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

    public class MyModel
    {
        public string JavascriptToRun { get; set; }
    }

    [Area("Reports")]
    [Controller]
    public class HumanAberrationAnalysisController : ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        private string NoneSelected = ""; //"(None Selected)";
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public HumanAberrationAnalysisController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<HumanAberrationAnalysisController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "HumanAberrationAnalysis";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Human Aberration Analysis";
        public string StartIssueDate { get; set; } = "";//DateTime.Now.ToString("MM/dd/yyyy");
        public string EndIssueDate { get; set; } = "";// DateTime.Now.ToString("MM/dd/yyyy");

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
                var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var reportTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseReportType, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var dateFieldSourceList = await _reportCrossCuttingClient.GetHumDateFieldSourceList(GetCurrentLanguage());
                var caseClassificationList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseClassification, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var organizationList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var gisSettlementList = new List<GisLocationChildLevelModel>();
                var genderList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.HumanGender, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.StatisticalPeriodType, 0);
                var analysisMethos = new List<AnalysisMethod>();
                analysisMethos.Add(new AnalysisMethod { Id = "1", Value = "CUSUM" });

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }

                if (gisRayonList.Count > 0)
                {
                    gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RayonId));
                }

                var humanAberrationAnalysisViewModel = new HumanAberrationAnalysisViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    DiagnosisList = diagnosisList,
                    ReportTypeList = reportTypeList,
                    CaseClassificationList = caseClassificationList,
                    OrganizationList = organizationList,
                    DateFieldSourceList = dateFieldSourceList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    GisSettlementList = gisSettlementList,
                    GenderList = genderList,
                    AnalysisMethods=analysisMethos,
                    AgeFromList = GetNumbersList(1, 100, 1, NoneSelected),
                    AgeToList = GetNumbersList(1, 120, 1, NoneSelected),
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
                    SettlementId = _tokenService.GetAuthenticatedUser().Settlement,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(humanAberrationAnalysisViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index( HumanAberrationAnalysisViewModel humanAberrationAnalysisViewModel)
        {
            try
            {
                var thresholdList = GetDecimalsList(0.5, 4.0, 0.1, NoneSelected);
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(humanAberrationAnalysisViewModel.LanguageId);
                var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(humanAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var reportTypeList = await _crossCuttingClient.GetBaseReferenceList(humanAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.CaseReportType, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var dateFieldSourceList = await _reportCrossCuttingClient.GetHumDateFieldSourceList(humanAberrationAnalysisViewModel.LanguageId);
                var caseClassificationList = await _crossCuttingClient.GetBaseReferenceList(humanAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.CaseClassification, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var organizationList = await _crossCuttingClient.GetBaseReferenceList(humanAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var gisSettlementList = new List<GisLocationChildLevelModel>();
                var genderList = await _crossCuttingClient.GetBaseReferenceList(humanAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.HumanGender, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(humanAberrationAnalysisViewModel.LanguageId, BaseReferenceConstants.StatisticalPeriodType, 0);
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(humanAberrationAnalysisViewModel.LanguageId, IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(humanAberrationAnalysisViewModel.LanguageId, Convert.ToString(humanAberrationAnalysisViewModel.RegionId));
                }

                if (gisRayonList.Count > 0)
                {
                    gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(humanAberrationAnalysisViewModel.LanguageId, Convert.ToString(humanAberrationAnalysisViewModel.RayonId));
                }
                var analysisMethos = new List<AnalysisMethod>();
                analysisMethos.Add(new AnalysisMethod { Id = "1", Value = "CUSUM" });
                humanAberrationAnalysisViewModel.ReportLanguageModels = reportLanguageList;
                humanAberrationAnalysisViewModel.DiagnosisList = diagnosisList;
                humanAberrationAnalysisViewModel.ReportTypeList = reportTypeList;
                humanAberrationAnalysisViewModel.CaseClassificationList = caseClassificationList;
                humanAberrationAnalysisViewModel.OrganizationList = organizationList;
                humanAberrationAnalysisViewModel.DateFieldSourceList = dateFieldSourceList;
                humanAberrationAnalysisViewModel.GisRegionList = gisRegionList;
                humanAberrationAnalysisViewModel.GisRayonList = gisRayonList;
                humanAberrationAnalysisViewModel.GisSettlementList = gisSettlementList;
                humanAberrationAnalysisViewModel.GenderList = genderList;
                humanAberrationAnalysisViewModel.AnalysisMethods = analysisMethos;
                humanAberrationAnalysisViewModel.AgeFromList = GetNumbersList(1, 100, 1, NoneSelected);
                humanAberrationAnalysisViewModel.AgeToList = GetNumbersList(1, 120, 1, NoneSelected);
                humanAberrationAnalysisViewModel.ThresholdList = thresholdList;
                humanAberrationAnalysisViewModel.TimeUnitList = timeUnitList;
                humanAberrationAnalysisViewModel.BaselineList = GetNumbersList(2, 1000, 1, NoneSelected);
                humanAberrationAnalysisViewModel.LagList = GetNumbersList(1, 99, 1, NoneSelected);
                humanAberrationAnalysisViewModel.ShowIncludeSignature = includeSignaturePermission;
                humanAberrationAnalysisViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(humanAberrationAnalysisViewModel);
                }
                else
                {
                    humanAberrationAnalysisViewModel.JavascriptToRun = "submitReport();";
                    return View (humanAberrationAnalysisViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

         
        }

        [HttpPost]
        public async Task<IActionResult> ChangeLanguage([FromBody] HumanAberrationAnalysisQueryModel reportQueryModel)
        {
            try
            {
                var thresholdList = GetDecimalsList(0.5, 4.0, 0.1, NoneSelected);
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(reportQueryModel.LanguageId);
                var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var reportTypeList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.CaseReportType, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var dateFieldSourceList = await _reportCrossCuttingClient.GetHumDateFieldSourceList(reportQueryModel.LanguageId);
                var caseClassificationList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.CaseClassification, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var organizationList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var gisSettlementList = new List<GisLocationChildLevelModel>();
                var genderList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.HumanGender, Convert.ToInt64(AccessoryCodes.HumanHACode));
                var timeUnitList = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.StatisticalPeriodType, 0);
                var analysisMethos = new List<AnalysisMethod> { new AnalysisMethod { Id = "1", Value = "CUSUM" }};

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    if (string.IsNullOrEmpty(reportQueryModel.RegionId))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, reportQueryModel.RegionId);
                }

                if (gisRayonList.Count > 0)
                {
                    if (string.IsNullOrEmpty(reportQueryModel.RayonId))
                        gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, Convert.ToString(gisRayonList.FirstOrDefault().idfsReference));
                    else
                        gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(reportQueryModel.LanguageId, reportQueryModel.RayonId);
                }

                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                _ = DateTime.TryParse(reportQueryModel.StartIssueDate, out DateTime startIssueDate);
                _ = DateTime.TryParse(reportQueryModel.EndIssueDate, out DateTime endIssueDate);
                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.LanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.LanguageId);

                var humanAberrationAnalysisViewModel = new HumanAberrationAnalysisViewModel()
                {
                    IncludeSignature = Convert.ToBoolean(reportQueryModel.IncludeSignature),
                    ReportName = reportQueryModel.ReportName,
                    ReportLanguageModels = reportLanguageList,
                    DiagnosisList = diagnosisList,
                    ReportTypeList = reportTypeList,
                    CaseClassificationList = caseClassificationList,
                    OrganizationList = organizationList,
                    DateFieldSourceList = dateFieldSourceList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    GisSettlementList = gisSettlementList,
                    GenderList = genderList,
                    AnalysisMethods = analysisMethos,
                    AgeFromList = GetNumbersList(1, 100, 1, NoneSelected),
                    AgeToList = GetNumbersList(1, 120, 1, NoneSelected),
                    ThresholdList = thresholdList,
                    TimeUnitList = timeUnitList,
                    BaselineList = GetNumbersList(2, 1000, 1, NoneSelected),
                    LagList = GetNumbersList(1, 99, 1, NoneSelected),
                    LanguageId = reportQueryModel.LanguageId,
                    PriorLanguageId = reportQueryModel.LanguageId,
                    AnalysisMethodId = reportQueryModel.AnalysisMethodId,
                    DateFieldSourceId = reportQueryModel.DateFieldSourceId.Length == 0 ? null : reportQueryModel.DateFieldSourceId, //TODO: is this multi-select?, then model needs to be adjusted.
                    DiagnosisId = reportQueryModel.DiagnosisId.Length == 0 ? null : reportQueryModel.DiagnosisId,
                    CaseClassificationId = reportQueryModel.CaseClassificationId.Length == 0 ? null : reportQueryModel.CaseClassificationId,//reportQueryModel.CaseClassificationId[0], //TODO: is this multi-select?, then model needs to be adjusted.
                    StartIssueDate = startIssueDate.ToShortDateString(),
                    EndIssueDate = endIssueDate.ToShortDateString(),
                    GenderId = reportQueryModel.GenderId,
                    AgeFromId = reportQueryModel.AgeFromId,
                    AgeToId = reportQueryModel.AgeToId,
                    ThresholdId = reportQueryModel.ThresholdId,
                    TimeUnitId = reportQueryModel.TimeUnitId,
                    BaselineId = reportQueryModel.BaselineId,
                    LagId = reportQueryModel.LagId,
                    OrganizationId = reportQueryModel.OrganizationId,
                    ReportTypeId = reportQueryModel.ReportTypeId,
                    RegionId = string.IsNullOrEmpty(reportQueryModel.RegionId) ? null : Convert.ToInt64(reportQueryModel.RegionId),
                    RayonId = string.IsNullOrEmpty(reportQueryModel.RayonId) ? null : Convert.ToInt64(reportQueryModel.RayonId),
                    SettlementId = string.IsNullOrEmpty(reportQueryModel.SettlementId) ? null : Convert.ToInt64(reportQueryModel.SettlementId),
                    UseArchiveData = Convert.ToBoolean(reportQueryModel.UseArchiveData),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View("Index", humanAberrationAnalysisViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] HumanAberrationAnalysisQueryModel reportQueryModel)
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

                //model.AddParameter("DiagnosisUsingType", "10020001");
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                if (!string.IsNullOrEmpty(reportQueryModel.StartIssueDate))
                    model.AddParameter("SD", Convert.ToDateTime(reportQueryModel.StartIssueDate).ToString("d", new CultureInfo(reportQueryModel.LanguageId)));
                if (!string.IsNullOrEmpty(reportQueryModel.EndIssueDate))
                    model.AddParameter("ED", Convert.ToDateTime(reportQueryModel.EndIssueDate).ToString("d", new CultureInfo(reportQueryModel.LanguageId)));
                foreach (string disease in reportQueryModel.DiagnosisId)
                {
                    model.AddParameter("Diagnosis", disease);
                }
                model.AddParameter("ReportType", reportQueryModel.ReportTypeId);
                foreach (string source in reportQueryModel.DateFieldSourceId)
                {
                    model.AddParameter("DateOptions", source);
                }
                foreach (string caseClassification in reportQueryModel.CaseClassificationId)
                {
                    model.AddParameter("idfsCaseClassification", caseClassification);
                }
                model.AddParameter("OrganizationID", reportQueryModel.OrganizationId);
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
                model.AddParameter("SettlementID", reportQueryModel.SettlementId);
                model.AddParameter("Gender", reportQueryModel.GenderId);
                model.AddParameter("StartAge", string.IsNullOrEmpty(reportQueryModel.AgeFromId) ? "0" : reportQueryModel.AgeFromId);
                model.AddParameter("FinishAge", string.IsNullOrEmpty(reportQueryModel.AgeToId) ? "0" : reportQueryModel.AgeToId);
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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetDiagnosisList([FromQuery] string langId)
        {
            var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(diagnosisList);
        }

        [HttpGet]
        public async Task<IActionResult> GetReportTypeList([FromQuery] string langId)
        {
            var reportTypeList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.CaseReportType, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(reportTypeList);
        }

        [HttpGet]
        public async Task<IActionResult> GetHumDateFieldSourceList([FromQuery] string langId)
        {
            var dateFieldSourceList = await _reportCrossCuttingClient.GetHumDateFieldSourceList(langId);
            return Ok(dateFieldSourceList);
        }

        [HttpGet]
        public async Task<IActionResult> GetCaseClassificationList([FromQuery] string langId)
        {
            var caseClassificationList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.CaseClassification, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(caseClassificationList);
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

        [HttpGet]
        public async Task<IActionResult> GisSettlementList(string node, string langId)
        {
            var gisSettlementList = await _crossCuttingClient.GetGisLocationChildLevel(langId, node);
            return Ok(gisSettlementList);
        }

        [HttpGet]
        public async Task<IActionResult> GetGenderList([FromQuery] string langId)
        {
            var genderList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.HumanGender, Convert.ToInt64(AccessoryCodes.HumanHACode));
            return Ok(genderList);
        }

        [HttpGet]
        public  IActionResult GetAgeFromList()
        {
            var ageFromList = GetNumbersList(1, 100, 1, NoneSelected);
            return Ok(ageFromList);
        }

        [HttpGet]
        public IActionResult GetAgeToList()
        {
            var ageToList = GetNumbersList(1, 120, 1, NoneSelected);
            
            return Ok(ageToList);
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

