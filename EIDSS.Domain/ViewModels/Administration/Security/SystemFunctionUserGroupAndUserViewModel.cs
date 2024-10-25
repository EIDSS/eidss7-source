using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SystemFunctionUserGroupAndUserViewModel : BaseModel
    {
        public long id { get; set; }
        public long idfsEmployeeType { get; set; }
        public string Name { get; set; }
        public string TypeName { get; set; }
    }
}
