using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Administration
{
    public class EmployeeUserPermissionsPageViewModel
    {
        public long EmployeeID { get; set; }

        public bool IsAddEmployee { get; set; } = false;
        public List<Select2Configruation> Select2Configurations { get; set; }

        [LocalizedRequired()]
        public Select2Configruation OrganizationDD { get; set; }

        public EmployeeSaveRequestModel PersonalInformation { get; set; }

        public RegisterViewModel RegisterViewModel { get; set; }


        public long? OrganizationID { get; set; }

        
       public string OrganizationFullName { get; set; }

        public long? idfsSite { get; set; }

        public string OtherSiteName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.DepartmentFieldLabel))]
        public long? DepartmentID { get; set; }

        public string DepartmentName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PositionFieldLabel))]

        public long? PositionTypeID { get; set; }

        public string PositionTypeName { get; set; }

        public Select2Configruation UserGroupDD { get; set; }

        public long? UserGroupID { get; set; }

        public string UserGroupName { get; set; }

        public List<Select2DataItem> UserGroups { get; set; }

        //public List<long> UserGroupID { get; set; }

        //public List<string> UserGroupName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PhoneFieldLabel))]
        public string OtherContactPhone{get; set; }

        public bool isDefault { get; set; }
        /// <summary>
        /// Defines Modal For Model
        /// </summary>
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        public SystemFunctionsPagesViewModel SystemFunctionPageViewModel { get; set; }

        public bool isEditOrg = true;

        public long idfUserID { get; set; }

    }
    public class UserGroup
    {
        long UserGroupID { get; set; }

        string UserGroupName { get; set; }
    }

}
