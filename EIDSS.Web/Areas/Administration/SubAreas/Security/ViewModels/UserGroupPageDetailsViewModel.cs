using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Administration.Security.ViewModels.UserGroup;
using EIDSS.Web.Administration.ViewModels.Administration;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.UserGroup;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.Security.ViewModels
{
    public class UserGroupPageDetailsViewModel
    {
        public long? UserGroupKey { get; set; }
        public bool DeleteVisibleIndicator { get; set; }
        public string InformationalMessage { get; set; }
        public string ErrorMessage { get; set; }
        public InformationSectionViewModel InformationSection { get; set; }
        public UsersAndGroupsSectionViewModel UsersAndGroupsSection { get; set; }
        public DashboardIconsSectionViewModel DashboardIconsSection { get; set; }
        public DashboardGridsSectionViewModel DashboardGridsSection { get; set; }
        public SystemFunctionsSectionViewModel SystemFunctionsSection { get; set; }
        //public List<EmployeesForUserGroupViewModel> EmployeesForUserGroup { get; set; }
        //public EIDSSGridConfiguration EmployeesForUserGroupGridConfiguration { get; set; }
        ////public EmployeesForUserGroupGetRequestModel SearchEmployeeViewModel { get; set; }
        //public SearchEmployeeActorViewModel SearchEmployeeActorViewModel { get; set; }
        //public List<UserGroupDashboardViewModel> DashboardIcons { get; set; }
        //public List<UserGroupDashboardViewModel> DashboardGrids { get; set; }
        public Select2Configruation GridSelect2Configuration { get; set; }
        //public List<UserGroupDashboardViewModel> SelectedDashboardIcons { get; set; }
        //public string SelectedDashboardGrid { get; set; }
        //public string SelectedDashboardIcons { get; set; }
        public bool RecordSelectionIndicator { get; set; }
    }
}
