using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public sealed class OmmCaseSetModel
    {
        public string langId { get; set; }
        public long? OutbreakCaseReportUID { get; set; }
        public long? idfOutbreak { get; set; }
        public long? idfHumanCase { get; set; }
        public long? idfVetCase { get; set; }
        public long? diseaseID { get; set; }
        public long? CaseObservationID { get; set; }
        public int? intRowStatus { get; set; }
        public string User { get; set; }
        public long? idfHumanActual { get; set; }
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        public long? idfsYNSpecIFicVaccinationAdministered { get; set; }
        public DateTime? StartDateofInvestigation { get; set; }

        //Notification
        public DateTime? datNotificationDate { get; set; }
        public long? idfSentByOffice { get; set; }
        public long? idfSentByPerson { get; set; }
        public long? idfReceivedByOffice { get; set; }
        public long? idfReceivedByPerson { get; set; }

        //Case Location
        public long? idfsLocationCountry { get; set; }
        public long? idfsLocationRegion { get; set; }
        public long? idfsLocationRayon { get; set; }
        public long? idfsLocationSettlement { get; set; }
        public string strStreet { get; set; }
        public string strHouse { get; set; }
        public string strBuilding { get; set; }
        public string strApartment { get; set; }
        public string strPostalCode { get; set; }
        public long? intLocationLatitude { get; set; }
        public long? intLocationLongitude { get; set; }

        //Clinical Information
        public long? CaseStatusID { get; set; }
        public DateTime? datOnSetDate { get; set; }
        public DateTime? datFinalDiagnosisDate { get; set; }
        public long? idfHospital { get; set; }
        public DateTime? datHospitalizationDate { get; set; }
        public DateTime? datDischargeDate { get; set; }
        public List<OmmClinicalAntimicrobialModel> Antimicrobials { get; set; }
        public List<OmmClinicalVaccinationModel> Vaccinations { get; set; }
        public string strClinicalNotes { get; set; }
        public long? idfsYNHospitalization { get; set; }
        public long? idfsYNAntimicrobialTherapy { get; set; }
        public long? idfCSObservation { get; set; }

        //Outbreak Investigation
        public long? idfInvestigatedByOffice { get; set; }
        public long? idfInvestigatedByPerson { get; set; }
        public DateTime? datInvestigationStartDate { get; set; }
        public long? CaseClassificationID { get; set; }
        public string IsPrimaryCaseFlag { get; set; }
        public string strOutbreakInvestigationComments { get; set; }
        public long? InvestigationObservationID { get; set; }
        public string strNote { get; set; }
        public long? idfEpiObservation { get; set; }

        //Case Monitoring
        public DateTime? datMonitoringDate { get; set; }
        public long? CaseMonitoringObservationID { get; set; }
        public string CaseMonitoringAdditionalComments { get; set; }
        public string CaseInvestigatorOrganization { get; set; }
        public string CaseInvestigatorName { get; set; }
        public List<OmmCaseMonitoringModel> CaseMonitorings { get; set; }

        //Samples
        public long? idfsYNSpecimenCollected { get; set; }

        public DateTime? AccessionDate { get; set; }
        public string SampleConditionReceived { get; set; }
        public string VaccinationName { get; set; }
        public DateTime? datDateOfVaccination { get; set; }

        //Tests
        public List<OmmCaseTestsModel> Tests { get; set; }
    }

    public sealed class OmmClinicalVaccinationModel
    {
        public long HumanDiseaseReportVaccinationUID { get; set; }
        public long idfHumanCase { get; set; }
        public string VaccinationName { get; set; }
        public DateTime VaccinationDate { get; set; }
        public System.String RowAction { get; set; }
        public int intRowStatus { get; set; }
    }

    public sealed class OmmClinicalAntimicrobialModel
    {
        public long idfAntimicrobialTherapy { get; set; }
        public string AntimicrobialName { get; set; }
        public string AntimicrobialDose { get; set; }
        public DateTime FirstAdministeredDate { get; set; }
        public System.String RowAction { get; set; }
        public int intRowStatus { get; set; }
    }

    public sealed class OmmCaseTestsModel
    {
        public long? idfTesting { get; set; }
        public long? idfMaterial { get; set; }
        public long? idfsSampleType { get; set; }
        public string strFieldBarcode { get; set; }
        public string strBarcode { get; set; }
        public long? idfsTestName { get; set; }
        public long? idfsTestResult { get; set; }
        public long? idfsTestStatus { get; set; }
        public System.DateTime? datConcludedDate { get; set; }
        public long? idfsTestCategory { get; set; }
        public long? idfsInterpretedStatus { get; set; }
        public string strInterpretedComment { get; set; }
        public System.DateTime? datInterpretationDate { get; set; }
        public long? idfInterpretedByPerson { get; set; }
        public int blnValidateStatus { get; set; }
        public string strValidateComment { get; set; }
        public System.DateTime? datValidationDate { get; set; }
        public long? idfValidatedByPerson { get; set; }
        public string SampleType { get; set; }
        public string TestName { get; set; }
        public string TestResult { get; set; }
        public string TestStatus { get; set; }
        public string TestCategory { get; set; }
        public string InterpretedStatus { get; set; }
        public string InterpretedByPerson { get; set; }
        public string ValidatedByPerson { get; set; }
        public string RowAction { get; set; }
        public int intRowStatus { get; set; }
    }

    public sealed class OmmCaseMonitoringModel
    {
        public long idfOutbreakCaseMonitoring { get; set; }
        public long? idfObservation { get; set; }
        public System.DateTime? datMonitoringDate { get; set; }
        public long? idfInvestigatedByOffice { get; set; }
        public string InvestigatedByOffice { get; set; }
        public string idfInvestigatedByPerson { get; set; }
        public string InvestigatedByPerson { get; set; }
        public string strAdditionalComments { get; set; }
        public int intRowStatus { get; set; }
        public System.String RowAction { get; set; }
        public long? idfsFormType { get; set; }
        public bool rowVisible { get; set; } = false;
    }
}
