using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VaccinationGetListViewModel : BaseModel 
    {
        public VaccinationGetListViewModel ShallowCopy()
        {
            return (VaccinationGetListViewModel)MemberwiseClone();
        }

        public long VaccinationID { get; set; }
        public long? DiseaseReportID { get; set; }
        public long? SpeciesID { get; set; }
        public string SpeciesTypeName { get; set; }
        public string Species { get; set; }
        public long? VaccinationTypeID { get; set; }
        public string VaccinationTypeName { get; set; }
        public long? RouteTypeID { get; set; }
        public string RouteTypeName { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public string IDC10Code { get; set; }
        public string OIECode { get; set; }
        public DateTime? VaccinationDate { get; set; }
        public string Manufacturer { get; set; }
        public string LotNumber { get; set; }
        public int? NumberVaccinated { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }    }
}
