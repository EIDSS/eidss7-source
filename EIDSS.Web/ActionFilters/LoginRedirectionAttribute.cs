using EIDSS.ClientLibrary.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Routing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Policy;
using System.Threading.Tasks;

namespace EIDSS.Web.ActionFilters
{
    public class LoginRedirectionAttribute : ActionFilterAttribute
    {

        private ITokenService _tokenService { get; }

        public LoginRedirectionAttribute(ITokenService tokenService)
        {
            _tokenService = tokenService;
        }
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            if ( _tokenService.GetAuthenticatedUser() == null)
            {
                context.Result = new RedirectToRouteResult(new RouteValueDictionary
                    {
                        { "action", "Login" },
                        { "controller", "Admin" },
                        { "Area", "Administration" }
                    });

            }

        }
    }
}
