using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.Localization.Constants;
using Microsoft.Extensions.Localization;

namespace EIDSS.ClientLibrary.Services
{
    public interface ITokenService
    {
        public AuthenticatedUser CreateAuthenticatedUser(string token,string refreshToken, DateTime tokenExpireDatetime);
        public AuthenticatedUser UpdateClaimsInAuthenticatedUser(List<Claim> claims);
        public AuthenticatedUser GetAuthenticatedUser();
        public UserPermissions GerUserPermissions(PagePermission permission);
        public void UpdatePermissionsToReadOnly();
    }
    public class TokenService : ITokenService
    {
        public string sessionUserName { get; set; } = "user";

        private readonly IHttpContextAccessor _httpContextAccessor;
        private ISession _session => _httpContextAccessor.HttpContext.Session;
        private readonly IConfiguration _configuration;
        private IUserConfigurationService _userConfigurationService;
        private readonly IStringLocalizer _localizer;
        private readonly IApplicationContext ApplicationContext;



        public TokenService( IHttpContextAccessor httpContextAccessor,IConfiguration configuration, IUserConfigurationService configurationService, IStringLocalizer localizer, IApplicationContext applicationContext)
        {
            _httpContextAccessor = httpContextAccessor;
            _configuration = configuration;
            _userConfigurationService = configurationService;
            _localizer = localizer;
            ApplicationContext = applicationContext;
        }

        public virtual AuthenticatedUser GetAuthenticatedUser()
        {
            var sessionId = ApplicationContext.SessionId;
            var userName = ApplicationContext.GetSession("UserName");

            if (string.IsNullOrEmpty(sessionId))
                return null;
            if (string.IsNullOrEmpty(userName))
                return null;
            return _userConfigurationService.GetUserToken(sessionId, userName);
        }

