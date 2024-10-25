using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(DataUpdateTypeEnum.Update,DataAuditObjectTypeEnum.HumanCase)]
    public class DiseaseReportSaveRequestModel : BaseSaveRequestModel
    {
        public long? DiseaseReportID { get; set; }
        public string EIDSSReportID { get; set; }
        public long? FarmID { get; set; }
        public long FarmMasterID { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? OutbreakID { get; set; }
        public long? RelatedToDiseaseReportID { get; set; }
        public string EIDSSFieldAccessionID { get; set; }
        public long DiseaseID { get; set; }
        public long? EnteredByPersonID { get; set; }
        public long? ReportedByOrganizationID { get; set; }
        public long? ReportedByPersonID { get; set; }
        public long? InvestigatedByOrganizationID { get; set; }
        public long? InvestigatedByPersonID { get; set; }
        public long? ReceivedByOrganizationID { get; set; }
        public long? ReceivedByPersonID { get; set; }
        public long SiteID { get; set; }
        public DateTime? DiagnosisDate { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? ReportDate { get; set; }
        public DateTime? AssignedDate { get; set; }
        public DateTime? InvestigationDate { get; set; }
        public int RowStatus { get; set; }
        public long? ReportTypeID { get; set; }
        public long? ClassificationTypeID { get; set; }
        public long? StatusTypeID { get; set; }
        public long ReportCategoryTypeID { get; set; }
        public int? FarmTotalAnimalQuantity { get; set; }
        public int? FarmSickAnimalQuantity { get; set; }
        public int? FarmDeadAnimalQuantity { get; set; }
        public double? FarmLatitude { get; set; }
        public double? FarmLongitude { get; set; }
        public long? FarmEpidemiologicalObservationID { get; set; }
        public long? ControlMeasuresObservationID { get; set; }
        public long? TestsConductedIndicator { get; set; }
        public string FlocksOrHerds { get; set; }
        public string Species { get; set; }
        public string Animals { get; set; }
        public string Vaccinations { get; set; }
        public string Samples { get; set; }
        public string PensideTests { get; set; }
        public string LaboratoryTests { get; set; }
        public string LaboratoryTestInterpretations { get; set; }
        public string CaseLogs { get; set; }
        public string Contacts { get; set; }
        public string CaseMonitorings { get; set; }
        public string Events { get; set; }
        public long UserID { get; set; }
        public bool LinkLocalOrFieldSampleIDToReportID { get; set; }
        public bool OutbreakCaseIndicator { get; set; }
        public long? OutbreakCaseReportUID { get; set; }
        public long? OutbreakCaseStatusTypeID { get; set; }
        public long? OutbreakCaseQuestionnaireObservationID { get; set; }
        public bool PrimaryCaseIndicator { get; set; }
        public long? DataAuditEventTypeID { get; set; }
        public string Comments { get; set; }
    }
}
