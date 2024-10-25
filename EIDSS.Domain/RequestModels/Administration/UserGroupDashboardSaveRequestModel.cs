using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class UserGroupDashboardSaveRequestModel
    {
        public long? roleId { get; set; }
        public string strDashboardObject { get; set; }
        public string user { get; set; }
    }
}
