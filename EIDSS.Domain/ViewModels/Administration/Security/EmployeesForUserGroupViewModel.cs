using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class EmployeesForUserGroupViewModel : BaseModel
    {
        public long? idfEmployeeGroup { get; set; }
        public long? idfEmployee { get; set; }
        public long? TypeID { get; set; }
        public string TypeName { get; set; }
        public string Name { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public long? idfUserID { get; set; }
        public string UserName { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
