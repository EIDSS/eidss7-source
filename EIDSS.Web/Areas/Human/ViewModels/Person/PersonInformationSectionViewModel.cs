using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.Person
{
    public class PersonInformationSectionViewModel
    {
        public DiseaseReportPersonalInformationViewModel PersonDetails { get; set; }
        public List<BaseReferenceViewModel> HumanGenderList { get; set; }
        public List<BaseReferenceViewModel> PersonalIDTypeList { get; set; }
        public List<BaseReferenceViewModel> HumanAgeTypeList { get; set; }
        public List<BaseReferenceViewModel> CitizenshipList { get; set; }
        public bool PersonIDVisibleIndicator { get; set; }
        public bool PersonalIDRequiredIndicator { get; set; }
        public bool FindInPINSystemInVisibledicator { get; set; }
        public UserPermissions PermissionsAccessToHumanDiseaseReportData { get; set; }
    }
}
