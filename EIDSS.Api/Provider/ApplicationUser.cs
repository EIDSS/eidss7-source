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

        public ApplicationUser() : base()
        {
        }

    }

}

