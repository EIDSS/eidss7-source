using System;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class FarmMasterGetDetailViewModel
    {
        public FarmMasterGetDetailViewModel ShallowCopy() => (FarmMasterGetDetailViewModel)MemberwiseClone();
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
        public int? RowAction { get; set; }
        public int RowStatus { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public DateTime? EnteredDate { get; set; }
        public long? FarmAddressID { get; set; }
        public long? FarmAddressLocationID { get; set; }
        public long? FarmAddressAdministrativeLevel0ID { get; set; }
        public string FarmAddressAdministrativeLevel0Name { get; set; }
        public long? FarmAddressAdministrativeLevel1ID { get; set; }
        public string FarmAddressAdministrativeLevel1Name { get; set; }
        public long? FarmAddressAdministrativeLevel2ID { get; set; }
        public string FarmAddressAdministrativeLevel2Name { get; set; }
        public long? FarmAddressAdministrativeLevel3ID { get; set; }
        public string FarmAddressAdministrativeLevel3Name { get; set; }
        public long? FarmAddressSettlementID { get; set; }
        public string FarmAddressSettlementName { get; set; }
        public long? FarmAddressSettlementTypeID { get; set; }
        public string FarmAddressSettlementTypeName { get; set; }
        public long? FarmAddressStreetID { get; set; }
        public string FarmAddressStreetName { get; set; }
        public string FarmAddressBuilding { get; set; }
        public string FarmAddressApartment { get; set; }
        public string FarmAddressHouse { get; set; }
        public long? FarmAddressPostalCodeID { get; set; }
        public string FarmAddressPostalCode { get; set; }
        public double? FarmAddressLatitude { get; set; }
        public double? FarmAddressLongitude { get; set; }
        public string Coordinates { get; set; }
        public string FarmOwnerName { get; set; }
        public string AddressString { get; set; }
        public int? NumberOfBirdsPerBuilding { get; set; }
        public int? NumberOfBuildings { get; set; }
        public long? AvianFarmTypeID { get; set; }
        public long? AvianProductionTypeID { get; set; }
    }
}