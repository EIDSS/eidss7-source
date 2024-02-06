using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.Person
{
    public class PersonAddressSectionViewModel
    {
        public DiseaseReportPersonalInformationViewModel PersonDetails { get; set; }
        public LocationViewModel CurrentAddress { get; set; }
        public LocationViewModel AlternateAddress { get; set; }
        public LocationViewModel PermanentAddress { get; set; }
        //public Dictionary<string, string> IsAnotherAddressList { get; set; }
        public List<BaseReferenceViewModel> PhoneTypeList { get; set; }
        public List<BaseReferenceViewModel> Phone2TypeList { get; set; }
        //public Dictionary<string, string> IsAnotherPhoneList { get; set; }
        public List<CountryModel> HumanCountryList { get; set; }
        public long? HumanAltForeignidfsCountry { get; set; }
    }
}
