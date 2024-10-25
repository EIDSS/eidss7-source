using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class AdministrativeUnitsDetailsSectionViewModel
    {

        public long? idfsCountry { get; set; }

        [LocalizedRequiredWhenTrue(nameof(HascCodeRequired), true)]
        [LocalizedStringLength(6)]
        public string HascCode { get; set; }
        [LocalizedStringLength(200)]
        public string UniqueCode { get; set; }
        [LocalizedRequired()]
        [LocalizedStringLength(200)]
        public string DefaultName { get; set; }
        [LocalizedRequired()]
        [LocalizedStringLength(200)]
        public string NationalName { get; set; }
        public long AdminLevel { get; set; }
        public LocationViewModel EditLocationViewModel   { get; set; }
        [LocalizedRequiredWhenTrue(nameof(LanLonRequired), true)]
        public double? Latitude { get; set; }
        [LocalizedRequiredWhenTrue(nameof(LanLonRequired), true)]

        public double? Longitude { get; set; }
        public int? Elevation { get; set; }

        public bool ShowHascCode { get; set; }
        public bool DisableAdminLevel { get; set; }
        public bool HascCodeRequired { get; set; }        

        public bool UniqueCodeRequired { get; set; }

        public bool UniqueCodeDisabled { get; set; }
        public bool LanLonRequired { get; set; } = true;

        public long? IdfsLocation { get; set; }
    }
}
