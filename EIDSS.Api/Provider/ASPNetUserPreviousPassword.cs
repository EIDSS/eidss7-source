using EIDSS.Api.Providers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Provider
{
    public class ASPNetUserPreviousPasswords
    {
        /// <summary>
        /// ASPNetUserPreviousPasswords
        /// </summary>
        public ASPNetUserPreviousPasswords()
        {
            AuditCreateDTM = DateTime.Now;
            AuditUpdateDTM = DateTime.Now;
        }

        /// <summary>
        /// 
        /// </summary>
        [Key, Column(Order = 0)]
        public long ASPNetUserPreviousPasswordsUID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// 
        [ForeignKey("ApplicationUser"), Column(Order = 1)]
        public string Id { get; set; }

        /// <summary>
        /// 
        /// </summary>
        [DataType(DataType.Password)]
        public string OldPasswordHash { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string AuditCreateUser { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public DateTime AuditCreateDTM { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string AuditUpdateUser { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public DateTime AuditUpdateDTM { get; set; }

        [ForeignKey(nameof(Id))]
        public virtual ApplicationUser ApplicationUser { get; set; }

    }
}
