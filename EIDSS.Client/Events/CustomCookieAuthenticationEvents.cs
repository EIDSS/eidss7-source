using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace EIDSS.ClientLibrary.Events
{
    public class CustomCookieAuthenticationEvents : CookieAuthenticationEvents
    {
        protected IUserConfigurationService UserConfigurationService;
        public CustomCookieAuthenticationEvents(IUserConfigurationService configurationService)
        {
            UserConfigurationService = configurationService;
        }
         
        public override async Task ValidatePrincipal(CookieValidatePrincipalContext context)
        {
            var userPrincipal = context.Principal;

            // Look for the LastChanged claim.
            if (userPrincipal != null)
            {
                var loggedInUser = (from c in userPrincipal.Claims
                                   where c.Type == "userName"
                                select c.Value).FirstOrDefault();
                


            }
        }
    }
}