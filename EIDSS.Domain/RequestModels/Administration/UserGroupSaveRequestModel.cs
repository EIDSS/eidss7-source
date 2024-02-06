using EIDSS.Domain.Attributes;
using EIDSS.Domain.ViewModels.Administration.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class UserGroupSaveRequestModel
    {
        public long? idfEmployeeGroup { get; set; }
        public long? idfsSite { get; set; }
        public string strDefault { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }
        public string langId { get; set; }
        public string strEmployees { get; set; }
        public string rolesandfunctions { get; set; }
        public string strDashboardObject { get; set; }
        public string user { get; set; }
    }
}
