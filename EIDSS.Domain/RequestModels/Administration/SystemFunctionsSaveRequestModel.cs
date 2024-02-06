using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SystemFunctionsSaveRequestModel
    {
        public string rolesandfunctions { get; set; }
        public long roleID { get; set; }

        public string langageId { get; set; }

        public string user { get; set; }
        public long? idfDataAuditEvent { get; set; }
    }

    public class RoleSystemFunctionOperation
    {
        public long? RoleId { get; set; }

        public long SystemFunction { get; set; }

        public long Operation { get; set; }

        public int intRowStatus { get; set; } = 1;
        public int intRowStatusForSystemFunction { get; set; } = 0;

    }
}
