using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{
    public class AddressSectionViewModel
    {
        public string Region { get; set; }

        public string Rayon { get; set; }

        public string SettlementType { get; set; }

        public string Settlement { get; set; }

        public string StreetAddress { get; set; }

        public string HouseAddress { get; set; }

        public string BuildingAddress { get; set; }

        public string BuildingApartement { get; set; }

        public string PostalCode { get; set; }

        public long? Latitude { get; set; }
        public long?  Longitude { get; set; }

        public LocationViewModel SearchLocationViewModel { get; set; }

        public DateTime? DateEntered;
        public DateTime? DateModified;

        public string FarmDateEntered;
        public string FarmDateModified;

        public string AddressDateEntered { get; set; }
        public string AddressDateModified { get; set; }

    }
}
