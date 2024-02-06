using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class UserGroupDashboardGetRequestModel
    {
        public long? roleId { get; set; }
        public string dashBoardItemType { get; set; }
        public string langId { get; set; }
        public string user { get; set; }
    }
}
