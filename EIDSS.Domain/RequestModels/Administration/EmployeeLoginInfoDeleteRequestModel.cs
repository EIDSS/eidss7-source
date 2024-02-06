using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class EmployeeLoginInfoDeleteRequestModel
    {
        
        public long? idfUserId { get; set; }
       
    }
}
