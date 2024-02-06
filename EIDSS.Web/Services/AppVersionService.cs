using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace EIDSS.Web.Services
{
    public interface IAppVersionService
    {
        string Version { get; }
        string GetOrganizationName();
        string GetYears();
    }

    public class AppVersionService : IAppVersionService
    {
        internal AuthenticatedUser authenticatedUser;
        private string StartYear = "2023";

        public AppVersionService( IUserConfigurationService configurationService, IApplicationContext applicationContext)
        {
            //TODO: remove commented if session-User approach works
            //////var userName = applicationContext.GetSession("UserName");
            //////if (userName !=null)
            //////{ 
            ////authenticatedUser = configurationService.GetUserToken();
            //////}

            var sessionId = applicationContext.SessionId;
            var loggedUserName = applicationContext.GetSession("UserName");
            authenticatedUser = configurationService.GetUserToken(sessionId, loggedUserName);

        }
        public string Version => Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyInformationalVersionAttribute>().InformationalVersion;

        public string GetOrganizationName()
        {
            var organizationName = "";
            if (authenticatedUser !=null)
            {
                organizationName = authenticatedUser.Organization;
            }

            return organizationName;
        }

        public string GetYears()
        {
            string endYear =  DateTime.UtcNow.ToString("yyyy");
            
            if (string.IsNullOrWhiteSpace(StartYear))
                return endYear;
            if (String.Compare(endYear, StartYear.Trim(), StringComparison.InvariantCultureIgnoreCase) <= 0)
                return endYear;
            return string.Format("{0} - {1}", StartYear, endYear);
        }
    }
}
