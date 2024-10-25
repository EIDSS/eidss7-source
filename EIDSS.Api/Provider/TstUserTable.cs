using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Providers
{
    public class TstUserTable
    {
        [Key]
        public long idfUserID { get; set; }
        public long? idfPerson { get; set; }
        public long idfsSite { get; set; }
        public DateTime? datTryDate { get; set; }
        public DateTime? datPasswordSet { get; set; }
        public string strAccountName { get; set; }
        public Byte[]? binPassword { get; set; }
        public int? intTry { get; set; }
        public int intRowStatus { get; set; }
        public Guid rowguid { get; set; }
        public string strMaintenanceFlag { get; set; }
        public bool? blnDisabled { get; set; }
        public long PreferredLanguageID { get; set; }
        public long SourceSystemNameID { get; set; }
        public string SourceSystemKeyValue { get; set; }
        public string EmailAddress { get; set; }
        public bool? EmailConfirmedFlag { get; set; }
        public string PasswordHash { get; set; }
        public bool? TwoFactorEnabledFlag { get; set; }
        public bool? LockoutEnabledFlag { get; set; }
        public DateTime? LockoutEndDTM { get; set; }
        public string AuditCreateUser { get; set; }
        public DateTime AuditCreateDTM { get; set; }
        public string AuditUpdateUser { get; set; }
        public DateTime AuditUpdateDTM { get; set; }

         public virtual ApplicationUser ApplicationUser { get; set; }
    }
}
