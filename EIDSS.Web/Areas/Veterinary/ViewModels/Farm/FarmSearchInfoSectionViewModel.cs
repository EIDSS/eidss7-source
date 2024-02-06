using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{
    public class FarmSearchInfoSectionViewModel
    {
        public Select2Configruation AccessoryCodes { get; set; }
        public Select2Configruation OrganizationTypes { get; set; }
        public Select2Configruation OwnershipFormTypes { get; set; }
        public Select2Configruation LegalFormTypes { get; set; }
        public Select2Configruation MainFormOfActivityTypes { get; set; }
        public LocationViewModel DetailsLocationViewModel { get; set; }
        public List<CountryModel> CountryList { get; set; }
      

    }
}
