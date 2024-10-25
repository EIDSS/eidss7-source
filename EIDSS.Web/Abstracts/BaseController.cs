using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.ActionFilters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Globalization;
using System.Threading;

namespace EIDSS.Web.Abstracts
{
    [RequireHttps]
    [ServiceFilter(typeof(LoginRedirectionAttribute))]
    [Authorize]
    public abstract class BaseController : Controller
    {
        protected internal ILogger _logger;
        internal readonly ITokenService _tokenService;
        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        internal AuthenticatedUser authenticatedUser;
        public string CountryId { get; set; }

        public BaseController(ILogger logger, ITokenService tokenService)
            : this(logger)
        {
            _tokenService = tokenService;
        }

        public BaseController(ILogger logger)
        {
            _logger = logger;
        }

        public UserPermissions GetUserPermissions(PagePermission pageEnum)
        {
            UserPermissions userPermissions = new();

            if (_tokenService != null)
            {
                authenticatedUser = _tokenService.GetAuthenticatedUser();
                if (authenticatedUser != null)
                {
                    userPermissions = _tokenService.GerUserPermissions(pageEnum);
                }
            }

            return userPermissions;
        }

        /// <summary>
        /// Returns the current UI culture code; used primarily for the language ID
        /// parameter on stored procedure calls to get back the appropriate
        /// translated values for reference and resource data.
        /// </summary>
        /// <returns></returns>
        public string GetCurrentLanguage()
        {
            return cultureInfo.Name;
        }
    }
}
