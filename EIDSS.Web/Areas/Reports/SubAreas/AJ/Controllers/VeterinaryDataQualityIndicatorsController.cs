using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class VeterinaryDataQualityIndicatorsController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public VeterinaryDataQualityIndicatorsController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService,  ILogger<VeterinaryDataQualityIndicatorsController> logger) : 
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "VeterinaryDataQualityIndicators";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Veterinary Data Quality Indicators";
        public int FromYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public int ToYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public long FromMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));
        public long ToMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));

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
                var organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                var veterinaryDataQualityIndicatorsViewModel = new VeterinaryDataQualityIndicatorsViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportFromYearModels = reportYearList,
                    ReportToYearModels = reportYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    OrganizationList = organiztionList,
                    LanguageId = GetCurrentLanguage(),
                    FromYear = FromYear,
                    ToYear = ToYear,
                    FromMonth = FromMonth,
                    ToMonth = ToMonth,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(veterinaryDataQualityIndicatorsViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(VeterinaryDataQualityIndicatorsViewModel veterinaryDataQualityIndicatorsViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                veterinaryDataQualityIndicatorsViewModel.ReportLanguageModels = reportLanguageList;
                veterinaryDataQualityIndicatorsViewModel.ReportFromYearModels = reportYearList;
                veterinaryDataQualityIndicatorsViewModel.ReportToYearModels = reportYearList;
                veterinaryDataQualityIndicatorsViewModel.ReportFromMonthNameModels = reportMonthNameList;
                veterinaryDataQualityIndicatorsViewModel.ReportToMonthNameModels = reportMonthNameList;
                veterinaryDataQualityIndicatorsViewModel.OrganizationList = organiztionList;
                veterinaryDataQualityIndicatorsViewModel.ShowIncludeSignature = includeSignaturePermission;
                veterinaryDataQualityIndicatorsViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(veterinaryDataQualityIndicatorsViewModel);
                }
                else
                {
                    veterinaryDataQualityIndicatorsViewModel.JavascriptToRun = "submitReport();";
                    return View(veterinaryDataQualityIndicatorsViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] VeterinaryDataQualityIndicatorsQueryModel  reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("FromYear", reportQueryModel.FromYear);
                model.AddParameter("ToYear", reportQueryModel.ToYear);
                model.AddParameter("FromMonth", reportQueryModel.FromMonth);
                model.AddParameter("ToMonth", reportQueryModel.ToMonth);
                model.AddParameter("OrganizationEntered", reportQueryModel.EnterByOrganizationId);
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
        public async Task<IActionResult> GetOrganizationList([FromQuery] string langId)
        {
            var organiztionList = await _crossCuttingClient.GetBaseReferenceList(langId,  BaseReferenceConstants.OrganizationAbbreviation, Convert.ToInt64(AccessoryCodes.LiveStockAndAvian));
            return Ok(organiztionList);
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
