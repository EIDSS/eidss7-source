using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.ActionFilters;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Reports.Controllers
{
    [Area("Reports")]
    [ServiceFilter(typeof(LoginRedirectionAttribute))]
    public class ReportController : EIDSS.ReportViewer.ReportController
    {
        private readonly IConfiguration _configuration;

        internal readonly ITokenService _tokenService;

        internal AuthenticatedUser authenticatedUser;

        private ICrossCuttingClient _crossCuttingClient;

        protected bool DisplayReportParameters { get; set; }


        public string ReportPath { get; set; }

        public string ReportFileName { get; set; } = "HumanFormN1Report_A3";

        public string IdfsCountryId { get; set; }

        //Only override this property if your controller is not called ReportController.
        //You'll want to enter whatever your controller's name is in place of "YourController" below.
        protected override string ReportImagePath
        {
            get
            {
                //return $"/HumanForm1A3Controller/ReportImage/?originalPath={Path}";
                return "Reports/Report/ReportImage/?originalPath={0}";
            }
        }

        protected override bool AjaxLoadInitialReport
        {
            get { return false; }
        }

        protected override ICredentials NetworkCredentials
        {
            get
            {
                //Custom Domain authentication (be sure to pull the info from a config file)
                return new System.Net.NetworkCredential(UserName, Password, Domain);
            }
        }

        public string Path { get; set; }

        public string ArchivedPath { get; set; }

        public string Domain { get; set; }

        public string UserName { get; set; }

        public string Password { get; set; }

        protected override bool ShowReportParameters
        {

            get
            {
                return DisplayReportParameters;
            }
        }

        protected override string ReportServerUrl
        {
            get
            {
                //You don't want to put the full API path here, just the path to the report server's ReportServer directory that it creates
                //(you should be able to access this path from your browser: https://YourReportServerUrl.com/ReportServer/ReportExecution2005.asmx )
                return _configuration.GetValue<string>("ReportServer:Url");
            }
        }

        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;

        public ReportController(IConfiguration configuration, ITokenService tokenService, ICrossCuttingClient crossCuttingClient, ILogger<ReportController> logger) : base(logger)
        {
           
            _tokenService = tokenService;
            _crossCuttingClient = crossCuttingClient;
            _configuration = configuration;

            var protectedConfigSection = configuration.GetSection("ProtectedConfiguration");
            var protectedConfig = protectedConfigSection.Get<ProtectedConfigurationSettings>();

            IdfsCountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            Path = _configuration.GetValue<string>("ReportServer:Path");
            ArchivedPath = _configuration.GetValue<string>("ReportServer:ArchivedPath");

            Domain = protectedConfig.SSRS_Domain.Decrypt();
            UserName = protectedConfig.SSRS_UserName.Decrypt();
            Password = protectedConfig.SSRS_Password.Decrypt();

            ReportPath = $"{Path}/{ReportFileName}";
            DisplayReportParameters = _configuration.GetValue<bool>("ReportServer:ShowReportParameters");
        }

        public UserPermissions GetUserPermissions(PagePermission pageEnum)
        {
            UserPermissions userPermissions = new UserPermissions();
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            if (authenticatedUser != null)
            {
                userPermissions = _tokenService.GerUserPermissions(pageEnum);
            }

            return userPermissions;
        }

        [HttpPost]
        public async Task<IActionResult> SaveReportAudit([FromBody] ReportAuditSaveJsonModel reportAuditSaveJsonViewModel)
        {

            ReportAuditSaveRequestModel reportAuditSaveRequestViewModel = new ReportAuditSaveRequestModel();
                            Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

            var authenticatedUser = _tokenService.GetAuthenticatedUser();
            reportAuditSaveRequestViewModel.strReportName = reportAuditSaveJsonViewModel.StrReportName;
            reportAuditSaveRequestViewModel.idfUserID = Convert.ToInt64(authenticatedUser.EIDSSUserId);
            reportAuditSaveRequestViewModel.idfIsSignatureIncluded = reportAuditSaveJsonViewModel.IdfIsSignatureIncluded != null ? Convert.ToBoolean(reportAuditSaveJsonViewModel.IdfIsSignatureIncluded) : false;
            reportAuditSaveRequestViewModel.strFirstName = authenticatedUser.FirstName;
            reportAuditSaveRequestViewModel.strMiddleName = authenticatedUser.SecondName;
            reportAuditSaveRequestViewModel.strLastName = authenticatedUser.LastName;
            reportAuditSaveRequestViewModel.strOrganization = authenticatedUser.Organization;
            reportAuditSaveRequestViewModel.userRole = authenticatedUser.RoleMembership.Count > 0 ? authenticatedUser.RoleMembership.FirstOrDefault() : "";
            reportAuditSaveRequestViewModel.datGeneratedDate = Convert.ToDateTime(DateTime.Now.ToString(CultureInfo.InvariantCulture)); // Convert.ToDateTime(DateTime.Now.ToString("MM/dd/yyyy HH:mm:ss"));

            var response = await _crossCuttingClient.SaveReportAudit(reportAuditSaveRequestViewModel);
            return Ok(response);
        }


        public string GetCurrentLanguage()
        {
            return uiCultureInfo.Name;
            //string strLangID = string.Empty;
            //switch (uiCultureInfo.Name)
            //{
            //    case "az-Latn-AZ":
            //        {
            //            strLangID = "az-L";
            //            break;
            //        }

            //    case "ru-RU":
            //        {
            //            strLangID = "ru";
            //            break;
            //        }

            //    case "en-US":
            //        {
            //            strLangID = "en";
            //            break;
            //        }

            //    case "ka-GE":
            //        {
            //            strLangID = "ka";
            //            break;
            //        }

            //    case "kk-KZ":
            //        {
            //            strLangID = "kk";
            //            break;
            //        }

            //    case "uz-Cyrl-UZ":
            //        {
            //            strLangID = "uz-C";
            //            break;
            //        }

            //    case "uz-Latn-UZ":
            //        {
            //            strLangID = "uz-L";
            //            break;
            //        }

            //    case "uk-UA":
            //        {
            //            strLangID = "uk";
            //            break;
            //        }

            //    case "hy-AM":
            //        {
            //            strLangID = "hy";
            //            break;
            //        }

            //    case "ar-IQ":
            //        {
            //            strLangID = "ar";
            //            break;
            //        }

            //    case "vi-VN":
            //        {
            //            strLangID = "vi";
            //            break;
            //        }

            //    case "lo-LA":
            //        {
            //            strLangID = "lo";
            //            break;
            //        }

            //    case "th-TH":
            //        {
            //            strLangID = "th";
            //            break;
            //        }

            //    default:
            //        {
            //            strLangID = "en";
            //            break;
            //        }
            //}

            //return strLangID;
        }

    }
}
