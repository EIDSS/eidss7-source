#region Using Statements

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.ActionFilters;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Globalization;
using System.Threading;

#endregion

namespace EIDSS.Web.Abstracts
{
    [ServiceFilter(typeof(LoginRedirectionAttribute))]
    public abstract class BaseViewComponent : ViewComponent
    {
        #region Global Values

        protected internal ILogger _logger;
        internal readonly ITokenService _tokenService;
        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        internal AuthenticatedUser authenticatedUser;
        private readonly IConfiguration _configuration;
        internal IConfiguration Configuration { get { return _configuration; } }
        public string CountryId { get; set; }

        #endregion

        #region Constructors

        public BaseViewComponent(ILogger logger, ITokenService tokenService)
        {
            _logger = logger;
            _tokenService = tokenService;
        }

        public BaseViewComponent()
        {
        }

        public BaseViewComponent(ILogger logger)
        {
            _logger = logger;
        }

        #endregion

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