        public virtual AuthenticatedUser CreateAuthenticatedUser(string token,string refreshToken, DateTime tokenExpireDatetime)
        {
            AuthenticatedUser authenticatedUser = null; 
            var handler = new JwtSecurityTokenHandler();

            var readableToken = handler.CanReadToken(token);
            if (readableToken)
            {
                var payLoad = handler.ReadJwtToken(token);
                var claims = payLoad.Claims;
                var jwtPayload = "{";
                foreach (var c in claims)
                {
                    jwtPayload += '"' + c.Type + "\":\"" + c.Value + "\",";

                }
                jwtPayload += '"' + "access_token" + "\":\"" + token + "\",";
                jwtPayload += "}";

                // Extract the result from the Jwt token

                var settings = new JsonSerializerSettings
                {
                    PreserveReferencesHandling = PreserveReferencesHandling.Objects
                };

                authenticatedUser = new AuthenticatedUser(_userConfigurationService);
                JsonConvert.PopulateObject(jwtPayload, authenticatedUser, settings);
                foreach (var child in payLoad.Claims)
                {
                    if (child.Type.ToLower().StartsWith("role") && authenticatedUser.RoleMembership.IndexOf(child.Value) == -1)
                        authenticatedUser.RoleMembership.Add(child.Value);
                    if (child.Type.ToLower().StartsWith("claim")) ExtractPermission(child.Value, ref authenticatedUser);
                }
      
            }

            if (authenticatedUser != null)
            {
                authenticatedUser.ExpireDate = tokenExpireDatetime;
                authenticatedUser.RefreshToken = refreshToken;
                authenticatedUser.IsInArchiveMode = false;
                authenticatedUser.ArchiveMenuName =
                    _localizer.GetString(FieldLabelResourceKeyConstants.SecurityConnecttoarchiveFieldLabel);
                var iSection = _configuration.GetSection("EIDSSGlobalSettings");
                authenticatedUser.AdminLevels = Convert.ToInt32(iSection.GetSection("AdminLevels").Value);

                authenticatedUser.DefaultCountry = !String.IsNullOrEmpty(iSection.GetSection("DefaultCountry").Value)
                    ? iSection.GetSection("DefaultCountry").Value
                    : "";
                authenticatedUser.Adminlevel0 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel0").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel0").Value)
                    : null;
                authenticatedUser.Adminlevel1 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel1").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel1").Value)
                    : null;
                authenticatedUser.Adminlevel2 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel2").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel2").Value)
                    : null;
                authenticatedUser.Adminlevel3 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel3").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel3").Value)
                    : null;
                authenticatedUser.Adminlevel4 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel4").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel4").Value)
                    : null;
                authenticatedUser.Adminlevel5 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel5").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel5").Value)
                    : null;
                authenticatedUser.Adminlevel6 = !String.IsNullOrEmpty(iSection.GetSection("AdminLevel6").Value)
                    ? Convert.ToInt64(iSection.GetSection("AdminLevel6").Value)
                    : null;

                authenticatedUser.BottomAdminLevel = Convert.ToInt64(iSection.GetSection("BottomAdminlevel").Value);

                authenticatedUser.Settlement = !String.IsNullOrEmpty(iSection.GetSection("Settlement").Value)
                    ? Convert.ToInt64(iSection.GetSection("Settlement").Value)
                    : null;

            }
            return authenticatedUser;
        }


        public AuthenticatedUser UpdateClaimsInAuthenticatedUser(List<Claim> claims)
        {
            var sessionId = ApplicationContext.SessionId;
            var userName = ApplicationContext.GetSession("UserName");

            if (string.IsNullOrEmpty(sessionId))
                return null;
            if (string.IsNullOrWhiteSpace(userName))
                return null;

            var authenticatedUser = _userConfigurationService.GetUserToken(sessionId, userName);
            
            if (authenticatedUser == null) 
                return null;

            var jwtPayload = claims.Aggregate("{", (current, c) => current + ('"' + c.Type + "\":\"" + c.Value + "\","));
            jwtPayload += "}";


            var settings = new JsonSerializerSettings
            {
                PreserveReferencesHandling = PreserveReferencesHandling.Objects
            };

            JsonConvert.PopulateObject(jwtPayload, authenticatedUser, settings);

            return authenticatedUser;
        }

        /// <summary>
        /// Extracts a user permission from a dictionary entry returned with the authentication packet.
        /// </summary>
        /// <param name="node"></param>
        /// <returns></returns>
        private void ExtractPermission(string node, ref AuthenticatedUser tokenInstance)
        {
            // return if null or empty...
            if (string.IsNullOrEmpty(node)) return;

            // each entry contains the permission name, the permission level and the permission id, seperated with a pipe | symbol.
            var entries = node.Split('|');

            // check to see if this permission exists in the list...
            var p = tokenInstance.Claims.Where(w => w.PermissionId == Convert.ToInt64(entries[2]));

            if (p.Any()) // test for count because Permission is auto-instantiated and may be empty first time thru...
            {
                // Check to see if the permission level exists...
                if (!p.FirstOrDefault().PermissionLevels.Any(w => w.PermissionLevelId == Convert.ToInt64(entries[0])))

                    p.FirstOrDefault().PermissionLevels.Add(new PermissionLevel(Convert.ToInt64(entries[0]), entries[1]));
            }
            else
            {
                var pl = new PermissionLevel(Convert.ToInt64(entries[0]), entries[1]);
                var x = new Permission
                {
                    PermissionId = Convert.ToInt64(entries[2]),
                    PermissionType = entries[1],
                    PermissionLevels = new List<PermissionLevel> { pl }
                };
                tokenInstance.Claims.Add(x);
            }
        }


        public void  UpdatePermissionsToReadOnly()
        {
            var sessionId = ApplicationContext.SessionId;
            var userName = ApplicationContext.GetSession("UserName");

            if (string.IsNullOrEmpty(sessionId))
                return;
            if (string.IsNullOrWhiteSpace(userName))
                return;

            var authenticatedUser = _userConfigurationService.GetUserToken(sessionId, userName);

            authenticatedUser?.Claims.ToList().ForEach(p =>
                p.PermissionLevels.RemoveAll(pl => ((pl.PermissionLevelId != (long)PermissionLevelEnum.Read)) && p.PermissionId != (long)PagePermission.CanReadArchivedData));
        }

        public virtual UserPermissions GerUserPermissions(PagePermission permission)
        {
            var sessionId = ApplicationContext.SessionId;
            var userName = ApplicationContext.GetSession("UserName");
            var userPermission = new UserPermissions();

            if (string.IsNullOrEmpty(sessionId))
                return userPermission;
            if (string.IsNullOrWhiteSpace(userName))
                return userPermission;

            var authenticatedUser = _userConfigurationService.GetUserToken(sessionId, userName);

            if (authenticatedUser == null)
                return userPermission;

            userPermission = new UserPermissions()
            {
                Create = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.Create),
                Read = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.Read),
                Write = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.Write),
                Delete = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.Delete),
                AccessToGenderAndAgeData = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.AccessToGenderAndAgeData),
                AccessToPersonalData = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.AccessToPersonalData),
                Execute = authenticatedUser.UserHasPermission(permission, PermissionLevelEnum.Execute)
            };

            return userPermission;
        }
    }
}
