using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Administration
{
    public class SystemFunctionsPagesViewModel
    {
        public string UserIDAndUserGroups { get; set; }

        public long EmployeeID { get; set; }

        public bool isChange { get; set;}= false;

        //public long SiteID { get; set; }
        //public List<PermissionViewModel> HeaderPermissions { get; set; }
        //public List<SystemFunctionPermissionsViewModel> SystemFunctionPermissionsViewModel { get; set; }
        //public List<Select2Configruation> Select2Configurations { get; set; }

        EIDSSGridConfiguration _gridViewComponentBuilder;

        ///// <summary>
        ///// Defines The Grid for the Model
        ///// </summary>
        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }

        ///// <summary>
        ///// Defines Modal For Model
        ///// </summary>
        // public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        public List<SystemFunctionPermissionsPageViewModel> PermissionViewModel = new List<SystemFunctionPermissionsPageViewModel>();
        //public long? RoleID { get; set; }
        //public long SystemFunctionId { get; set; }
        //public string Permission { get; set; }
        //public bool HasReadPermission { get; set; } = false;
        //public int? ReadPermission { get; set; } = 0;
        //public bool HasWritePermission { get; set; } = false;
        //public int? WritePermission { get; set; } = 0;
        //public bool HasCreatePermission { get; set; } = false;
        //public int? CreatePermission { get; set; } = 0;
        //public bool HasExecutePermission { get; set; } = false;
        //public int? ExecutePermission { get; set; } = 0;
        //public bool HasDeletePermission { get; set; } = false;
        //public int? DeletePermission { get; set; } = 0;

        //public bool HasAccessToPersonalDataPermission { get; set; } = false;
        //public int? AccessToPersonalDataPermission { get; set; } = 0;
        //public bool HasAccessToGenderAndAgeDataPermission { get; set; } = false;
        //public int? AccessToGenderAndAgeDataPermission { get; set; } = 0;
    }
}
