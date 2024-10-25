using EIDSS.Api.Providers;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Api.Controllers.Administration.Security;
using Serilog;

namespace EIDSS.Api.Provider
{

    public interface IPermissionService
    {
        Task<List<UserRolesAndPermissionsViewModel>> GetPermissionsAsync(long UserId, long? employeeId, CancellationToken cancellationToken);
        Task<AspNetUserDetailModel> GetUseDetails(string id, CancellationToken cancellationToken);
        Task<List<Claim>> GetTokenClaims(ApplicationUser user);
        Task<List<Claim>> GetUserClaims(ApplicationUser user);
    }

    public class PermissionService:IPermissionService
    {
        private readonly IConfiguration _configuration;
        private readonly IDataRepository _repository;

        public PermissionService(IConfiguration configuration, IDataRepository repository)
        {
            _configuration = configuration;
            _repository = repository;
        }

        public async Task<List<UserRolesAndPermissionsViewModel>> GetPermissionsAsync(long UserId, long? employeeId,CancellationToken cancellationToken = default)
        {

            List<UserRolesAndPermissionsViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                //results = await _administrationRepository.GetVectorTypeListAsync(langID, strSearchVectorType, cancellationToken);
                DataRepoArgs args = new()
                {
                    Args = new object[] { UserId, employeeId, null,cancellationToken },
                    MappedReturnType = typeof(List<UserRolesAndPermissionsViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ASPNetUser_GetRolesAndPermissionsResult>)
                };

                results = await _repository.Get(args) as List<UserRolesAndPermissionsViewModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
               // Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                //Log.Error(ex.Message);
                throw;
            }

            return results.ToList();
         
               
        }

        public async Task<AspNetUserDetailModel> GetUseDetails(string id, CancellationToken cancellationToken = default)
        {

            List<AspNetUserDetailModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { id, null, cancellationToken },
                    MappedReturnType = typeof(List<AspNetUserDetailModel>),
                    RepoMethodReturnType = typeof(List<USP_ASPNetUser_GetDetailResult>)
                };

