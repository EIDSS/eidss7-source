using EIDSS.ClientLibrary.ApiClients.CrossCutting;
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
    public class VeterinaryCaseReportController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public VeterinaryCaseReportController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService,  ILogger<VeterinaryCaseReportController> logger) : 
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "VeterinaryCaseReport";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Veterinary Report Form Vet 1";
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
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var organiztionList = new List<BaseReferenceViewModel>();

                //gisRegionList = await _crossCuttingClient.GetGisLocation(LanguageId, 1, null);
                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }
                organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                var veterinaryCaseReportViewModel = new VeterinaryCaseReportViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportFromYearModels = reportYearList,
                    ReportToYearModels = reportYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    OrganizationList = organiztionList,
                    LanguageId = GetCurrentLanguage(),
                    FromYear = FromYear,
                    ToYear = ToYear,
                    FromMonth = FromMonth,
                    ToMonth = ToMonth,
                    RegionId =  _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature = includeSignaturePermission,
                    ShowUseArchiveData = archivePermission
                };

                return View(veterinaryCaseReportViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(VeterinaryCaseReportViewModel veterinaryCaseReportViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(GetCurrentLanguage());
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var organiztionList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);
                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(veterinaryCaseReportViewModel.RegionId));
                }
                organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                veterinaryCaseReportViewModel.ReportLanguageModels = reportLanguageList;
                veterinaryCaseReportViewModel.ReportFromYearModels = reportYearList;
                veterinaryCaseReportViewModel.ReportToYearModels = reportYearList;
                veterinaryCaseReportViewModel.ReportFromMonthNameModels = reportMonthNameList;
                veterinaryCaseReportViewModel.ReportToMonthNameModels = reportMonthNameList;
                veterinaryCaseReportViewModel.GisRegionList = gisRegionList;
                veterinaryCaseReportViewModel.GisRayonList = gisRayonList;
                veterinaryCaseReportViewModel.OrganizationList = organiztionList;
                veterinaryCaseReportViewModel.ShowIncludeSignature = includeSignaturePermission;
                veterinaryCaseReportViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(veterinaryCaseReportViewModel);
                }
                else
                {
                    veterinaryCaseReportViewModel.JavascriptToRun = "submitReport();";
                    return View(veterinaryCaseReportViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] VeterinaryCaseReportQueryModel  reportQueryModel)
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
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
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
        public async Task<IActionResult> GetRayonList(string node,string langId)
        {
            var gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(langId,node);
            return Ok(gisRayonList);
        }

        [HttpGet]
        public async Task<IActionResult> GetRegionList([FromQuery] string langId)
        {
            var gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(langId, IdfsCountryId);
            return Ok(gisRegionList);
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
