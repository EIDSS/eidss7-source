using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.ActionFilters;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Configurations;
using Microsoft.Extensions.Options;

namespace EIDSS.Web.Areas.Reports.Controllers
{
    [Area("Reports")]
    [ServiceFilter(typeof(LoginRedirectionAttribute))]
    public class CustomReportController : EIDSS.ReportViewer.ReportController
    {
        private readonly IConfiguration _configuration;

        internal readonly ITokenService _tokenService;

        internal AuthenticatedUser authenticatedUser;

        private ICrossCuttingClient _crossCuttingClient;

        protected  bool  DisplayReportParameters { get; set; }

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

        protected override string ReportServerUrl => throw new NotImplementedException();

        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;

        public CustomReportController(IConfiguration configuration, ITokenService tokenService, ICrossCuttingClient crossCuttingClient, ILogger<CustomReportController> logger) : base(logger)
        {

            _tokenService = tokenService;
            _crossCuttingClient = crossCuttingClient;
            _configuration = configuration;

            IdfsCountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            Path = _configuration.GetValue<string>("ReportServer:Path");
            ArchivedPath = _configuration.GetValue<string>("ReportServer:ArchivedPath");

            var protectedConfigSection = configuration.GetSection("ProtectedConfiguration");
            var protectedConfig = protectedConfigSection.Get<ProtectedConfigurationSettings>();

            Domain = protectedConfig.SSRS_Domain.Decrypt();
            UserName = protectedConfig.SSRS_UserName.Decrypt();
            Password = protectedConfig.SSRS_Password.Decrypt();
            ReportPath = $"{Path}/{ReportFileName}";

            DisplayReportParameters = _configuration.GetValue<bool>("ReportServer:ShowReportParameters");



        }

        public IActionResult Index()
        {



            return View();
        }
    }
}
