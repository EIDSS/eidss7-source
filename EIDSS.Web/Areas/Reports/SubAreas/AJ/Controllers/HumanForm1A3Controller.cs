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
    public class HumanForm1A3Controller : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        internal bool archivePermission;
        internal bool includeSignaturePermission;

        public HumanForm1A3Controller(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService,  ILogger<HumanForm1A3Controller> logger) : 
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "HumanFormN1Report_A3";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Execute;
            includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Execute;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;

        }

        public string ReportName { get; set; } = "Form #1 (A3)";
        public int Year { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        public long IdfsReference_FromMonth { get; set; } = Convert.ToInt64(DateTime.Now.ToString("MM"));
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
                var reportYearList = await _crossCuttingClient.GetReportYearList();
                var reportMonthNameList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                var gisRegionList = new List<GisLocationChildLevelModel>();
                var gisRayonList = new List<GisLocationChildLevelModel>();
                var organiztionList = new List<BaseReferenceViewModel>();

                gisRegionList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), IdfsCountryId);

                if (gisRegionList.Count > 0)
                {
                    gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(_tokenService.GetAuthenticatedUser().RegionId));
                }

                organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                var humanForm1A3ViewModel = new HumanForm1A3ViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    ReportYearModels = reportYearList,
                    ReportFromMonthNameModels = reportMonthNameList,
                    ReportToMonthNameModels = reportMonthNameList,
                    GisRegionList = gisRegionList,
                    GisRayonList = gisRayonList,
                    OrganizationList = organiztionList,
                    LanguageId = GetCurrentLanguage(),
                    Year = Year,
                    idfsReference_FromMonth= IdfsReference_FromMonth,
                    idfsReference_ToMonth = IdfsReference_ToMonth,
                    RegionId =  _tokenService.GetAuthenticatedUser().RegionId,
                    RayonId = _tokenService.GetAuthenticatedUser().RayonId,
                    ShowIncludeSignature= includeSignaturePermission,
                    ShowUseArchiveData= archivePermission
                };

                return View(humanForm1A3ViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(HumanForm1A3ViewModel humanForm1A3ViewModel)
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
                    if (string.IsNullOrEmpty(Convert.ToString(humanForm1A3ViewModel.RegionId)))
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(gisRegionList.FirstOrDefault().idfsReference));
                    else
                        gisRayonList = await _crossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(humanForm1A3ViewModel.RegionId));
                }
                organiztionList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));

                humanForm1A3ViewModel.ReportLanguageModels = reportLanguageList;
                humanForm1A3ViewModel.ReportYearModels = reportYearList;
                humanForm1A3ViewModel.ReportFromMonthNameModels = reportMonthNameList;
                humanForm1A3ViewModel.ReportToMonthNameModels = reportMonthNameList;
                humanForm1A3ViewModel.GisRegionList = gisRegionList;
                humanForm1A3ViewModel.GisRayonList = gisRayonList;
                humanForm1A3ViewModel.OrganizationList = organiztionList;
                humanForm1A3ViewModel.ShowIncludeSignature = includeSignaturePermission;
                humanForm1A3ViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(humanForm1A3ViewModel);
                }
                else
                {
                    humanForm1A3ViewModel.JavascriptToRun = "submitReport();";
                    return View(humanForm1A3ViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] HumanForm1A3QueryModel  reportQueryModel)
        {
            try
            { 
                ReportViewModel model = new();
                model.ReportPath = reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("Year", reportQueryModel.Year);
                model.AddParameter("FromMonth", reportQueryModel.IdfsReference_FromMonth);
                model.AddParameter("ToMonth", reportQueryModel.IdfsReference_ToMonth);
                model.AddParameter("RegionID", reportQueryModel.RegionId);
                model.AddParameter("RayonID", reportQueryModel.RayonId);
                model.AddParameter("Organization", reportQueryModel.EnterByOrganizationId);
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
            var organiztionList = await _crossCuttingClient.GetBaseReferenceList(langId,  BaseReferenceConstants.OrganizationName, Convert.ToInt64(AccessoryCodes.AllHACode));
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
