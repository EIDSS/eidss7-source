using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class EmployeeUserGroupOrgDetailsGetRequestModel
    {
        public long? idfPerson { get; set; }
        public long? idfOffice { get; set; }
        public string LangID {get;set;}

       

    }
}
