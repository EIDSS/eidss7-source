using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class AnimalSaveRequestModel
    {
        [Required]
        public long AnimalID { get; set; }
        public long? SexTypeID { get; set; }
        public long? ConditionTypeID { get; set; }
        public long? AgeTypeID { get; set; }
        public long? SpeciesID { get; set; }
        public long? ObservationID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public string AnimalName { get; set; }
        public string Color { get; set; }
        public string AnimalDescription { get; set; }
        public long? ClinicalSignsIndicator { get; set; }
        [Required]
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
        public long? RelatedToAnimalID { get; set; }
        public long? RelatedToObservationID { get; set; }
    }
}