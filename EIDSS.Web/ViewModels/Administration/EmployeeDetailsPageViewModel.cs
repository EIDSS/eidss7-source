using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Administration
{
    public class EmployeeDetailsPageViewModel
    {
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }

        public long EmployeeID { get; set; }

        public bool IsEditEmployee { get; set; } = false;

        public bool IsAddEmployee { get; set; } = false;

        public string EmployeeCategory { get; set; }
        public List<Select2Configruation> Select2Configurations { get; set; }

        public EmployeePersonalInfoPageViewModel PersonalInfoSection { get; set; }

        public EmployeeAccountManagementPageViewModel AccountManagementSection { get; set; }

        public EmployeeLoginViewModel LoginSection { get; set; }
        public UserPermissions UserPermissions { get; set; }

        public SystemFunctionsPagesViewModel SystemFunctionPageViewModel { get; set; }

    }
}
