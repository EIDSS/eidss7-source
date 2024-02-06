using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Repository.ReturnModels
{
    /// <summary>
    /// Object Change Audit 
    /// </summary>
    public partial class TauDataAuditDetailUpdate
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
        /// Changed column identifier
        /// </summary>
        public long? IdfColumn { get; set; }
        /// <summary>
        /// Object identifier
        /// </summary>
        public long? IdfObject { get; set; }
        /// <summary>
        /// Corresponding Changed object identifier
        /// </summary>
        public long? IdfObjectDetail { get; set; }
        /// <summary>
        /// Old value
        /// </summary>
        public object StrOldValue { get; set; }
        /// <summary>
        /// New value
        /// </summary>
        public object StrNewValue { get; set; }
        public Guid IdfDataAuditDetailUpdate { get; set; }
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
