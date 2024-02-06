using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Repository.ReturnModels
{
    /// <summary>
    /// Audit Events
    /// </summary>
    public partial class TauDataAuditEvent
    {
        public TauDataAuditEvent()
        {
            TauDataAuditDetailCreate = new HashSet<TauDataAuditDetailCreate>();
            TauDataAuditDetailDelete = new HashSet<TauDataAuditDetailDelete>();
            TauDataAuditDetailRestore = new HashSet<TauDataAuditDetailRestore>();
            TauDataAuditDetailUpdate = new HashSet<TauDataAuditDetailUpdate>();
        }

        /// <summary>
        /// Audit event identifier
        /// </summary>
        public long IdfDataAuditEvent { get; set; }
        /// <summary>
        /// Audit object type
        /// </summary>
        public long? IdfsDataAuditObjectType { get; set; }
        /// <summary>
        /// Audit event type
        /// </summary>
        public long? IdfsDataAuditEventType { get; set; }
        /// <summary>
        /// Main audit object identifier
        /// </summary>
        public long? IdfMainObject { get; set; }
        /// <summary>
        /// Main audit object table identifier
        /// </summary>
        public long? IdfMainObjectTable { get; set; }
        /// <summary>
        /// User caused audit event identifier
        /// </summary>
        public long? IdfUserId { get; set; }
        /// <summary>
        /// Site event created on identifier
        /// </summary>
        public long IdfsSite { get; set; }
        /// <summary>
        /// Date/time of event creation
        /// </summary>
        public DateTime? DatEnteringDate { get; set; }
        /// <summary>
        /// Host name caused event
        /// </summary>
        public string StrHostname { get; set; }
        public Guid Rowguid { get; set; }
        public DateTime? DatModificationForArchiveDate { get; set; }
        public string StrMaintenanceFlag { get; set; }
        public long? SourceSystemNameId { get; set; }
        public string SourceSystemKeyValue { get; set; }
        public string AuditCreateUser { get; set; }
        public DateTime? AuditCreateDtm { get; set; }
        public string AuditUpdateUser { get; set; }
        public DateTime? AuditUpdateDtm { get; set; }

        public virtual ICollection<TauDataAuditDetailCreate> TauDataAuditDetailCreate { get; set; }
        public virtual ICollection<TauDataAuditDetailDelete> TauDataAuditDetailDelete { get; set; }
        public virtual ICollection<TauDataAuditDetailRestore> TauDataAuditDetailRestore { get; set; }
        public virtual ICollection<TauDataAuditDetailUpdate> TauDataAuditDetailUpdate { get; set; }
    }
}
