using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AdminEmployeeListViewModel : BaseModel
    {
        public long EmployeeId { get; set; }
        public string FirstName { get; set; }
        public string SecondName { get; set; }
        public string FamilyName { get; set; }
        public string FullName { get; set; }
        public string Phone { get; set; }
        public string Organization { get; set; }
        public string OrganizationFullName { get; set; }
        public string OrganizationId { get; set; }
        public long? InstitutionId { get; set; }
        public long? PositionId { get; set; }

        public string Position { get; set; }
        public long? EmployeeCategory { get; set; }
        public long? AccountStateId { get; set; }


    }
}
