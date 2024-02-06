using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
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
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Administration
{
    public class EmployeePersonalInfoPageViewModel : BaseModel
    {

        //public EmployeePersonalInfoPageViewModel()
        //{
        //    EmployeeCategoryList = new Dictionary<string, string>();
        //}



        [LocalizedRequired()]
        public Select2Configruation OrganizationDD { get; set; }

        [LocalizedRequired()]
        public Select2Configruation PersonalIdTypeDD { get; set; }

        public Select2Configruation SiteDD { get; set; }

        public Select2Configruation DepartmentDD { get; set; }


        public Select2Configruation PositionDD { get; set; }

        public List<Select2Configruation> Select2Configurations { get; set; }

        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        //public Dictionary<string, string> EmployeeCategoryList { get; set; }
        public List<BaseReferenceViewModel> EmployeeCategoryList { get; set; }

        public long EmployeeID { get; set; }

        [LocalizedRequired()]
        public string EmployeeCategory { get; set; }

        //[LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PersonalIDTypeFieldLabel))]
        [LocalizedRequired()]

        public long? idfsEmployeeCategory { get; set; }
        public long? PersonalIDType { get; set; }

        public string PersonalIDTypeName { get; set; }

        [StringLength(100)]
        [LocalizedRequiredWhenOtherValueNotPresent(nameof(PersonalIDType), "PersonalInfoSection_PersonalIDType", (long)PersonalIDTypeEnum.Unknown)]
        public string PersonalID { get; set; }

        [LocalizedRequired()]
        [LocalizedStringLength(200)]
        public string FirstOrGivenName { get; set; }

        [LocalizedStringLength(200)]
        public string SecondName { get; set; }

        [LocalizedRequired()]
        [LocalizedStringLength(200)]
        public string LastOrSurName { get; set; }
        public string EmployeeFullName { get; set; }

        public long? OrganizationID { get; set; }
        public string AbbreviatedName { get; set; }

        public long SiteID { get; set; }
        public string SiteName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.DepartmentFieldLabel))]
        public long? DepartmentID { get; set; }
        public string DepartmentName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PositionFieldLabel))]
        public long? PositionTypeID { get; set; }

        public string PositionTypeName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.PhoneFieldLabel))]
        public string ContactPhone { get; set; }

        

        public UserPermissions CanManageReferencesandConfiguratuionsPermission { get; set; }

        public UserPermissions CanAccessOrganizationsList { get;set;}


    }
}
