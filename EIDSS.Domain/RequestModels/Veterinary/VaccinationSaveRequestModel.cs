using EIDSS.Domain.Attributes;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VaccinationSaveRequestModel
    {
        [Required]
        public long VaccinationID { get; set; }
        public long? SpeciesID { get; set; }
        public long? VaccinationTypeID { get; set; }
        public long? RouteTypeID { get; set; }
        public long? DiseaseID { get; set; }
        public DateTime? VaccinationDate { get; set; }
        public string Manufacturer { get; set; }
        public string LotNumber { get; set; }
        public int? NumberVaccinated { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}