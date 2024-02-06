using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication
{
    public class PersonDeduplicationDetailsViewModel
    {
        public long LeftHumanMasterID { get; set; }
        public long RightHumanMasterID { get; set; }
        public PersonDeduplicationInformationSectionViewModel InformationSection { get; set; }
        public PersonDeduplicationAddressSectionViewModel AddressSection { get; set; }
        public PersonDeduplicationEmploymentSectionViewModel EmploymentSection { get; set; }
    }
}
