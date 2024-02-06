namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class FarmViewModel
    {
        public FarmViewModel ShallowCopy()
        {
            return (FarmViewModel)MemberwiseClone();
        }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? FarmTypeID { get; set; }
        public string FarmTypeName { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? FarmAddressID { get; set; }
        public string FarmName { get; set; }
        public string EIDSSFarmID { get; set; }
        public long? MonitoringSessionSummaryID { get; set; }
        public string Fax { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public int? TotalLivestockAnimalQuantity { get; set; }
        public int? TotalAvianAnimalQuantity { get; set; }
        public int? SickLivestockAnimalQuantity { get; set; }
        public int? SickAvianAnimalQuantity { get; set; }
        public int? DeadLivestockAnimalQuantity { get; set; }
        public int? DeadAvianAnimalQuantity { get; set; }
        public int RowStatus { get; set; }
        public long? CountryID { get; set; }
        public long? RegionID { get; set; }
        public string RegionName { get; set; }
        public long? RayonID { get; set; }
        public string RayonName { get; set; }
        public long? SettlementID { get; set; }
        public string SettlementName { get; set; }
        public string Apartment { get; set; }
        public string Building { get; set; }
        public string House { get; set; }
        public string PostalCode { get; set; }
        public string Street { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public double? Elevation { get; set; }
        public string FarmAddress { get; set; }
        public string FarmAddressCoordinates { get; set; }
        public string EIDSSPersonID { get; set; }
        public string EIDSSFarmOwnerID { get; set; }
        public string FarmOwnerName { get; set; }
        public string FarmOwnerFirstName { get; set; }
        public string FarmOwnerLastName { get; set; }
        public string FarmOwnerSecondName { get; set; }
        public int? RecordCount { get; set; }
        public int? TotalCount { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
        public int? RowAction { get; set; }
        public bool Selected { get; set; }
    }
}