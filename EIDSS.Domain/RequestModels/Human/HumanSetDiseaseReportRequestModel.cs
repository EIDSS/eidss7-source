using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using System;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(DataUpdateTypeEnum.Update, DataAuditObjectTypeEnum.HumanCase)]
    public class HumanSetDiseaseReportRequestModel
    {

        public string LanguageID { get; set; }

        public long? idfHumanCase { get; set; }

        public long? idfHuman { get; set; }

        public long? idfHumanActual { get; set; }

        public string strHumanCaseId { get; set; }

        public long? idfsFinalDiagnosis { get; set; }

        public DateTime? datDateOfDiagnosis { get; set; }

        public DateTime? datNotificationDate { get; set; }

        public long? idfsFinalState { get; set; }

        public string strLocalIdentifier { get; set; }

        public long? idfSentByOffice { get; set; }

        public string strSentByFirstName { get; set; }

        public string strSentByPatronymicName { get; set; }

        public string strSentByLastName { get; set; }

        public long? idfSentByPerson { get; set; }

        public long? idfReceivedByOffice { get; set; }

        public string strReceivedByFirstName { get; set; }

        public string strReceivedByPatronymicName { get; set; }

        public string strReceivedByLastName { get; set; }

        public long? idfReceivedByPerson { get; set; }

        public long? idfsHospitalizationStatus { get; set; }

        public long? idfHospital { get; set; }

        public string strCurrentLocation { get; set; }

        public DateTime? datOnSetDate { get; set; }

        public long? idfsInitialCaseStatus { get; set; }

        public long? idfsYNPreviouslySoughtCare { get; set; }

        public DateTime? datFirstSoughtCareDate { get; set; }

        public long? idfSoughtCareFacility { get; set; }

        public long? idfsNonNotIFiableDiagnosis { get; set; }

        public long? idfsYNHospitalization { get; set; }

        public DateTime? datHospitalizationDate { get; set; }

        public DateTime? datDischargeDate { get; set; }

        public string strHospitalName { get; set; }

        public long? idfsYNAntimicrobialTherapy { get; set; }

        public string strAntibioticName { get; set; }

        public string strDosage { get; set; }

        public DateTime? datFirstAdministeredDate { get; set; }

        public string strAntibioticComments { get; set; }

        public long? idfsYNSpecIFicVaccinationAdministered { get; set; }

        public long? idfInvestigatedByOffice { get; set; }

        public DateTime? StartDateofInvestigation { get; set; }

        public long? idfsYNRelatedToOutbreak { get; set; }

        public long? idfOutbreak { get; set; }

        public long? idfsYNExposureLocationKnown { get; set; }

        public long? idfPointGeoLocation { get; set; }

        public DateTime? datExposureDate { get; set; }

        public long? idfsGeoLocationType { get; set; }

        public string strLocationDescription { get; set; }

        public long? idfsLocationCountry { get; set; }

        public long? idfsLocationRegion { get; set; }

        public long? idfsLocationRayon { get; set; }

        public long? idfsLocationSettlement { get; set; }

        public double? intLocationLatitude { get; set; }

        public double? intLocationLongitude { get; set; }

        public long? intElevation { get; set; }

        public long? idfsLocationGroundType { get; set; }

        public double? intLocationDistance { get; set; }

        public double? intLocationDirection { get; set; }

        public string strForeignAddress { get; set; }

        public long? idfsFinalCaseStatus { get; set; }

        public long? idfsOutcome { get; set; }

        public DateTime? DateOfBirth { get; set; }

        public DateTime? datDateofDeath { get; set; }

        public long? idfsCaseProgressStatus { get; set; }

        public long? idfPersonEnteredBy { get; set; }

        public string strClinicalNotes { get; set; }

        public long? idfsYNSpecimenCollected { get; set; }

        public long? idfsYNTestsConducted { get; set; }

        public long? DiseaseReportTypeID { get; set; }

        public bool? blnClinicalDiagBasis { get; set; }

        public bool? blnLabDiagBasis { get; set; }

        public bool? blnEpiDiagBasis { get; set; }

        public DateTime? DateofClassification { get; set; }

        public string strSummaryNotes { get; set; }

        public long? idfEpiObservation { get; set; }

        public long? idfCSObservation { get; set; }

        public long? idfInvestigatedByPerson { get; set; }

        public string strEpidemiologistsName { get; set; }

        public long? idfsNotCollectedReason { get; set; }

        public string strNotCollectedReason { get; set; }

        public string SamplesParameters { get; set; }

        public string TestsParameters { get; set; }

        public string Notifications { get; set; }
        public string TestsInterpretationParameters { get; set; }

        public string AntiviralTherapiesParameters { get; set; }

        public string VaccinationsParameters { get; set; }

        public string ContactsParameters { get; set; }
        public string Events { get; set; }

        public long? idfsHumanAgeType { get; set; }

        public int? intPatientAge { get; set; }

        public DateTime? datCompletionPaperFormDate { get; set; }

        public long? idfsSite { get; set; }

        public string AuditUser { get; set; }

        public int RowStatus { get; set; } = 0;

        public string strNote { get; set; }

        public long? idfParentMonitoringSession { get; set; }
        public long? ConnectedTestId { get; set; }

        private DateTime DateEntered { get; } = DateTime.Now;

        private DateTime DateModified { get; } = DateTime.Now;

        public long? DiseaseId { get; set; }
        public DateTime? DateOfDiagnosis { get; set; }
        public long? ChangedDiseaseId { get; set; }
        public DateTime? DateOfChangedDiagnosis { get; set; }
        public long? ChangeDiagnosisReasonId { get; set; }
    }
}