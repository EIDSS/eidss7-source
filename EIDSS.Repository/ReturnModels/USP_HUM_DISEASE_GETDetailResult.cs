﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_HUM_DISEASE_GETDetailResult
    {
        public long idfHumanCase { get; set; }
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
        public long? idfInvestigatedByOffice { get; set; }
        public long? idfReceivedByOffice { get; set; }
        public long? idfEpiObservation { get; set; }
        public long? idfCSObservation { get; set; }
        public DateTime? datNotificationDate { get; set; }
        public DateTime? datCompletionPaperFormDate { get; set; }
        public DateTime? datFirstSoughtCareDate { get; set; }
        public DateTime? datHospitalizationDate { get; set; }
        public DateTime? datFacilityLastVisit { get; set; }
        public DateTime? datExposureDate { get; set; }
        public DateTime? datDischargeDate { get; set; }
        public DateTime? datOnSetDate { get; set; }
        public DateTime? StartDateofInvestigation { get; set; }
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
        public long? idfPointGeoLocation { get; set; }
        public long? idfsPointGroundType { get; set; }
        public long? idfsPointGeoLocationType { get; set; }
        public long? idfsPointCountry { get; set; }
        public long? idfsPointRegion { get; set; }
        public long? idfsPointRayon { get; set; }
        public long? idfsPointSettlement { get; set; }
        public double? dblPointDistance { get; set; }
        public double? dblPointLatitude { get; set; }
        public double? dblPointLongitude { get; set; }
        public double? dblPointElevation { get; set; }
        public double? dblPointAlignment { get; set; }
        public double? dblPointAccuracy { get; set; }
        public string strPointForeignAddress { get; set; }
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
        public long? idfsYNExposureLocationKnown { get; set; }
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
        public DateTime? datDateOfDeath { get; set; }
        public string Region { get; set; }
        public string Rayon { get; set; }
        public string HumanAgeType { get; set; }
        public string Outcome { get; set; }
        public string NonNotifiableDiagnosis { get; set; }
        public string NotCollectedReason { get; set; }
        public string CaseProgressStatus { get; set; }
        public string YNSpecificVaccinationAdministered { get; set; }
        public string PreviouslySoughtCare { get; set; }
        public string YNExposureLocationKnown { get; set; }
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
        public string InvestigatedByOffice { get; set; }
        public string YNTestConducted { get; set; }
        public string strMonitoringSessionID { get; set; }
        public string ExposureLocationType { get; set; }
        public string strGroundType { get; set; }
        public string ExposureLocationDescription { get; set; }
        public string SummaryCaseClassification { get; set; }
        public string SentByPerson { get; set; }
        public string ReceivedByPerson { get; set; }
        public string InvestigatedByPerson { get; set; }
        public string EnteredByPerson { get; set; }
        public string strOfficeEnteredBy { get; set; }
        public long? idfOfficeEnteredBy { get; set; }
        public string strNotificationSentby { get; set; }
        public string strNotificationReceivedby { get; set; }
        public string PatientStatus { get; set; }
        public string Country { get; set; }
        public string Settlement { get; set; }
        public string PatientFarmOwnerName { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? HumanActualId { get; set; }
        public bool? blnInitialSSD { get; set; }
        public bool? blnFinalSSD { get; set; }
        public long? idfParentMonitoringSession { get; set; }
        public long? DiseaseId { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? DateOfDiagnosis { get; set; }
        public long? ChangedDiseaseId { get; set; }
        public string ChangedDiseaseName { get; set; }
        public DateTime? DateOfChangedDiagnosis { get; set; }
        public long? ChangeDiagnosisReasonId { get; set; }

    }
}
