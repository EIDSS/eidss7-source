using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class SystemFunctionsPersonAndEmpoyeeGroupDelRequestModel
    {
        public long SystemFunctionId { get; set; }
        public long UserId { get; set; }
    }
}
