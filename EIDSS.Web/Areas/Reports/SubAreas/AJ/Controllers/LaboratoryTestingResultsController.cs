using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Globalization;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [SubArea("AJ")]
    [Controller]
    public class LaboratoryTestingResultsController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IReportCrossCuttingClient _reportCrossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public LaboratoryTestingResultsController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, IReportCrossCuttingClient reportCrossCuttingClient, ITokenService tokenService, ILogger<LaboratoryTestingResultsController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            _reportCrossCuttingClient = reportCrossCuttingClient;
            ReportFileName = "LaboratoryTestingResults";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Laboratory Testing Results";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public long Month { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));

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
                var labTestingResultsDepartmentList = new List<LABTestingResultsDepartmentViewModel>();
            
                var laboratoryTestingResultsViewModel = new LaboratoryTestingResultsViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    LABTestingResultsDepartmentList = labTestingResultsDepartmentList,
                    LanguageId = GetCurrentLanguage(),
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(laboratoryTestingResultsViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(LaboratoryTestingResultsViewModel laboratoryTestingResultsViewModel)
        {
            try
            {
                // model.ReportName = reportName;
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var labTestingResultsDepartmentList = new List<LABTestingResultsDepartmentViewModel>();
                labTestingResultsDepartmentList = await _reportCrossCuttingClient.GetLABTestingResultsDepartmentList(GetCurrentLanguage(), laboratoryTestingResultsViewModel.SampleID);
                
                laboratoryTestingResultsViewModel.ReportLanguageModels = reportLanguageList;
                laboratoryTestingResultsViewModel.SampleID = laboratoryTestingResultsViewModel.SampleID;
                laboratoryTestingResultsViewModel.LABTestingResultsDepartmentList = labTestingResultsDepartmentList;
                laboratoryTestingResultsViewModel.DepartmentID = laboratoryTestingResultsViewModel.DepartmentID;
                laboratoryTestingResultsViewModel.ShowIncludeSignature = includeSignaturePermission;
                laboratoryTestingResultsViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(laboratoryTestingResultsViewModel);
                }
                else
                {
                    laboratoryTestingResultsViewModel.JavascriptToRun = "submitReport();";
                    return View(laboratoryTestingResultsViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] LaboratoryTestingResultsQueryModel reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("SampleID", reportQueryModel.SampleID);
                model.AddParameter("DepartmentID", reportQueryModel.DepartmentID);
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
        public async Task<IActionResult> GetLABTestingResultsDepartmentList([FromQuery] string langId, string sampleId)
        {
            var labTestingResultsDepartmentList = await _reportCrossCuttingClient.GetLABTestingResultsDepartmentList(langId,sampleId);
            return Ok(labTestingResultsDepartmentList);
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        
    }
}
