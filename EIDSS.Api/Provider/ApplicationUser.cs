using EIDSS.Api.Provider;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace EIDSS.Api.Providers
{
    public class ApplicationUser : IdentityUser
    {

        #region New Column(s) (Properties)

        /// <summary>
        /// EIDSS User identifier
        /// </summary>

        [ForeignKey("ApplicationUser")]
        public long idfUserID { get; set; }
       
        /// <summary>
        /// Disable a user account.
        /// </summary>
        public bool? blnDisabled { get; set; }

        /// <summary>
        /// Reason account was disabled
        /// </summary>
        [MaxLength(256)]
        public string strDisabledReason { get; set; }

        /// <summary>
        /// Date password last changed
        /// </summary>
        public DateTime? datPasswordLastChanged { get; set; }

        /// <summary>
        /// When set to true indicates that at the next logon, the user is required to change his password
        /// </summary>
        public bool PasswordResetRequired { get; set; }

        /// <summary>
        /// User password history
        /// </summary>
        ///
        public virtual IList<ASPNetUserPreviousPasswords> PasswordHistory { get; set; }

        [ForeignKey(nameof(idfUserID))]
        public virtual TstUserTable TstUserTable { get; set; }




        #endregion

        /// <summary>
        /// 
        /// </summary>
        public ApplicationUser() : base()
        {
            // Instantiate password history...
            //PasswordHistory = new List<ASPNetUserPreviousPassword>();
            
        }


        //public async Task GenerateUserIdentityAsync(UserManager<ApplicationUser> userManager, ApplicationUser user)
        //{
        //    var userIdentity = await userManager.GetClaimsAsync(this);

        //    var user = userManager.Users.Where(w => w.UserName == this.NormalizedUserName.Name).FirstOrDefault();
        //    var roles = ModelFactory.GetUserRolesAndPermissions(user.idfUserID, user.UserName);

        //    // Add custom user claims here
        //    if (roles != null && roles.Count > 0)
        //        roles.ForEach(r => userIdentity.AddClaim(new Claim(ClaimTypes.UserData, String.Format("{0}.{1}", new string[] { r.PermissionId.ToString().Trim(), r.PermissionLevel.ToString() }))));

        //    return userIdentity;

        //    var identity = new ClaimsIdentity(CookieAuthenticationDefaults.AuthenticationScheme);

        //    identity.AddClaim(new Claim(ClaimTypes.Name, this.UserName));


        //    return identity;
        //}

        ///// <summary>
        ///// Creates an identity object for a user.
        ///// </summary>
        ///// <param name="manager"></param>
        ///// <param name="authenticationType"></param>
        ///// <returns></returns>
        //public async Task<ClaimsIdentity> GenerateUserIdentityAsync(UserManager<ApplicationUser> manager, string authenticationType)
        //{
        //    // Note the authenticationType must match the one defined in CookieAuthenticationOptions.AuthenticationType
        //    var userIdentity = await manager.CreateAsync(this, authenticationType);


        //    //var user = manager.Users.Where(w => w.UserName == userIdentity.Name).FirstOrDefault();
        //    //var roles = ModelFactory.GetUserRolesAndPermissions(user.idfUserID, user.UserName);

        //    //// Add custom user claims here
        //    //if (roles != null && roles.Count > 0)
        //    //    roles.ForEach(r => userIdentity.AddClaim(new Claim(ClaimTypes.UserData, String.Format("{0}.{1}", new string[] { r.PermissionId.ToString().Trim(), r.PermissionLevel.ToString() }))));

        //    return userIdentity;
        //}
    }

}

