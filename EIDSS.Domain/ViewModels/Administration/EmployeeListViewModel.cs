using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EmployeeListViewModel : BaseModel
    {
        public long? EmployeeID { get; set; }
        public string FirstOrGivenName { get; set; }
        public string SecondName { get; set; }
        public string LastOrSurName { get; set; }
        public string EmployeeFullName { get; set; }
        public string ContactPhone { get; set; }
        public string OrganizationAbbreviatedName { get; set; }

        public string OrganizationFullName { get; set; }

        public string EIDSSOrganizationID { get; set; }

        public long? OrganizationID { get; set; }

        public string PositionTypeName { get; set; }

        public long? PositionTypeID { get; set; }

        public string AccountState { get; set; }

        public string AccountDisabled { get; set; }
        public string AccountLocked { get; set; }

        public string EmployeeCategory { get; set; }

    }
}
