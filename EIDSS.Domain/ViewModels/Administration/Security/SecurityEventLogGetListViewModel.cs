using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SecurityEventLogGetListViewModel
    {
        public long idfSecurityAudit { get; set; }
        public long idfsAction { get; set; }
        public string strActionDefaultName { get; set; }
        public string strActionNationalName { get; set; }
        public long idfsResult { get; set; }
        public string strResultDefaultName { get; set; }
        public string strResultNationalName { get; set; }
        public long idfsProcessType { get; set; }
        public string strProcessTypeDefaultName { get; set; }
        public string strProcessTypeNationalName { get; set; }
        public long idfAffectedObjectType { get; set; }
        public long idfObjectID { get; set; }
        public long? idfUserID { get; set; }
        public long? idfPerson { get; set; }
        public string strAccountName { get; set; }
        public string strPersonName { get; set; }
        public long? idfDataAuditEvent { get; set; }
        public DateTime datActionDate { get; set; }
        public string strErrorText { get; set; }
        public string strProcessID { get; set; }
        public string strDescription { get; set; }
        public int? TotalRowCount { get; set; }
        public int? TotalPages { get; set; }
    }
}
