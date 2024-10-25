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
    public class EmployeeAccountManagementPageViewModel
    {
        public long EmployeeID { get; set; }

        public bool IsEdit { get; set; } = false;
       
        //public bool ?Locked { get; set; }

        public bool Disabled { get; set; }

        public string Reason { get; set; }

        public bool blnLocked { get; set; }

        public bool blnDisabled { get; set; }

        public bool Active { get; set; }

        public string strLockoutReason { get; set; }
        public string strAccountDisabled { get; set; }


        public List<Select2Configruation> Select2Configurations { get; set; }
        EIDSSGridConfiguration _gridViewComponentBuilder;

        /// <summary>
        /// Defines The Grid for the Model
        /// </summary>
        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }

        /// <summary>
        /// Defines Modal For Model
        /// </summary>
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        public EmployeeUserPermissionsPageViewModel EmployeeUserPermissionsPageViewModel { get; set; }


        public List<EmployeeUserGroupsAndPermissionsViewModel> UserGroupsAndPermissions { get; set; }


        public UserPermissions UserPermissions { get; set; }

    }
}
