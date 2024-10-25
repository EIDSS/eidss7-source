using EIDSS.Domain.Attributes;
using EIDSS.Domain.ViewModels.Administration.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class AuditRestoreRequestModel
    {
        public long UserId { get; set; }
        public long SiteId { get; set; }
        public long IdfDataAuditEvent { get; set; }
    }
}
