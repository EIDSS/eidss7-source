using EIDSS.ClientLibrary.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Text.Json.Serialization;
using EIDSS.Domain.ViewModels;

namespace EIDSS.ClientLibrary.Responses
{
    [DataContract]
    public class AuthenticatedUser
    {
        #region Fields
        
        IUserConfigurationService _userConfigurationService;

        #endregion
        #region Properties


        /// <summary>
        /// The authorization bearer token. 
        /// </summary>
        
        public virtual string Active { get; set; }

        /// <summary>
        /// The authorization bearer token. 
        /// </summary>
        [DataMember(Name = "access_token")]
        public virtual string AccessToken { get;  set; }

        public virtual string RefreshToken { get;  set; }

        public bool IsInArchiveMode { get; set; }
        public string ArchiveMenuName { get; set; } 

        /// <summary>
        /// A string representing the ASPNet Identity identifier for the logged in user.
        /// </summary>
        [DataMember]
        public virtual string ASPNetId { get; private set; }

        /// <summary>
        /// An integer representing the EIDSS Userid for the logged in user.
        /// </summary>
        [DataMember]
        public virtual string EIDSSUserId { get;  set; } 

        /// <summary>
        /// The logged in users email address.  This value is not required by the system and may be null.
        /// </summary>
        [DataMember]
        public virtual string Email { get; private set; }

        /// <summary>
        /// Date and time the token expires in universal time (GMT).
        /// </summary>
        [DataMember(Name = ".expires")]
        public virtual DateTime ExpireDate { get; internal set; }

        /// <summary>
        /// Indicates the expiry of the token (in seconds).
        /// </summary>
        [DataMember(Name = "expires_in")]
        public virtual int ExpireSeconds { get; private set; }

        /// <summary>
        /// The firstname of the logged in user.
        /// </summary>
        [DataMember]
        public virtual string FirstName { get; private set; }

        /// <summary>
        /// An integer representing the institution (organization) of the logged in user.
        /// </summary>
        [DataMember]
        public virtual string Institution { get; internal set; }

        /// <summary>       
        /// Date and time the token was issued in universal time (GMT).
        /// </summary>
        [DataMember(Name = ".issued")]
        public virtual DateTime IssueDate { get; private set; }

        /// <summary>
        /// An integer representing the EIDSS person/employee identifier of the logged in user.
        /// </summary>
        [DataMember]
        public virtual string PersonId { get;  set; }

        /// <summary>
        /// The lastname of the logged in user.
        /// </summary>
        [DataMember]
        public virtual string LastName { get; private set; }

         /// <summary>
        /// An integer representing the office (location) of the logged in user.
        /// </summary>
        [DataMember]
        public virtual long OfficeId { get; internal set; }

        /// <summary>
        /// An integer representing the organization (institution) of the logged in user. 
        /// </summary>
        [DataMember]
        public virtual string Organization { get; internal set; }

        /// <summary>
        /// An integer representing the organizationFullName (institution) of the logged in user. 
        /// </summary>
        [DataMember]
        public virtual string OrganizationFullName { get; internal set; }


        /// <summary>
        /// A boolean value indicating whether this user's password requires a reset.
        /// </summary>
        [DataMember]
        public virtual bool PasswordResetRequired { get; internal set; }

        /// <summary>
        /// An integer representing the Rayon identifer for the logged in user.
        /// </summary>
        [DataMember]
        public virtual long RayonId { get; private set; }

        /// <summary>
        /// An integer representing the Region identifier for the logged in user.
        /// </summary>
        [DataMember]
        public virtual long RegionId { get; private set; }
        /// <summary>
        /// The logged in users middlename.  
        /// </summary>
        [DataMember]
        public virtual string SecondName { get; private set; }

        /// <summary>
        /// Identifier for the logged in user's site group ID, if the user's site 
        /// is associated with a site group.  Used in site filtration.
        /// </summary>
        [DataMember]
        public virtual string SiteGroupID { get; internal set; }

        /// <summary>
        /// An integer that represents the site of the logged in user.
        /// </summary>
        [DataMember]
        public virtual string SiteId { get; internal set; }

        /// <summary>
        /// An integer that represents the site of the logged in user.
        /// </summary>
        [DataMember]
        public virtual string SiteCode { get; internal set; }

        /// <summary>
        /// An integer that represents the site type identifier for the site of the logged in user.
        /// Site types include: first-level, second-level, third-level, etc.
        /// </summary>
        [DataMember]
        public virtual long SiteTypeId { get; internal set; }

        /// <summary>
        /// A string indicating the type of token this is.
        /// </summary>
        [DataMember(Name = "token_type")]
        public virtual string TokenType { get; private set; }

        /// <summary>
        /// The user for which the token is assigned.
        /// </summary>
        [DataMember(Name = "userName")]
        public virtual string UserName { get; private set; }

        /// <summary>
        /// LockoutThld
        /// </summary>
        [DataMember(Name = "LockoutThld")]
        public virtual string LockoutThld { get; private set; }

        /// <summary>
        ///Lockout.
        /// </summary>
        [DataMember(Name = "MaxSessionLength")]
        public virtual string MaxSessionLength { get;  set; }

        /// <summary>
        /// SessionInactivity
        /// </summary>
        [DataMember(Name = "InactivityTimeOut")]
        public virtual string InactivityTimeOut { get;  set; }

        /// <summary>
        ///Lockout.
        /// </summary>
        [DataMember(Name = "DisplaySessionInactivity")]
        public virtual string DisplaySessionInactivity { get; set; }

