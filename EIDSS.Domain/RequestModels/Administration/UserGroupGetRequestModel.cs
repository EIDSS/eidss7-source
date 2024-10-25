using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class UserGroupGetRequestModel : BaseGetRequestModel
    {
        public string strName { get; set; }
        public string strDescription { get; set; }
        //public string user { get; set; }
        public long? idfsSite { get; set; }
    }
}
