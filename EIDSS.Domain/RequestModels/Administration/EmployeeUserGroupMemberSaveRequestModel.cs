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
    public class EmployeeUserGroupMemberSaveRequestModel
    {
        public string idfEmployeeGroups { get; set; }

        public long? idfEmployee { get; set; }

        public int? intRowStatus { get; set; }

       
        
    }
}
