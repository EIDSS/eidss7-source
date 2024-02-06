using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class OutbreakCaseCreateRequestModel
    {
        public string LangID { get; set; }
        public int? intRowStatus { get; set; }
        public string User { get; set; }
        public long? OutbreakCaseReportUID { get; set; }
        public long? idfOutbreak { get; set; }
        public long? idfHumanCase { get; set; }
        public long? idfVetCase { get; set; }
        public long? OutbreakCaseObservationID { get; set; }
        public long? idfHumanActual { get; set; }
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        public DateTime? datNotificationDate { get; set; }
        public long? idfSentByOffice { get; set; }
        public long? idfSentByPerson { get; set; }
        public long? idfReceivedByOffice { get; set; }
        public long? idfReceivedByPerson { get; set; }
        public long? CaseGeoLocationID { get; set; }
        public long? CaseidfsLocation { get; set; }
        public string CasestrStreetName { get; set; }
        public string CasestrApartment { get; set; }
        public string CasestrBuilding { get; set; }
        public string CasestrHouse { get; set; }
        public string CaseidfsPostalCode { get; set; }
        public double? CasestrLatitude { get; set; }
        public double? CasestrLongitude { get; set; }
        public double? CasestrElevation { get; set; }
        public long? CaseStatusID { get; set; }
        public DateTime? datOnSetDate { get; set; }
        public DateTime? datFinalDiagnosisDate { get; set; }
        public long? idfHospital { get; set; }
        public DateTime? datHospitalizationDate { get; set; }
        public DateTime? datDischargeDate { get; set; }
        public string Antimicrobials { get; set; }
        public string vaccinations { get; set; }
        public string strClinicalNotes { get; set; }
        public long? idfsYNHospitalization { get; set; }
        public long? idfsYNAntimicrobialTherapy { get; set; }
        public long? idfsYNSpecIFicVaccinationAdministered { get; set; }
        public DateTime? StartDateofInvestigation { get; set; }
        public long? idfCSObservation { get; set; }
        public long? OutbreakCaseClassificationID { get; set; }
        public long? idfInvestigatedByOffice { get; set; }
        public long? idfInvestigatedByPerson { get; set; }
        public DateTime? datInvestigationStartDate { get; set; }
        public string IsPrimaryCaseFlag { get; set; }
        public string strNote { get; set; }
        public long? idfEpiObservation { get; set; }
        public string CaseMonitorings { get; set; }
        public string CaseContacts { get; set; }
        public long? idfsYNSpecimenCollected { get; set; }
        public string CaseSamples { get; set; }
        public long? idfsYNTestsConducted { get; set; }
        public string CaseTests { get; set; }
        public string Events { get; set; }
    }
}
