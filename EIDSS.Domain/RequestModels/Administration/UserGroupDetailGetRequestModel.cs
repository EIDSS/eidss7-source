using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class UserGroupDetailGetRequestModel
    {
        public long? idfEmployeeGroup { get; set; }
        public string langId { get; set; }
        public string user { get; set; }
    }
}