        /// <summary>
        /// DisplaySessionInactivity
        /// </summary>
        [DataMember(Name = "DisplaySessionCloseOut")]
        public virtual string DisplaySessionCloseOut { get; set; }

        public virtual bool ChangesPendingSave { get; set; }

        /// <summary>
        /// User preferences
        /// We need to get user preferences from the database.
        /// </summary>
        [IgnoreDataMember]
        public virtual UserPreferences Preferences { get; internal set; }

        public virtual string DefaultCountry { get; set; }
        public virtual int AdminLevels { get; set; }
        public virtual long? Adminlevel0 { get; set; }
        public virtual long? Adminlevel1 { get; set; }
        public virtual long? Adminlevel2 { get; set; }
        public virtual long? Adminlevel3 { get; set; }
        public virtual long? Adminlevel4 { get; set; }
        public virtual long? Adminlevel5 { get; set; }
        public virtual long? Adminlevel6 { get; set; }
        public virtual long BottomAdminLevel { get; set; }

        public virtual long? Settlement { get; set; }


        /// <summary>
        /// Permissions a user is granted at other sites.
        /// </summary>
        public virtual List<AccessRulePermission> AccessRulePermissions { get; private set; } = new List<AccessRulePermission>();

        /// <summary>
        /// Organizations a user is employed with.
        /// </summary>
        public virtual List<UserOrganization> UserOrganizations { get; private set; } = new List<UserOrganization>();

        public virtual List<string> RoleMembership { get; set; } = new List<string>();

        public virtual List<Permission> Claims { get; set; } = new List<Permission>();

        /// <summary>
        /// Returns a permission given the permission identifier
        /// </summary>
        /// <param name="permission"></param>
        /// <returns></returns>
        public virtual Permission Permission(PagePermission permission)
            => Claims.FirstOrDefault(c => c.PermissionId == Convert.ToInt64(permission));

        /// <summary>
        /// Return a Permission that has the Permission Type.
        /// </summary>
        [Obsolete("This function will be deprecated, use Permission function that accepts the PermissionEnum", false)]
        public Permission Permission(string permissionType)
        {
            // Perform a case insensitive search and remove the spaces...
            Permission result =
                (from perms in Claims
                 where string.Equals(perms.PermissionType.Replace(" ", ""),
                     permissionType.Replace(" ", ""), StringComparison.OrdinalIgnoreCase) == true
                 select perms).FirstOrDefault();


            return result;
        }

        /// <summary>
        /// Return if a user has a particular Permission Level
        /// </summary>
        [Obsolete("This function will be deprecated, use the UserHasPermission function that accepts enumerators", false)]
        public Boolean UserHasPermission(string permissionType, long level)
        {
            Permission permission = this.Permission(permissionType);

            if (permission == null)
                return false;
            else
                return permission.PermissionLevels.Any(item => item.PermissionLevelId == level);
        }

        /// <summary>
        /// Checks to see if the user has access to the permission.
        /// </summary>
        /// <param name="permission"></param>
        /// <param name="level"></param>
        /// <returns></returns>
        public virtual Boolean UserHasPermission(PagePermission permission, PermissionLevelEnum level)
        {
            Permission p = this.Permission(permission);
            if (p == null) return false;

            return p.PermissionLevels.Any(i => i.PermissionLevelId == Convert.ToInt64(level));
        }


        #endregion

        /// <summary>
        /// Instantiates a new instance of the class.  
        /// This class should only be instantiated by the EIDSS infrastructure and the testing framework.
        /// DO NOT DIRECTLY INSTANTIATE THIS CLASS VIA CODE!
        /// </summary>
        public AuthenticatedUser( IUserConfigurationService userConfigurationService)
        {
            _userConfigurationService = userConfigurationService;
             Preferences =new UserPreferences(userConfigurationService);
        }


        /// <summary>
        /// Returns the entire list of the logged in user's permissions.
        /// </summary>
        /// <returns></returns>
        public virtual List<Permission> GetPermissions()
        {
            return Claims;
        }

        /// <summary>
        /// Determines if the user has been assigned to any of the given roles.
        /// </summary>
        /// <param name="roles"></param>
        /// <returns></returns>
        public virtual bool IsInAnyRole(List<RoleEnum> roles)
        {
            // convert the list of enums to list of strings...
            List<string> r = new List<string>();
            roles.ForEach(a => r.Add(a.ToEnumString()));

            // Get the exceptions of the two lists...
            // If the exception list is empty, this means the user is assigned all of the passed in roles...
            // If the list contains any items, the user hasn't been assigned all roles.
            return RoleMembership.Except(r).Any();
        }

        /// <summary>
        /// Determines if the logged in user has been assigned the specified role.
        /// </summary>
        /// <param name="role"></param>
        /// <returns></returns>
        public virtual bool IsInRole(RoleEnum role)
        {
            var r = role.ToEnumString().Replace(" ", string.Empty).ToLower();

            // case insensitive compare...
            var ret = RoleMembership.Where(a => a.Replace(" ", string.Empty).ToLower() == r);

            return !(ret == null || ret.Count() == 0);
        }

        /// <summary>
        /// Determines if the logged in has been assigned to all of the given roles.
        /// </summary>
        /// <param name="roles"></param>
        /// <returns></returns>
        public virtual bool IsInRole(List<RoleEnum> roles)
        {
            // convert the list of enums to list of strings...
            List<string> r = new List<string>();
            roles.ForEach(a => r.Add(a.ToEnumString()));

            // Get the exceptions of the two lists...
            // If the exception list is empty, this means the user is assigned all of the passed in roles...
            // If the list contains any items, the user hasn't been assigned all roles.
            return !RoleMembership.Except(r).Any();

        }


    }
}