                results = await _repository.Get(args) as List<AspNetUserDetailModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                // Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                //Log.Error(ex.Message);
                throw;
            }

            return results.FirstOrDefault();

        }



        public async Task<SecurityConfigurationViewModel> GetSecurityPolicy(CancellationToken cancellationToken = default)
        {
            List<SecurityConfigurationViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { null, cancellationToken },
                    MappedReturnType = typeof(List<SecurityConfigurationViewModel>),
                    RepoMethodReturnType = typeof(List<USP_SecurityConfiguration_GetResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SecurityConfigurationViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return results.FirstOrDefault();
        }



        public async Task<List<Claim>> GetTokenClaims(ApplicationUser user)
        {
            var userDetail = await GetUseDetails(user.Id);

            var securityPolicy = await GetSecurityPolicy();

            //TODO: check if the name can be null
            var uName = userDetail?.UserName ?? user.UserName;
            //var claims = await CreateTokenClaims(userDetail);
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, uName),
                new Claim(JwtRegisteredClaimNames.UniqueName, uName),
                new Claim(ClaimTypes.NameIdentifier, uName),
                new Claim("userName", uName)
             
            };
            if (securityPolicy.LockoutThld != null)
                claims.Add(new Claim("ExpireDate",
                    DateTimeOffset.UtcNow.AddMinutes((double)securityPolicy.LockoutThld).ToString()));
            claims.Add(new Claim("LockoutThld", securityPolicy.LockoutThld.ToString()));

            claims.Add(new Claim("InactivityTimeOut", securityPolicy.SesnInactivityTimeOutMins.ToString()));
            claims.Add(new Claim("MaxSessionLength", securityPolicy.MaxSessionLength.ToString()));

            claims.Add(new Claim("DisplaySessionInactivity", securityPolicy.SesnIdleTimeoutWarnThldMins.ToString()));
            claims.Add(new Claim("DisplaySessionCloseOut", securityPolicy.SesnIdleCloseoutThldMins.ToString()));
            
            return claims;


        }

        public async Task<List<Claim>> GetUserClaims(ApplicationUser user)
        {
            var userDetail = await GetUseDetails(user.Id);

            var claims = await CreateTokenClaims(userDetail);
           
            return claims;

        }

        public async Task<List<Claim>> GetPermissionClaims(long userId)
        {

            var permissionList = await GetPermissionsAsync(userId, null);

            var claims = CreatePermissionClaims(permissionList);

            return claims;

        }

        public async Task<List<Claim>> CreateTokenClaims(AspNetUserDetailModel userDetails)
        {
            List<Claim> claims = new List<Claim>();

             var securityPolicy = await GetSecurityPolicy();

            claims.Add(new Claim(ClaimTypes.Name, userDetails.UserName));
            claims.Add(new Claim(JwtRegisteredClaimNames.UniqueName, userDetails.UserName));
            claims.Add(new Claim(ClaimTypes.NameIdentifier, userDetails.UserName));
            claims.Add(new Claim("userName", userDetails.UserName));
            claims.Add(new Claim("ASPNetId", userDetails.Id));
            claims.Add(new Claim("EIDSSUserId", userDetails.idfUserID.ToString()));
            claims.Add(new Claim("Email", !string.IsNullOrEmpty(userDetails.Email) ? userDetails.Email : ""));
            claims.Add(new Claim("PersonId", userDetails.idfPerson.ToString()));
            claims.Add(new Claim("FirstName", !string.IsNullOrEmpty(userDetails.strFirstName) ? userDetails.strFirstName : ""));
            claims.Add(new Claim("SecondName", !string.IsNullOrEmpty(userDetails.strSecondName) ? userDetails.strSecondName : ""));
            claims.Add(new Claim("LastName", !string.IsNullOrEmpty(userDetails.strFamilyName) ? userDetails.strFamilyName : ""));
            claims.Add(new Claim("SiteId", userDetails.idfsSite.ToString()));
            claims.Add(new Claim("Institution", userDetails.Institution.ToString()));
            claims.Add(new Claim("Organization", !string.IsNullOrEmpty(userDetails.OfficeAbbreviation) ? userDetails.OfficeAbbreviation : ""));
            claims.Add(new Claim("OfficeId", userDetails.idfOffice.ToString()));
            claims.Add(new Claim("RegionId", userDetails.idfsRegion.ToString()));
            claims.Add(new Claim("RayonId", userDetails.idfsRayon.ToString()));
            claims.Add(new Claim("SiteTypeId", userDetails.idfsSiteType.ToString()));
            claims.Add(new Claim("SiteGroupID", userDetails.SiteGroupID.ToString()));
            claims.Add(new Claim("PasswordResetRequired", userDetails.PasswordResetRequired.ToString()));
            claims.Add(new Claim("SiteCode",
                string.IsNullOrEmpty(userDetails.strHASCsiteID) ? "" : userDetails.strHASCsiteID));
            if (securityPolicy.LockoutThld != null)
                claims.Add(new Claim("ExpireDate",
                    DateTimeOffset.UtcNow.AddMinutes((double)securityPolicy.LockoutThld).ToString()));


            return claims;

        }

        private List<Claim> CreatePermissionClaims(List<UserRolesAndPermissionsViewModel> rolesandPermissions)
        {
            List<Claim> claims = new List<Claim>();
            if (rolesandPermissions != null && rolesandPermissions.Count > 0)
            {
                // Roles...
                var roles = rolesandPermissions.Select(s => s.Role).Distinct();
                foreach (var r in roles)
                {
                    claims.Add(new Claim("Role", r));
                }

                // Permissions...
                foreach (var p in rolesandPermissions)
                {
                    claims.Add(new Claim("Claim", p.PermissionLevelId.ToString() +
                                                  "|" + p.PermissionLevel.Trim() +
                                                  "|" + p.PermissionId.ToString()));
                }
            }

            return claims;
        }
    }
}
