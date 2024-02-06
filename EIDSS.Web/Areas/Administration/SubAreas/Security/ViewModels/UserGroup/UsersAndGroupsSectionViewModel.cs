using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Administration.ViewModels.Administration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.Security.ViewModels.UserGroup
{
    public class UsersAndGroupsSectionViewModel
    {
        public long? idfEmployeeGroup { get; set; }
        public List<EmployeesForUserGroupViewModel> EmployeesForUserGroup { get; set; }
        public EIDSSGridConfiguration EmployeesForUserGroupGridConfiguration { get; set; }
        public SearchEmployeeActorViewModel SearchEmployeeActorViewModel { get; set; }
        public UserPermissions UserGroupPermissions { get; set; }
        public IList<EmployeesForUserGroupViewModel> UsersAndGroupsToSave { get; set; }
    }
}
