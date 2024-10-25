using EIDSS.Domain.ViewModels.Administration.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.Security.ViewModels.UserGroup
{
    public class DashboardIconsSectionViewModel
    {
        public List<UserGroupDashboardViewModel> DashboardIcons { get; set; }
        public List<UserGroupDashboardViewModel> SelectedDashboardIcons { get; set; }
    }
}
