using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SystemFunctionPersonANDEmployeeGroupViewModel : BaseModel
    {
        public long idfEmployee { get; set; }
        public long idfsEmployeeType { get; set; }
        public string EmployeeTypeName { get; set; }
        public string Name { get; set; }
        public long? idfsOfficeAbbreviation { get; set; }
        public string OrganizationName { get; set; }
        public string strDescription { get; set; }
    }
}
