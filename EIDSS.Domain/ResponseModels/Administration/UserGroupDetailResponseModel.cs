using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class UserGroupDetailResponseModel
    {
        public long idfEmployeeGroup { get; set; }
        public long? idfsEmployeeGroupName { get; set; }
        public string strGroupName { get; set; }
        public string strNationalGroupName { get; set; }
        public long idfsSite { get; set; }
        public string strSiteID { get; set; }
        public string strDescription { get; set; }
    }
}
