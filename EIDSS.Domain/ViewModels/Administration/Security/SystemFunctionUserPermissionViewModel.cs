using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SystemFunctionUserPermissionViewModel:BaseModel
    {
        public long? IdfEmployee { get; set; }
        public long SystemFunctionID { get; set; }
        public string StrSystemFunction { get; set; }
        public long SystemFunctionOperationID { get; set; }
        public string StrSystemFunctionOperation { get; set; }
        public int? AccessStatus { get; set; }
        public int OperationStatus { get; set; }
    }
}
