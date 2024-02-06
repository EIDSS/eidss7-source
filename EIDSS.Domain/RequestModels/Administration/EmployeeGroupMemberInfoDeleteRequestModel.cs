using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class EmployeeGroupMemberDeleteRequestModel
    {

        public string idfEmployeeGroups { get; set; }

        public long? idfEmployee { get; set; }
        
    }
}
