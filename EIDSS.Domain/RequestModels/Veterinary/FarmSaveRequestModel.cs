using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Auditing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FarmSaveRequestModel
    {
        public long? FarmMasterID { get; set; }

        public long? AvianFarmTypeID { get; set; }

        public long? AvianProductionTypeID { get; set; }

        public long? FarmCategory { get; set; }

        public long? FarmOwnerID { get; set; }


        public long? FarmTypeID { get; set; }

        public string FarmNationalName { get; set; }

        public string FarmInterNationalName { get; set; }

        public string EIDSSFarmID { get; set; }

        public long? OwnershipStructureTypeID { get; set; }


        public string Fax { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        public long? FarmAddressID { get; set; }

        public bool? ForeignAddressIndicator { get; set; }

        public long? FarmAddressIdfsLocation { get; set; }

        public string FarmAddressStreet { get; set; }

        public string FarmAddressApartment { get; set; }

        public string FarmAddressBuilding { get; set; }

        public string FarmAddressHouse { get; set; }

        public string FarmAddressPostalCode { get; set; }


        public double? FarmAddressLatitude { get; set; }

        public double? FarmAddressLongitude { get; set; }

        public int? NumberOfBuildings { get; set; }

        public int? NumberOfBirdsPerBuilding { get; set; }


        public string HerdsOrFlocks { get; set; }

        public string Species { get; set; }

        public string AuditUser { get; set; }


    }
}
