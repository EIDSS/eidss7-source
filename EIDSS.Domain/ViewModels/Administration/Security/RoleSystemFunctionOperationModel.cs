using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class RoleSystemFunctionOperationModel
    {
        public long RoleId { get; set; }

        public long SystemFunction { get; set; }

        public long Operation { get; set; }

        public int intRowStatus { get; set; }

        public int intRowStatusForSystemFunction { get; set; }
    }

    public class SystemFunctionsUserPermissionsSetParams
    {
        public string rolesandfunctions { get; set; }

        public long roleID { get; set; }

        public string langageId { get; set; }

        public string user { get; set; }
        public long? idfDataAuditEvent { get; set; }
    }

    public class RoleSystemFunctionModel
    {
        public long RoleId { get; set; }

        public long SystemFunction { get; set; }

    }
}
