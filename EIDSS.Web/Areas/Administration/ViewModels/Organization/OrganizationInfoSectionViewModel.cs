using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Administration.ViewModels.Organization
{
    public class OrganizationInfoSectionViewModel
    {
        public Select2Configruation AccessoryCodes { get; set; }
        public Select2Configruation OrganizationTypes { get; set; }
        public Select2Configruation OwnershipFormTypes { get; set; }
        public Select2Configruation LegalFormTypes { get; set; }
        public Select2Configruation MainFormOfActivityTypes { get; set; }
        public LocationViewModel DetailsLocationViewModel { get; set; }
        public List<CountryModel> CountryList { get; set; }
        public long? ForeignOrganizationCountryID { get; set; }
        public OrganizationGetDetailViewModel OrganizationDetails { get; set; }
    }
}
