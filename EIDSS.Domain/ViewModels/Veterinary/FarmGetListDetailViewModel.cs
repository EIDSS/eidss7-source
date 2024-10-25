using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Veterinary
{
  public  class FarmGetListDetailViewModel
    {
        public FarmGetListDetailViewModel ShallowCopy() => (FarmGetListDetailViewModel)MemberwiseClone();
        public long? FarmMasterID { get; set; }
        public long? FarmID { get; set; }
        public long? FarmTypeID { get; set; }
        public string FarmTypeName { get; set; }
        public long? OwnershipStructureTypeID { get; set; }
        public string EIDSSFarmOwnerID { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? FarmOwnerMasterID { get; set; }
        public string EIDSSPersonID { get; set; }
        public string FarmOwner { get; set; }
        public string FarmOwnerLastName { get; set; }
        public string FarmOwnerFirstName { get; set; }
        public string FarmOwnerSecondName { get; set; }
        public string FarmName { get; set; }
        public string EIDSSFarmID { get; set; }
        public string Fax { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public int? TotalLivestockAnimalQuantity { get; set; }
        public int? TotalAvianAnimalQuantity { get; set; }
        public int? SickLivestockAnimalQuantity { get; set; }
        public int? SickAvianAnimalQuantity { get; set; }
        public int? DeadLivestockAnimalQuantity { get; set; }
        public int? DeadAvianAnimalQuantity { get; set; }
        public string Note { get; set; }
        public int RowAction { get; set; }
        public int RowStatus { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public DateTime? EnteredDate { get; set; }
        public long? FarmAddressID { get; set; }
        public long? FarmAddressidfsCountry { get; set; }
        public long? FarmAddressidfsRegion { get; set; }
        public long? FarmAddressidfsRayon { get; set; }
        public long? FarmAddressidfsSettlement { get; set; }
        public string FarmAddressstrStreetName { get; set; }
        public string FarmAddressstrBuilding { get; set; }
        public string FarmAddressstrApartment { get; set; }
        public string FarmAddressstrHouse { get; set; }
        public string FarmAddressstrPostalCode { get; set; }
        public double? FarmAddressstrLatitude { get; set; }
        public double? FarmAddressstrLongitude { get; set; }
        public string RegionName { get; set; }
        public string RayonName { get; set; }
        public string SettlementName { get; set; }
        public string Coordinates { get; set; }
        public string FarmOwnerName { get; set; }
        public string FarmAddress { get; set; }
    }
}
