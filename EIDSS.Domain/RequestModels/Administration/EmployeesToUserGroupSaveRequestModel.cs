using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EmployeesToUserGroupSaveRequestModel
    {
        public long? idfEmployeeGroup { get; set; }

        public string strEmployees { get; set; }
        public string user { get; set; }
    }
}
