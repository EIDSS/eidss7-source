using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Repository.ReturnModels
{
    /// <summary>
    /// Object Deletion Audit 
    /// </summary>
    public partial class TauDataAuditDetailDelete
    {
        /// <summary>
        /// Audit event identifier
        /// </summary>
        public long? IdfDataAuditEvent { get; set; }
        /// <summary>
        /// Table identifier
        /// </summary>
        public long? IdfObjectTable { get; set; }
        /// <summary>
        /// Object identifier
        /// </summary>
        public long? IdfObject { get; set; }
        /// <summary>
        /// Corresponding Deleted object identifier
        /// </summary>
        public long? IdfObjectDetail { get; set; }
        public Guid IdfDataAuditDetailDelete { get; set; }
        public string StrMaintenanceFlag { get; set; }
        public long? SourceSystemNameId { get; set; }
        public string SourceSystemKeyValue { get; set; }
        public string AuditCreateUser { get; set; }
        public DateTime? AuditCreateDtm { get; set; }
        public string AuditUpdateUser { get; set; }
        public DateTime? AuditUpdateDtm { get; set; }

        public virtual TauDataAuditEvent IdfDataAuditEventNavigation { get; set; }
    }
}
