using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{
    public class FarmInfoSectionViewModel
    {

        public  long? FarmID { get; set; }
        public bool FarmAvian { get; set; }
        public bool FarmLivestock { get; set; }
        public string FarmName { get; set; }
        public string FarmOwnner { get; set; }
        public string FarmPhone { get; set; }
        public string FarmFax { get; set; }
        public string FarmEmail { get; set; } 
        public AddressSectionViewModel AddressSection { get; set; }
        public LocationViewModel DetailsLocationViewModel { get; set; }

    }
}
