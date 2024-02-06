using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class UserGroupViewModel : BaseModel
    {
        public long? idfEmployeeGroup { get; set; }
        public long? idfsEmployeeGroupName { get; set; }
        public string strDefault { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }
    }
}
