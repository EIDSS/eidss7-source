using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class CaseGetListViewModel : BaseModel
    {
        public string EIDSSOutbreakID { get; set; }
        public long CaseID { get; set; }
        public string EIDSSCaseID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public string CaseTypeName { get; set; }
        public string StatusTypeName { get; set; }
        public string ClassificationTypeName { get; set; }
        public string CaseLocation { get; set; }
        public DateTime DateEntered { get; set; }
        public DateTime? DateOfSymptomOnset { get; set; }
        public DateTime? InvestigationDate { get; set; }
        public string ReportedByPersonName { get; set; }
        public string InvestigatedByPersonName { get; set; }
        public int? TotalSickAnimalQuantity { get; set; }
        public int? TotalDeadAnimalQuantity { get; set; }
        public int PrimaryCaseIndicator { get; set; }
        public int? MonitoringDuration { get; set; }
        public int? MonitoringFrequency { get; set; }
        public long? OutbreakTypeID { get; set; }
        public int RowCount { get; set; }
        public int RowAction { get; set; }
    }
}
