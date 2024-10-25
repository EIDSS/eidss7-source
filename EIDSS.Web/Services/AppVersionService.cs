using System;
using System.Reflection;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;

namespace EIDSS.Web.Services
{
    public class AppVersionService : IAppVersionService
    {
        private const string StartYear = "2023";

        private readonly AuthenticatedUser authenticatedUser;

        public AppVersionService(IUserConfigurationService configurationService, IApplicationContext applicationContext)
        {
            var sessionId = applicationContext.SessionId;
            var loggedUserName = applicationContext.GetSession("UserName");
            authenticatedUser = configurationService.GetUserToken(sessionId, loggedUserName);
        }

        public string Version
        {
            get
            {
                var version = Assembly.GetEntryAssembly().GetName().Version;
                return $"{version.Major}.{version.Minor}.{version.Build}";
            }
        }

        public string GetOrganizationName()
        {
            var organizationName = string.Empty;
            if (authenticatedUser != null)
            {
                organizationName = authenticatedUser.Organization;
            }

            return organizationName;
        }

        public string GetYears()
        {
            string endYear = DateTime.UtcNow.ToString("yyyy");

            if (string.IsNullOrWhiteSpace(StartYear))
                return endYear;
            if (string.Compare(endYear, StartYear.Trim(), StringComparison.InvariantCultureIgnoreCase) <= 0)
                return endYear;
            return string.Format("{0} - {1}", StartYear, endYear);
        }
    }
}
