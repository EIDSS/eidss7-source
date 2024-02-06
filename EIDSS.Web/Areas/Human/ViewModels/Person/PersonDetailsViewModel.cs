using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.Person
{
    public class PersonDetailsViewModel
    {
        public long? HumanMasterID { get; set; }
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public bool IsReview { get; set; }
        //public bool PersonIDVisibleIndicator { get; set; }
        //public bool PersonalIDRequiredIndicator { get; set; }
        //public bool FindInPINSystemInVisibledicator { get; set; }
        //public DiseaseReportPersonalInformationViewModel PersonDetails { get; set; }
        public PersonInformationSectionViewModel PersonInformationSection { get; set; }
        public PersonAddressSectionViewModel PersonAddressSection { get; set; }
        public PersonEmploymentSchoolViewModel PersonEmploymentSchoolSection { get; set; }
        public int StartIndex { get; set; } = 0;
    }
}
