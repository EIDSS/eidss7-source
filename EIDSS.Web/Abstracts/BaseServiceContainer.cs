#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
//using System.Text.Json.Serialization;
using Newtonsoft.Json;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Abstracts
{
    /// <summary>
    /// 
    /// </summary>
    public class BaseServiceContainer
    {
        #region Globals

        #region Member Variables

        private ITokenService _tokenService;
        private ILogger _baseLogger;
        private IConfiguration _configuration;

        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        internal AuthenticatedUser authenticatedUser;

        #endregion

        #region Properties
        public string CountryID
        {
            get
            {
                return _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            }
        }

        #endregion

        #endregion

        #region Methods

        #region Constructor

        public BaseServiceContainer()
        {
            // needed for deserialization
        }

        [JsonConstructor]
        public BaseServiceContainer(ILogger logger, ITokenService tokenService, IConfiguration configuration)
        {
            _baseLogger = logger;
            _tokenService = tokenService;
            _configuration = configuration;
        }

        #endregion Constructor

        #region Security Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="pageEnum"></param>
        /// <returns></returns>
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

        public ITokenService TokenService
            { get { return _tokenService; } }

        #endregion

        #region Culture Methods

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

        #endregion

        #endregion
    }
}
