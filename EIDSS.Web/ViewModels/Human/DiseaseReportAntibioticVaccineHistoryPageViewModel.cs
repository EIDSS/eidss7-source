using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportAntibioticVaccineHistoryPageViewModel
    {
        public long? HumanID { get; set; }
        public long? HumanActualID { get; set; }
        public long? idfHumanCase { get; set; }
        public long? idfsYNSpecificVaccinationAdministered { get; set; }
        public long? idfsYNAntimicrobialTherapy { get; set; }
        public string AdditionalInforMation { get; set; }
        public string AntibioticName { get; set; }
        public string Dose { get; set; }
        public DateTime? datAntibioticFirstAdministered { get; set; }
        public string vaccinationName { get; set; }
        public DateTime? vaccinationDate { get; set; }
        public List<DiseaseReportAntiviralTherapiesViewModel> antibioticsHistory { get; set; } = new();
        public List<DiseaseReportVaccinationViewModel> vaccinationHistory { get; set; } = new();
        public List<DiseaseReportVaccinationViewModel> vaccinationHistoryForGrid { get; set; }

        public bool IsReportClosed { get; set; } = false;
    }
    public class VaccinationDetails
    {
        public int VaccinationID { get; set; }
        public string VaccinationName { get; set; }
        public DateTime? datofVaccination { get; set; }
    }
}
