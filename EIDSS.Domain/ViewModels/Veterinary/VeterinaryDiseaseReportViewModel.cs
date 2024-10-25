using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VeterinaryDiseaseReportViewModel : BaseModel
    {
        public long ReportKey { get; set; }
        public string ReportID { get; set; }
        public long?  OutbreakKey { get; set; }
        public string OutbreakID { get; set; }
        public long ReportCategoryTypeID { get; set; }
        public string ReportStatusTypeName { get; set; }
        public string ReportTypeName { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string ClassificationTypeName { get; set; }
        public DateTime? ReportDate { get; set; }
        public DateTime? InvestigationDate { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? FinalDiagnosisDate { get; set; }
        public string InvestigatedByPersonName { get; set; }
        public string ReportedByPersonName { get; set; }
        public int TotalSickAnimalQuantity { get; set; }
        public int TotalAnimalQuantity { get; set; }
        public int TotalDeadAnimalQuantity { get; set; }
        public string SpeciesList { get; set; }
        public string FarmID { get; set; }
        public long? FarmMasterKey { get; set; }
        public string FarmName { get; set; }
        public long? FarmOwnerKey { get; set; }
        public string FarmOwnerID { get; set; }
        public string FarmOwnerName { get; set; }
        public string FarmLocation { get; set; }
        public string FarmAddress { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string EnteredByPersonName { get; set; }
        public long SiteKey { get; set; }
        public long idfFarm { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int? TotalCount { get; set;  } 
        public int? RowAction { get; set; }
        public int RowStatus { get; set; }
        public bool Selected { get; set; }
    }

    public class VeterinaryDiseaseReportDetailViewModel
    {
        public long idfHumanCase { get; set; }
        public int? parentHumanDiseaseReportID { get; set; }
        public string relatedHumanDiseaseReportIdList { get; set; }
        public long idfHuman { get; set; }
        public long? idfsHospitalizationStatus { get; set; }
        public long? idfsYNSpecimenCollected { get; set; }
        public long? idfsHumanAgeType { get; set; }
        public long? idfsYNAntimicrobialTherapy { get; set; }
        public long? idfsYNHospitalization { get; set; }
        public long? idfsYNRelatedToOutbreak { get; set; }
        public long? idfsOutCome { get; set; }
        public long? idfsInitialCaseStatus { get; set; }
        public long? idfsFinalDiagnosis { get; set; }
        public string strFinalDiagnosis { get; set; }
        public long? idfsFinalCaseStatus { get; set; }
        public string strFinalCaseStatus { get; set; }
        public long? idfSentByOffice { get; set; }
        public long? idfInvestigatedByOffice { get; set; } // Case Investigation
        public long? idfReceivedByOffice { get; set; }
        public long? idfEpiObservation { get; set; }
        public long? idfCSObservation { get; set; }
        public DateTime? datNotificationDate { get; set; }
        public DateTime? datCompletionPaperFormDate { get; set; }
        public DateTime? datFirstSoughtCareDate { get; set; }
        public DateTime? datHospitalizationDate { get; set; }
        public DateTime? datFacilityLastVisit { get; set; }
        public DateTime? datExposureDate { get; set; } // Case investigation
        public DateTime? datDischargeDate { get; set; }
        public DateTime? datOnSetDate { get; set; }
        public DateTime? StartDateofInvestigation { get; set; } // Case Investigation
        public DateTime? datDateOfDiagnosis { get; set; }
        public DateTime? datFinalDiagnosisDate { get; set; }
        public string strNote { get; set; }
        public string strCurrentLocation { get; set; }
        public string strHospitalizationPlace { get; set; }
        public string strLocalIdentifier { get; set; }
        public string strSoughtCareFacility { get; set; }
        public string strSentByFirstName { get; set; }
        public string strSentByPatronymicName { get; set; }
        public string strSentByLastName { get; set; }
        public string strReceivedByFirstName { get; set; }
        public string strReceivedByPatronymicName { get; set; }
        public string strReceivedByLastName { get; set; }
        public string strEpidemiologistsName { get; set; }
        public string strClinicalDiagnosis { get; set; }
        public string strClinicalNotes { get; set; }
        public string strSummaryNotes { get; set; }
        public int? intPatientAge { get; set; }
        public bool? blnClinicalDiagBasis { get; set; }
        public bool? blnLabDiagBasis { get; set; }
        public bool? blnEpiDiagBasis { get; set; }
        public long? idfPersonEnteredBy { get; set; }
        public long? idfPointGeoLocation { get; set; } //case investigation
        public long? idfsPointGroundType { get; set; } //case investigation
        public long? idfsPointGeoLocationType { get; set; } //case investigation
        public long? idfsPointCountry { get; set; } //case investigation
        public long? idfsPointRegion { get; set; } //case investigation
        public long? idfsPointRayon { get; set; } //case investigation
        public long? idfsPointSettlement { get; set; } //case investigation
        public double? dblPointDistance { get; set; } //case investigation
        public double? dblPointLatitude { get; set; } //case investigation
        public double? dblPointLongitude { get; set; } //case investigation
        public double? dblPointElevation { get; set; } //case investigation

        public double? dblPointAlignment { get; set; }
        public double? dblPointAccuracy { get; set; }
        public string strPointForeignAddress { get; set; } //case investigation
        public long? idfSentByPerson { get; set; }
        public long? idfReceivedByPerson { get; set; }
        public long? idfInvestigatedByPerson { get; set; }
        public long? idfsYNTestsConducted { get; set; }
        public long? idfSoughtCareFacility { get; set; }
        public long? idfsNonNotifiableDiagnosis { get; set; }
        public string stridfsNonNotifiableDiagnosis { get; set; }
        public long? idfOutbreak { get; set; }
        public string strCaseId { get; set; }
        public long? idfsCaseProgressStatus { get; set; }
        public long idfsSite { get; set; }
        public string strSampleNotes { get; set; }
        public Guid? uidOfflineCaseID { get; set; }
        public DateTime? datFinalCaseClassificationDate { get; set; }
        public long? idfHospital { get; set; }
        public long? idfsYNSpecificVaccinationAdministered { get; set; }
        public long? idfsNotCollectedReason { get; set; }
        public string strNotCollectedReason { get; set; }
        public long? idfsYNPreviouslySoughtCare { get; set; }
        public long? idfsYNExposureLocationKnown { get; set; } //Case Investigation
        public DateTime? datEnteredDate { get; set; }
        public DateTime? datModificationDate { get; set; }
        public long? idfsDiagnosis { get; set; }
        public long? idfsFinalState { get; set; }
        public long? DiseaseReportTypeID { get; set; }
        public string ReportType { get; set; }
        public string LegacyCaseID { get; set; }
        public DateTime? DateofClassification { get; set; }
        public string strOutbreakID { get; set; }
        public string strDescription { get; set; }
        public string strPersonId { get; set; }

        public string strGroundType { get; set; }
        public DateTime? datDateOfDeath { get; set; }
        public string Region { get; set; } //case investigation
        public string Rayon { get; set; } //case investigation
        public string HumanAgeType { get; set; }
        public string Outcome { get; set; }
        public string NonNotifiableDiagnosis { get; set; }
        public string NotCollectedReason { get; set; }
        public string CaseProgressStatus { get; set; }
        public string YNSpecificVaccinationAdministered { get; set; }
        public string PreviouslySoughtCare { get; set; }
        public string YNExposureLocationKnown { get; set; } // Case Investigation
        public string HospitalizationStatus { get; set; }
        public string YNHospitalization { get; set; }
        public string YNAntimicrobialTherapy { get; set; }
        public string YNSpecimenCollected { get; set; }
        public string YNRelatedToOutBreak { get; set; }
        public string TentativeDiagnosis { get; set; }
        public string SummaryIdfsFinalDiagnosis { get; set; }
        public string InitialCaseStatus { get; set; }
        public string FinalCaseStatus { get; set; }
        public string SentByOffice { get; set; }
        public string ReceivedByOffice { get; set; }
        public string HospitalName { get; set; }
        public string InvestigatedByOffice { get; set; } // Case Investigation
        public string YNTestConducted { get; set; }
        public string strMonitoringSessionID { get; set; }
        public string ExposureLocationType { get; set; } // Case Investigation
        public string ExposureLocationDescription { get; set; } // Case Inverstigation
        public string SummaryCaseClassification { get; set; }
        public string SentByPerson { get; set; }
        public string ReceivedByPerson { get; set; }
        public string InvestigatedByPerson { get; set; }  // Case Investigation
        public string EnteredByPerson { get; set; }
        public string strOfficeEnteredBy { get; set; }
        public long? idfOfficeEnteredBy { get; set; }
        public string strNotificationSentby { get; set; }
        public string strNotificationReceivedby { get; set; }
        public string PatientStatus { get; set; }
        public string Country { get; set; } //case investigation
        public string Settlement { get; set; } //case investigation
        public string PatientFarmOwnerName { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? HumanActualId { get; set; }
        public bool? blnInitialSSD { get; set; }
        public bool? blnFinalSSD { get; set; }
    }
}
