using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.Controllers
{
    [Area("Reports")]
    [Controller]
    public class PrintBarcodesController : Reports.Controllers.ReportController
    {
        internal UserPermissions userPermissions;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly UserPreferences _userPreferences;
        private string NoneSelected = ""; //"(None Selected)";
        internal bool prefix = true;
        internal bool site = true;
        internal bool year = true;
        internal bool date;
        //internal bool archivePermission;
        //internal bool includeSignaturePermission;

        public PrintBarcodesController(IConfiguration configuration, ICrossCuttingClient crossCuttingClient, ITokenService tokenService, ILogger<PrintBarcodesController> logger) :
                base(configuration, tokenService, crossCuttingClient, logger)
        {
            _logger = logger;
            _configuration = configuration;
            _crossCuttingClient = crossCuttingClient;
            ReportFileName = "PrintBarcodes";
            ReportPath = $"{Path}/{ReportFileName}";
            userPermissions = _tokenService.GerUserPermissions(PagePermission.AccessToSystemPreferences);
            //archivePermission = _tokenService.GerUserPermissions(PagePermission.CanReadArchivedData).Read;
            //includeSignaturePermission = _tokenService.GerUserPermissions(PagePermission.CanSignReport).Read;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
        }

        public string ReportName { get; set; } = "Print Barcodes";

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
                var typeOfBarCodeLabel = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.NumberingSchemaDocumentType, 0);

                var printBarcodesViewModel = new PrintBarcodesViewModel()
                {
                    ReportName = ReportName,
                    ReportLanguageModels = reportLanguageList,
                    TypeOfBarCodeLabelList = typeOfBarCodeLabel,
                    NoOfLabelsToPrintList =  GetNumbersList(1, 100, 1, NoneSelected),
                    LanguageId = GetCurrentLanguage(),
                    PriorLanguageId = GetCurrentLanguage(),
                    NoOfLabelsToPrint ="1",
                    Prefix = prefix,
                    Site = site,
                    Year = year,
                    Date = date
                    //ShowIncludeSignature = includeSignaturePermission,
                    //ShowUseArchiveData = archivePermission
                };

                return View(printBarcodesViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpPost]
        public async Task<IActionResult> Index(PrintBarcodesViewModel printBarcodesViewModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(printBarcodesViewModel.LanguageId);
                var typeOfBarCodeLabel = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.NumberingSchemaDocumentType, 0);

                printBarcodesViewModel.ReportName = ReportName;
                printBarcodesViewModel.ReportLanguageModels = reportLanguageList;
                printBarcodesViewModel.TypeOfBarCodeLabelList = typeOfBarCodeLabel;
                printBarcodesViewModel.NoOfLabelsToPrintList = GetNumbersList(1, 100, 1, NoneSelected);
                printBarcodesViewModel.Prefix = prefix;
                printBarcodesViewModel.Site = site;
                printBarcodesViewModel.Year = year;
                printBarcodesViewModel.Date = date;
                //printBarcodesViewModel.ShowIncludeSignature = includeSignaturePermission;
                //printBarcodesViewModel.ShowUseArchiveData = archivePermission;

                if (!ModelState.IsValid)
                {
                    return View(printBarcodesViewModel);
                }
                else
                {
                    printBarcodesViewModel.JavascriptToRun = "submitReport();";
                    return View(printBarcodesViewModel);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }


        }

        [HttpPost]
        public async Task<IActionResult> ChangeLanguage([FromBody] PrintBarcodesQueryModel reportQueryModel)
        {
            try
            {
                var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(reportQueryModel.LanguageId);
                var typeOfBarCodeLabel = await _crossCuttingClient.GetBaseReferenceList(reportQueryModel.LanguageId, BaseReferenceConstants.NumberingSchemaDocumentType, 0);

                var printBarcodesViewModel = new PrintBarcodesViewModel()
                {
                    //IncludeSignature = Convert.ToBoolean(reportQueryModel.IncludeSignature),
                    ReportName = reportQueryModel.ReportName,
                    ReportLanguageModels = reportLanguageList,
                    LanguageId = reportQueryModel.LanguageId,
                    PriorLanguageId = reportQueryModel.LanguageId,
                    TypeOfBarCodeLabelList = typeOfBarCodeLabel,
                    TypeOfBarCodeLabel = reportQueryModel.TypeOfBarCodeLabel,
                    NoOfLabelsToPrintList = GetNumbersList(1, 100, 1, NoneSelected),
                    NoOfLabelsToPrint = reportQueryModel.NoOfLabelsToPrint,
                    Prefix = Convert.ToBoolean(reportQueryModel.Prefix),
                    Site = Convert.ToBoolean(reportQueryModel.Site),
                    Year = Convert.ToBoolean(reportQueryModel.Year),
                    Date = Convert.ToBoolean(reportQueryModel.Date),
                    //UseArchiveData = Convert.ToBoolean(reportQueryModel.UseArchiveData),
                    //ShowIncludeSignature = includeSignaturePermission,
                    //ShowUseArchiveData = archivePermission
                };

                return View("Index", printBarcodesViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost]
        public IActionResult GenerateReport([FromBody] PrintBarcodesQueryModel reportQueryModel)
        {
            try
            {

                ReportViewModel model = new();
                model.ReportPath = ReportPath; //reportQueryModel.UseArchiveData == "false" ? ReportPath : $"/{ArchivedPath}/{ReportFileName}";
                model.AddParameter("LangID", reportQueryModel.LanguageId);
                model.AddParameter("TypeOfBarCodeLabel", reportQueryModel.TypeOfBarCodeLabel);
                model.AddParameter("NoOfLabelsToPrint", reportQueryModel.NoOfLabelsToPrint);
                model.AddParameter("Prefix", reportQueryModel.Prefix == "true" ? "1" : "0");
                model.AddParameter("Site", reportQueryModel.Site == "true" ? "5" : "");
                model.AddParameter("Year", reportQueryModel.Year == "true" ? "1" : "0");
                model.AddParameter("Date", reportQueryModel.Date == "true" ? "1" : "0");
                //model.AddParameter("IncludeSignature", reportQueryModel.IncludeSignature);
                model.AddParameter("UserFullName", $"{authenticatedUser.FirstName} {authenticatedUser.LastName}");
                model.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);
                model.AddParameter("PrintDateTime", reportQueryModel.PrintDateTime.ToString(new CultureInfo("en-US")));

                return PartialView("~/Areas/Reports/Views/Shared/_PartialReport.cshtml", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetLanguageList([FromQuery] string langId)
        {
            var reportLanguageList = await _crossCuttingClient.GetReportLanguageList(langId);
            return Ok(reportLanguageList);
        }

        [HttpGet]
        public async Task<IActionResult> GetTypeOfBarCodeLabelList([FromQuery] string langId)
        {
            var typeOfBarCodeLabel = await _crossCuttingClient.GetBaseReferenceList(langId, BaseReferenceConstants.NumberingSchemaDocumentType, 0);
            return Ok(typeOfBarCodeLabel);
        }

        private List<Age> GetNumbersList(int StartNumber, int EndNumber, int Increment, string lblNoneSelected)
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
        public IActionResult GetNoOfLabelsToPrintList()
        {
            var noOfLabelsToPrintList = GetNumbersList(1, 100, 1, NoneSelected);

            return Ok(noOfLabelsToPrintList);
        }
    }
}

