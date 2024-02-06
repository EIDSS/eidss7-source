using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class UsergroupSystemfunctionPermissionViewModel
    {
        public long SystemFunctionID { get; set; }
        public string strSystemFunction { get; set; }
        public long SystemFunctionOperationID { get; set; }
        public string strSystemFunctionOperation { get; set; }
        public int intRowStatus { get; set; }
    }
}
