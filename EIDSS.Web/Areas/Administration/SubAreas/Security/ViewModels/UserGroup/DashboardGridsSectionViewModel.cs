using EIDSS.Domain.ViewModels.Administration.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.Security.ViewModels.UserGroup
{
    public class DashboardGridsSectionViewModel
    {
        public List<UserGroupDashboardViewModel> DashboardGrids { get; set; }
        public string SelectedDashboardGrid { get; set; }
    }
}
