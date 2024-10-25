using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FarmInventorySpeciesSaveRequestModel
    {
        public long SpeciesID { get; set; }
        public long? SpeciesMasterID { get; set; }
        public long FlockOrHerdID { get; set; }
        public long SpeciesTypeID { get; set; }
        public int? SickAnimalQuantity { get; set; }
        public int? TotalAnimalQuantity { get; set; }
        public int? DeadAnimalQuantity { get; set; }
        public DateTime? StartOfSignsDate { get; set; }
        public string AverageAge { get; set; }
        public long? ObservationID { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
        public long? RelatedToSpeciesID { get; set; }
        public long? RelatedToObservationID { get; set; }
        public long? OutbreakCaseStatusTypeID { get; set; }
    }
}