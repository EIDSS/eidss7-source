using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace EIDSS.ClientLibrary.Services
{
    public interface ICrossCuttingService
    {
        Task UpdateUserPreferencesInTokenAsync(AuthenticatedUser authenticatedUser);
        Task UpdateUserOrganizationInToken(long employeeId, long organizationId, string languageId, AuthenticatedUser authenticatedUser);
        void RefreshToken(UserOrganization organization,List<UserRolesAndPermissionsViewModel> permissions ,AuthenticatedUser authenticated);
    }

    public class CrossCuttingService:BaseService, ICrossCuttingService
    {
        private readonly IPreferenceClient _preferenceClient;
        private readonly IEmployeeClient _employeeClient;

        public CrossCuttingService(IPreferenceClient preferenceClient,  IEmployeeClient employeeClient, ILogger<CrossCuttingService> logger, IHttpContextAccessor  httpContextAccessor) : base(logger)
        {
            _preferenceClient = preferenceClient;
            _employeeClient = employeeClient;
        }

        public async Task UpdateUserPreferencesInTokenAsync(AuthenticatedUser token )
        {
            var userPreferences = await _preferenceClient.InitializeUserPreferences(Convert.ToInt64(token.EIDSSUserId));

            token.Preferences.ActiveLanguage = userPreferences.StartupLanguage;
            token.Preferences.StartupLanguage = userPreferences.StartupLanguage;
            token.Preferences.PrintMapInVetInvestigationForms = userPreferences.PrintMapInVetInvestigationForms;
            token.Preferences.DefaultMapProject = userPreferences.DefaultMapProject;
            token.Preferences.DefaultRayonInSearchPanels = userPreferences.DefaultRayonInSearchPanels;
            token.Preferences.DefaultRegionInSearchPanels = userPreferences.DefaultRegionInSearchPanels;
            token.Preferences.UserPreferencesId = userPreferences.UserPreferencesId;
            //authenticatedUser.Preferences.GridViewPreferences = sp.GridViewPreferences
        }

        public async Task UpdateUserOrganizationInToken(long employeeId, long organizationId, string languageId, AuthenticatedUser token)
        {
            var model = new EmployeesUserGroupAndPermissionsGetRequestModel()
            {
                idfPerson = employeeId,
                LangID = languageId
            };
            var userOrganizations = await _employeeClient.GetEmployeeUserGroupAndPermissions(model);

            token.UserOrganizations.Clear();
            if (userOrganizations.Count ==0)
            {
                var userOrganization = new UserOrganization()
                {
                    RowID = 1,
                    DefaultOrganizationIndicator = true,
                    EmployeeID = Convert.ToInt64(token.PersonId),
                    OrganizationID = token.OfficeId,
                    OrganizationName = token.Organization,
                    StrOrganizationID = token.OfficeId.ToString(),
                    OrganizationFullName = token.OrganizationFullName,
                    SiteGroupID = string.IsNullOrEmpty(token.SiteGroupID) ? (long?)null/* TODO Change to default(_) if this is not a reference type */: System.Convert.ToInt64(token.SiteGroupID),
                    SiteID = Convert.ToInt64(token.SiteId),
                    SiteTypeID = Convert.ToInt64(token.SiteTypeId),
                    UserGroup = token.RoleMembership.Count ==0? null:token.RoleMembership[0]                   
                };

                token.UserOrganizations.Add(userOrganization);

            }
            else
            {
                foreach (var organization in userOrganizations.Where(o=>o.Active==true))
                {
                    if (token.UserOrganizations.Find(x => x.OrganizationID == organization.OrganizationID) != null)
                    {
                        continue;
                    }

                    var userOrganization = new UserOrganization()
                    {
                        RowID = organization.Row.Value,
                        DefaultOrganizationIndicator = organization.IsDefault.Value? organization.IsDefault.Value:false,
                        EmployeeID = Convert.ToInt64( organization.idfEmployee),
                        OrganizationID = Convert.ToInt64( organization.OrganizationID),
                        OrganizationName = organization.Organization,
                        StrOrganizationID = organization.OrganizationID.ToString(),
                        OrganizationFullName = organization.OrganizationFullName,
                        SiteGroupID = organization.SiteGroupID,
                        SiteID = Convert.ToInt64( organization.idfsSite),
                        SiteTypeID = Convert.ToInt64( organization.SiteTypeID),
                        UserGroup = organization.UserGroup
                    };

                    if (userOrganization.OrganizationID == organizationId)
                        userOrganization.CurrentOrganizationIndicator = true;
                    else
                        userOrganization.CurrentOrganizationIndicator = false;

                    
                    token.UserOrganizations.Add(userOrganization);
                    if (organizationId == userOrganization.OrganizationID)
                    {
                        token.PersonId = organization.idfEmployee.ToString();
                        token.EIDSSUserId = organization.idfUserID.ToString();
                    }
                }
            }
        }


        public void RefreshToken(UserOrganization organization, List<UserRolesAndPermissionsViewModel> permissions, AuthenticatedUser authenticatedUser)
        {
            authenticatedUser.Institution = organization.OrganizationID.ToString();
            authenticatedUser.OfficeId = organization.OrganizationID;
            authenticatedUser.Organization = organization.OrganizationName;
            authenticatedUser.OrganizationFullName = organization.OrganizationFullName;
            authenticatedUser.SiteId = organization.SiteID.ToString();
            authenticatedUser.SiteTypeId = organization.SiteTypeID;
            authenticatedUser.SiteGroupID = organization.SiteGroupID.ToString();

            var permissionsDistinct = permissions.GroupBy(item => item.PermissionId).Select(grp => grp.First()).ToList();
            foreach (var permission in permissionsDistinct)
            {
                var permissionsForPermissionLevels = permissions.Where(item => item.PermissionId == permission.PermissionId);
                var permissionLevels = new List<PermissionLevel>();
                foreach (var permissionForPermissionLevel in permissionsForPermissionLevels)
                {
                    permissionLevels.Add(new PermissionLevel(Convert.ToInt64(permissionForPermissionLevel.PermissionLevelId), permissionForPermissionLevel.PermissionLevel));
                };

                var x = new Permission
                {
                    PermissionId = Convert.ToInt64(permission.PermissionId),
                    PermissionType = permission.Permission,
                    PermissionLevels = permissionLevels
                };
                authenticatedUser.Claims.Add(x);
                permissions.RemoveAll(item => item.PermissionId == permission.PermissionId);
            }



        }
        //public void UpdateAccessRulesAndPermissionsInToken(AuthenticatedUser token)
        //{
        //    var permissions = _cro.GetAccessRulesAndPermissions(token.EIDSSUserId.ToInt64).Result;
        //    AccessRulePermission accessRuleAndPermission;
        //    foreach (var permission in permissions)
        //    {
        //        accessRuleAndPermission = new AccessRulePermission()
        //        {
        //            AccessRuleID = permission.AccessRuleID,
        //            AccessToGenderAndAgeDataPermissionIndicator = permission.AccessToGenderAndAgeDataPermissionIndicator,
        //            AccessToPersonalDataPermissionIndicator = permission.AccessToPersonalDataPermissionIndicator,
        //            DeletePermissionIndicator = permission.DeletePermissionIndicator,
        //            ReadPermissionIndicator = permission.ReadPermissionIndicator,
        //            WritePermissionIndicator = permission.WritePermissionIndicator,
        //            SiteID = permission.SiteID
        //        };

        //        token.AccessRulePermissions.Add(accessRuleAndPermission);
        //    }
        //}
    }
}