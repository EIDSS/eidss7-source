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
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class SummaryVeterinaryController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public SummaryVeterinaryController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<SummaryVeterinaryController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "SummaryVeterinaryReport";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Summary Veterinary Report";

        public string StartIssueDate { get; set; } = DateTime.Now.AddMonths(-1).ToShortDateString();
        public string EndIssueDate { get; set; } = DateTime.Now.ToShortDateString();
        public string SurveillanceTypeId { get; set; }

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
                var diagnosisList = new List<BaseReferenceViewModel>();
                var nameOfInvestigationOrMeasureList = await _reportCrossCuttingClient.GetVetNameOfInvestigationOrMeasure(GetCurrentLanguage());
                var speciesTypeList = new List<SpeciesTypeViewModel>();
                var vetSummarySurveillanceTypes = await _reportCrossCuttingClient.GetVetSummarySurveillanceType(GetCurrentLanguage());

 
                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.LiveStockAndAvian));

                if (diagnosisList.Count > 0)
                {
                    speciesTypeList = await _reportCrossCuttingClient.GetSpeciesTypes(GetCurrentLanguage(), diagnosisList.FirstOrDefault().IdfsBaseReference);
                }

                var summaryVeterinaryViewModel = new SummaryVeterinaryViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    StartIssueDate = StartIssueDate,
                    EndIssueDate = EndIssueDate,
                    NameOfInvestigationOrMeasureList = nameOfInvestigationOrMeasureList,
                    VetSummarySurveillanceTypes = vetSummarySurveillanceTypes,
                    DiagnosisList = diagnosisList,
                    SpeciesTypeList = speciesTypeList,
                    SurveillanceTypeId = SurveillanceTypeId,
                    LanguageId = GetCurrentLanguage(),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(summaryVeterinaryViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(SummaryVeterinaryViewModel summaryVeterinaryViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var diagnosisList = new List<BaseReferenceViewModel>();
                var nameOfInvestigationOrMeasureList = await _reportCrossCuttingClient.GetVetNameOfInvestigationOrMeasure(GetCurrentLanguage());
                var speciesTypeList = new List<SpeciesTypeViewModel>();
                var vetSummarySurveillanceTypes = await _reportCrossCuttingClient.GetVetSummarySurveillanceType(GetCurrentLanguage());


                diagnosisList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.LiveStockAndAvian));

                if (diagnosisList.Count > 0)
                {
                    speciesTypeList = await _reportCrossCuttingClient.GetSpeciesTypes(GetCurrentLanguage(), Convert.ToInt64(summaryVeterinaryViewModel.DiagnosisId));
                }

                summaryVeterinaryViewModel.ReportLanguageModels = reportLanguageList;
                summaryVeterinaryViewModel.NameOfInvestigationOrMeasureList = nameOfInvestigationOrMeasureList;
                summaryVeterinaryViewModel.VetSummarySurveillanceTypes = vetSummarySurveillanceTypes;
                summaryVeterinaryViewModel.DiagnosisList = diagnosisList;
                summaryVeterinaryViewModel.SpeciesTypeList = speciesTypeList;
                summaryVeterinaryViewModel.ShowIncludeSignature = includeSignaturePermission;
                summaryVeterinaryViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(summaryVeterinaryViewModel);
                }
                else
                {
                    summaryVeterinaryViewModel.JavascriptToRun = "submitReport();";
                    return View(summaryVeterinaryViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] SummaryVeterinaryQueryModel reportQueryModel)
        {
            try
            { 
                Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
                _ = DateTime.TryParse(reportQueryModel.StartIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime startIssueDate);
                _ = DateTime.TryParse(reportQueryModel.EndIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime endIssueDate);
                Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("StartIssueDate", startIssueDate.ToShortDateString());
                model.AddParameter("EndIssueDate", endIssueDate.ToShortDateString());
                model.AddParameter("SurveillanceType", reportQueryModel.SurveillanceTypeId);
                model.AddParameter("InvestigationOrMeasureType", reportQueryModel.NameOfInvestigationOrMeasureId);
                model.AddParameter("Diagnosis", reportQueryModel.DiagnosisId);
                foreach (string speciesType in reportQueryModel.SpeciesTypeId)
                {
                    model.AddParameter("SpeciesType", speciesType);
                }
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
            var diagnosisList = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.Disease, Convert.ToInt64(AccessoryCodes.LiveStockAndAvian));
            return Ok(diagnosisList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        [HttpGet]
        public async Task<IActionResult> GetVetNameOfInvestigationOrMeasure([FromQuery] string langId)
        {
            var nameOfInvestigationOrMeasure = await _reportCrossCuttingClient.GetVetNameOfInvestigationOrMeasure(langId);
            return Ok(nameOfInvestigationOrMeasure);
        }

        [HttpGet]
        public async Task<IActionResult> GetVetSummarySurveillanceType([FromQuery] string langId)
        {
            var vetSummarySurveillanceTypes = await _reportCrossCuttingClient.GetVetSummarySurveillanceType(langId);
            return Ok(vetSummarySurveillanceTypes);
        }


        [HttpGet]
        public async Task<IActionResult> GetSpeciesTypes(string langId, long node)
        {
            var speciesTypes = await _reportCrossCuttingClient.GetSpeciesTypes(langId, node);
            return Ok(speciesTypes);
        }
    }
}
