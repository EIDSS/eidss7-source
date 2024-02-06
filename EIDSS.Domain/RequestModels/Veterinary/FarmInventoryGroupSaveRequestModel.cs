using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FarmInventoryGroupSaveRequestModel
    {
        public long FlockOrHerdID { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? FlockOrHerdMasterID { get; set; }
        public string EIDSSFlockOrHerdID { get; set; }
        public int? SickAnimalQuantity { get; set; }
        public int? TotalAnimalQuantity { get; set; }
        public int? DeadAnimalQuantity { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}