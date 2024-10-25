using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Components.Administration.Deduplication;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Web.Components.FlexForm;
using Radzen.Blazor;
using EIDSS.Web.ViewModels.Human;

namespace EIDSS.Web.Services
{
    public class HumanDiseaseReportDeduplicationSessionStateContainerService
    {

        #region backing fields

        private IList<Field> summaryList { get; set; }
        private IList<Field> summaryList2 { get; set; }

        private IList<Field> notificationList { get; set; }
        private IList<Field> notificationList2 { get; set; }
        private IEnumerable<int> notificationValues { get; set; }
        private IEnumerable<int> notificationValues2 { get; set; }

        private IList<Field> symptomsList { get; set; }
        private IList<Field> symptomsList2 { get; set; }
        private IEnumerable<int> symptomsValues { get; set; }
        private IEnumerable<int> symptomsValues2 { get; set; }

        private IList<Field> facilityDetailsList { get; set; }
        private IList<Field> facilityDetailsList2 { get; set; }
        private IEnumerable<int> facilityDetailsValues { get; set; }
        private IEnumerable<int> facilityDetailsValues2 { get; set; }

        private IList<Field> antibioticHistoryList { get; set; }
        private IList<Field> antibioticHistoryList2 { get; set; }
        private IEnumerable<int> antibioticHistoryValues { get; set; }
        private IEnumerable<int> antibioticHistoryValues2 { get; set; }

        private IList<Field> vaccineHistoryList { get; set; }
        private IList<Field> vaccineHistoryList2 { get; set; }
        private IEnumerable<int> vaccineHistoryValues { get; set; }
        private IEnumerable<int> vaccineHistoryValues2 { get; set; }

        private IList<DiseaseReportSamplePageSampleDetailViewModel> samples;
        private IList<DiseaseReportSamplePageSampleDetailViewModel> samples2;
        private IList<DiseaseReportSamplePageSampleDetailViewModel> survivorSamples;

        private IList<DiseaseReportTestDetailForDiseasesViewModel> tests;
        private IList<DiseaseReportTestDetailForDiseasesViewModel> tests2;
        private IList<DiseaseReportTestDetailForDiseasesViewModel> survivorTests;

        private IList<DiseaseReportContactDetailsViewModel> contacts;
        private IList<DiseaseReportContactDetailsViewModel> contacts2;
        private IList<DiseaseReportContactDetailsViewModel> survivorContacts;

        private IList<DiseaseReportAntiviralTherapiesViewModel> antibiotics;
        private IList<DiseaseReportAntiviralTherapiesViewModel> antibiotics2;
        private IList<DiseaseReportAntiviralTherapiesViewModel> survivorAntibiotics;

        private IList<DiseaseReportVaccinationViewModel> vaccinations;
        private IList<DiseaseReportVaccinationViewModel> vaccinations2;
        private IList<DiseaseReportVaccinationViewModel> survivorVaccinations;

        public RadzenDataGrid<DiseaseReportAntiviralTherapiesViewModel> antibitiocDetailsgrid;
        public RadzenDataGrid<DiseaseReportAntiviralTherapiesViewModel> antibitiocDetailsgrid2;
        public RadzenDataGrid<DiseaseReportVaccinationViewModel> vaccinationDetailsgrid;
        public RadzenDataGrid<DiseaseReportVaccinationViewModel> vaccinationDetailsgrid2;
        public List<DiseaseReportAntiviralTherapiesViewModel> antibioticsHistory { get; set; }

        public List<DiseaseReportAntiviralTherapiesViewModel> antibioticsHistory2 { get; set; }
 

        public List<DiseaseReportVaccinationViewModel> vaccinationHistory { get; set; }

        public List<DiseaseReportVaccinationViewModel> vaccinationHistory2 { get; set; }

        public int AntibioticsCount { get; set; }
        public int AntibioticsCount2 { get; set; }
        public int SurvivorAntibioticsCount { get; set; }

        public IList<DiseaseReportAntiviralTherapiesViewModel> SelectedAntibiotics { get; set; }
        public IList<DiseaseReportAntiviralTherapiesViewModel> SelectedAntibiotics2 { get; set; }

        public IList<DiseaseReportAntiviralTherapiesViewModel> Antibiotics { get => antibiotics; set { antibiotics = value; NotifyStateChanged("Antibiotics"); } }
        public IList<DiseaseReportAntiviralTherapiesViewModel> Antibiotics2 { get => antibiotics2; set { antibiotics2 = value; NotifyStateChanged("Antibiotics2"); } }
        public IList<DiseaseReportAntiviralTherapiesViewModel> SurvivorAntibiotics { get => survivorAntibiotics; set { survivorAntibiotics = value; NotifyStateChanged("SurvivorAntibiotics"); } }

        public int VaccinationsCount { get; set; }
        public int VaccinationsCount2 { get; set; }
        public int SurvivorVaccinationsCount { get; set; }

        public IList<DiseaseReportVaccinationViewModel> SelectedVaccinations { get; set; }
        public IList<DiseaseReportVaccinationViewModel> SelectedVaccinations2 { get; set; }

        public IList<DiseaseReportVaccinationViewModel> Vaccinations { get => vaccinations; set { vaccinations = value; NotifyStateChanged("Vaccinations"); } }
        public IList<DiseaseReportVaccinationViewModel> Vaccinations2 { get => vaccinations2; set { vaccinations2 = value; NotifyStateChanged("Vaccinations2"); } }
        public IList<DiseaseReportVaccinationViewModel> SurvivorVaccinations { get => survivorVaccinations; set { survivorVaccinations = value; NotifyStateChanged("Survivorvaccinations"); } }

        private IList<Field> clinicalNotesList { get; set; }
        private IList<Field> clinicalNotesList2 { get; set; }


        private IList<Field> samplesList { get; set; }
        private IList<Field> samplesList2 { get; set; }
        private IEnumerable<int> samplesValues { get; set; }
        private IEnumerable<int> samplesValues2 { get; set; }


        public int SamplesCount { get; set; }
        public int SamplesCount2 { get; set; }
        public int SurvivorSamplesCount { get; set; }

        public IList<DiseaseReportSamplePageSampleDetailViewModel> SelectedSamples { get; set; }
        public IList<DiseaseReportSamplePageSampleDetailViewModel> SelectedSamples2 { get; set; }

        public IList<DiseaseReportSamplePageSampleDetailViewModel> Samples { get => samples; set { samples = value; NotifyStateChanged("Samples"); } }
        public IList<DiseaseReportSamplePageSampleDetailViewModel> Samples2 { get => samples2; set { samples2 = value; NotifyStateChanged("Samples2"); } }
        public IList<DiseaseReportSamplePageSampleDetailViewModel> SurvivorSamples { get => survivorSamples; set { survivorSamples = value; NotifyStateChanged("SurvivorSamples"); } }


        private IList<Field> testsList { get; set; }
        private IList<Field> testsList2 { get; set; }
        private IEnumerable<int> testsValues { get; set; }
        private IEnumerable<int> testsValues2 { get; set; }


        public IList<DiseaseReportTestDetailForDiseasesViewModel> testsDetails = new List<DiseaseReportTestDetailForDiseasesViewModel>();
        public IList<DiseaseReportTestDetailForDiseasesViewModel> testsDetails2 = new List<DiseaseReportTestDetailForDiseasesViewModel>();

        public int TestsCount { get; set; }
        public int TestsCount2 { get; set; }
        public int SurvivorTestsCount { get; set; }

        public IList<DiseaseReportTestDetailForDiseasesViewModel> SelectedTests { get; set; }
        public IList<DiseaseReportTestDetailForDiseasesViewModel> SelectedTests2 { get; set; }

        public IList<DiseaseReportTestDetailForDiseasesViewModel> Tests { get => tests; set { tests = value; NotifyStateChanged("Tests"); } }
        public IList<DiseaseReportTestDetailForDiseasesViewModel> Tests2 { get => tests2; set { tests2 = value; NotifyStateChanged("Tests2"); } }
        public IList<DiseaseReportTestDetailForDiseasesViewModel> SurvivorTests { get => survivorTests; set { survivorTests = value; NotifyStateChanged("SurvivorTests"); } }


        private IList<Field> caseInvestigationsDetailsList { get; set; }
        private IList<Field> caseInvestigationDetailsList2 { get; set; }
        private IEnumerable<int> caseInvestigationDetailsValues { get; set; }
        private IEnumerable<int> caseInvestigationDetailsValues2 { get; set; }

        private IList<Field> riskFactorsList { get; set; }
        private IList<Field> riskFactorsList2 { get; set; }
        private IEnumerable<int> riskFactorsValues { get; set; }
        private IEnumerable<int> riskFactorsValues2 { get; set; }

        private IList<Field> contactsList { get; set; }
        private IList<Field> contactsList2 { get; set; }
        private IEnumerable<int> contactsValues { get; set; }
        private IEnumerable<int> contactsValues2 { get; set; }

        public RadzenDataGrid<DiseaseReportContactDetailsViewModel> contactsGrid;
        public RadzenDataGrid<DiseaseReportContactDetailsViewModel> contactsGrid2;

        public IList<DiseaseReportContactDetailsViewModel> contactsDetails = new List<DiseaseReportContactDetailsViewModel>();
        public IList<DiseaseReportContactDetailsViewModel> contactsDetails2 = new List<DiseaseReportContactDetailsViewModel>();

        public int ContactsCount { get; set; }
        public int ContactsCount2 { get; set; }
        public int SurvivorContactsCount { get; set; }

        public IList<DiseaseReportContactDetailsViewModel> SelectedContacts { get; set; }
        public IList<DiseaseReportContactDetailsViewModel> SelectedContacts2 { get; set; }

        public IList<DiseaseReportContactDetailsViewModel> Contacts { get => contacts; set { contacts = value; NotifyStateChanged("Contacts"); } }
        public IList<DiseaseReportContactDetailsViewModel> Contacts2 { get => contacts2; set { contacts2 = value; NotifyStateChanged("Contacts2"); } }
        public IList<DiseaseReportContactDetailsViewModel> SurvivorContacts { get => survivorContacts; set { survivorContacts = value; NotifyStateChanged("SurvivorContacts"); } }

        private IList<Field> finalOutcomeList { get; set; }
        private IList<Field> finalOutcomeList2 { get; set; }
        private IEnumerable<int> finalOutcomeValues { get; set; }
        private IEnumerable<int> finalOutcomeValues2 { get; set; }




        #endregion
        #region Globals

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;


        public IList<HumanDiseaseReportViewModel> Records { get; set; }
        public IList<HumanDiseaseReportViewModel> SelectedRecords { get; set; }
        public IList<HumanDiseaseReportViewModel> SearchRecords { get; set; }

        public long HumanDiseaseReportID { get; set; }
        public long HumanDiseaseReportID2 { get; set; }

        public long idfHuman { get; set; }

        public long idfHumanActual { get; set; }
        public long? idfsYNRelatedToOutbreak { get; set; }

        public long? idfsCaseProgressStatus { get; set; }

        public long? DiseaseReportTypeID { get; set; }

        public string strHumanCaseId { get; set; }
        //public DateTime? datCompletionPaperFormDate { get; set; }
        //public string strLocalIdentifier { get; set; }
        public bool? blnClinicalDiagBasis { get; set; }
        public bool? blnLabDiagBasis { get; set; }
        public bool? blnEpiDiagBasis { get; set; }
        public string strNote { get; set; }


        public long idfHuman2 { get; set; }

        public long idfHumanActual2 { get; set; }

        public long? idfsYNRelatedToOutbreak2 { get; set; }

        public long? idfsCaseProgressStatus2 { get; set; }
        public long? DiseaseReportTypeID2 { get; set; }

        public string strHumanCaseId2 { get; set; }
        //public DateTime? datCompletionPaperFormDate2 { get; set; }
        //public string strLocalIdentifier2 { get; set; }
        public bool? blnClinicalDiagBasis2 { get; set; }
        public bool? blnLabDiagBasis2 { get; set; }
        public bool? blnEpiDiagBasis2 { get; set; }
        public string strNote2 { get; set; }

        public IList<Field> SummaryList { get => summaryList; set { summaryList = value; NotifyStateChanged("summaryList"); } }
        public IList<Field> SummaryList2 { get => summaryList2; set { summaryList2 = value; NotifyStateChanged("summaryList2"); } }
        public IList<Field> SummaryList0 { get; set; }
        public IList<Field> SummaryList02 { get; set; }

        public IList<Field> NotificationList { get =>notificationList ; set { notificationList = value; NotifyStateChanged("notificationList"); } }
        public IList<Field> NotificationList2 { get => notificationList2; set { notificationList2 = value; NotifyStateChanged("notificationList2"); } }
        public IList<Field> NotificationList0 { get; set; }
        public IList<Field> NotificationList02 { get; set; }
        
        public IEnumerable<int> NotificationValues { get => notificationValues; set { notificationValues = (IEnumerable<int>)value; NotifyStateChanged("notificationValues"); } }
        public IEnumerable<int> NotificationValues2 { get => notificationValues2; set { notificationValues2 = (IEnumerable<int>)value; NotifyStateChanged("notificationValues2"); } }

        public IList<Field> SymptomsList0 { get; set; }
        public IList<Field> SymptomsList02 { get; set; }
        public IList<Field> SymptomsList { get => symptomsList; set { symptomsList = value; NotifyStateChanged("SymptomsList"); } }
        public IList<Field> SymptomsList2 { get => symptomsList2; set { symptomsList2 = value; NotifyStateChanged("SymptomsList2"); } }

        public IEnumerable<int> SymptomsValues { get => symptomsValues; set { symptomsValues = (IEnumerable<int>)value; NotifyStateChanged("SymptomsValues"); } }
        public IEnumerable<int> SymptomsValues2 { get => symptomsValues2; set { symptomsValues2 = (IEnumerable<int>)value; NotifyStateChanged("SymptomsValues2"); } }


        public FlexForm SymptomsDetails { get; set; }

        public FlexForm SymptomsDetails2 { get; set; }

        public bool FlexFormDisabledIndicator { get; set; } = true;

        public FlexFormQuestionnaireGetRequestModel SymptomsFlexFormRequest { get; set; }

        public FlexFormQuestionnaireGetRequestModel SymptomsFlexFormRequest2 { get; set; }
        public FlexFormQuestionnaireGetRequestModel SurvivorSymptomsFlexFormRequest { get; set; }

        public IList<Field> FacilityDetailsList0 { get; set; }
        public IList<Field> FacilityDetailsList02 { get; set; }
        public IList<Field> FacilityDetailsList { get => facilityDetailsList; set { facilityDetailsList = value; NotifyStateChanged("FacilityDetailsList"); } }
        public IList<Field> FacilityDetailsList2 { get => facilityDetailsList2; set { facilityDetailsList2 = value; NotifyStateChanged("FacilityDetailsList2"); } }

        public IEnumerable<int> FacilityDetailsValues { get => facilityDetailsValues; set { facilityDetailsValues = (IEnumerable<int>)value; NotifyStateChanged("FacilityDetailsValues"); } }
        public IEnumerable<int> FacilityDetailsValues2 { get => facilityDetailsValues2; set { facilityDetailsValues2 = (IEnumerable<int>)value; NotifyStateChanged("FacilityDetailsValues2"); } }


        public IList<Field> AntibioticHistoryList0 { get; set; }
        public IList<Field> AntibioticHistoryList02 { get; set; }
        public IList<Field> AntibioticHistoryList { get => antibioticHistoryList; set { antibioticHistoryList = value; NotifyStateChanged("AntibioticHistoryList"); } }
        public IList<Field> AntibioticHistoryList2 { get => antibioticHistoryList2; set { antibioticHistoryList2 = value; NotifyStateChanged("AntibioticHistoryList2"); } }

        public IEnumerable<int> AntibioticHistoryValues { get => antibioticHistoryValues; set { antibioticHistoryValues = (IEnumerable<int>)value; NotifyStateChanged("AntibioticHistoryValues"); } }
        public IEnumerable<int> AntibioticHistoryValues2 { get => antibioticHistoryValues2; set { antibioticHistoryValues2 = (IEnumerable<int>)value; NotifyStateChanged("AntibioticHistoryValues2"); } }


        public IList<Field> VaccineHistoryList0 { get; set; }
        public IList<Field> VaccineHistoryList02 { get; set; }
        public IList<Field> VaccineHistoryList { get => vaccineHistoryList; set { vaccineHistoryList = value; NotifyStateChanged("VaccineHistoryList"); } }
        public IList<Field> VaccineHistoryList2 { get => vaccineHistoryList2; set { vaccineHistoryList2 = value; NotifyStateChanged("VaccineHistoryList2"); } }

        public IEnumerable<int> VaccineHistoryValues { get => vaccineHistoryValues; set { vaccineHistoryValues = (IEnumerable<int>)value; NotifyStateChanged("VaccineHistoryValues"); } }
        public IEnumerable<int> VaccineHistoryValues2 { get => vaccineHistoryValues2; set { vaccineHistoryValues = (IEnumerable<int>)value; NotifyStateChanged("VacccineHistoryValues2"); } }

        public IList<Field> ClinicalNotesList0 { get; set; }
        public IList<Field> ClinicalNotesList02 { get; set; }
        public IList<Field> ClinicalNotesList { get => clinicalNotesList; set { clinicalNotesList = value; NotifyStateChanged("ClinicalNotesList"); } }
        public IList<Field> ClinicalNotesList2 { get => clinicalNotesList2; set { clinicalNotesList2 = value; NotifyStateChanged("ClinicalNotesList2"); } }


        public IList<Field> SamplesList0 { get; set; }
        public IList<Field> SamplesList02 { get; set; }
        public IList<Field> SamplesList { get => samplesList; set { samplesList = value; NotifyStateChanged("SamplesList"); } }
        public IList<Field> SamplesList2 { get => samplesList2; set { samplesList2 = value; NotifyStateChanged("SamplesList2"); } }

        public IEnumerable<int> SamplesValues { get => samplesValues; set { samplesValues = (IEnumerable<int>)value; NotifyStateChanged("SamplesValues"); } }
        public IEnumerable<int> SamplesValues2 { get => samplesValues2; set { samplesValues2 = (IEnumerable<int>)value; NotifyStateChanged("SamplesValues2"); } }

        public IList<Field> TestsList0 { get; set; }
        public IList<Field> TestsList02 { get; set; }
        public IList<Field> TestsList { get => testsList; set { testsList = value; NotifyStateChanged("TestsList"); } }
        public IList<Field> TestsList2 { get => testsList2; set { testsList2 = value; NotifyStateChanged("TestsList2"); } }

        public IEnumerable<int> TestsValues { get => testsValues; set { testsValues = (IEnumerable<int>)value; NotifyStateChanged("TestsValues"); } }
        public IEnumerable<int> TestsValues2 { get => testsValues2; set { testsValues2 = (IEnumerable<int>)value; NotifyStateChanged("TestsValues2"); } }

        public IList<Field> CaseInvestigationDetailsList0 { get; set; }
        public IList<Field> CaseInvestigationDetailsList02 { get; set; }
        public IList<Field> CaseInvestigationDetailsList { get => caseInvestigationsDetailsList; set { caseInvestigationsDetailsList = value; NotifyStateChanged("CaseInvestigationDetailsList"); } }
        public IList<Field> CaseInvestigationDetailsList2 { get => caseInvestigationDetailsList2; set { caseInvestigationDetailsList2 = value; NotifyStateChanged("CaseInvestigationDetailsList2"); } }

        public IEnumerable<int> CaseInvestigationDetailsValues { get => caseInvestigationDetailsValues; set { caseInvestigationDetailsValues = (IEnumerable<int>)value; NotifyStateChanged("CaseInvestigationDetailsValues"); } }
        public IEnumerable<int> CaseInvestigationDetailsValues2 { get => caseInvestigationDetailsValues2; set { caseInvestigationDetailsValues2 = (IEnumerable<int>)value; NotifyStateChanged("CaseInvestigationDetailsValues2"); } }


        public IList<Field> RiskFactorsList0 { get; set; }
        public IList<Field> RiskFactorsList02 { get; set; }
        public IList<Field> RiskFactorsList { get => riskFactorsList; set { riskFactorsList = value; NotifyStateChanged("RiskFactorsList"); } }
        public IList<Field> RiskFactorsList2 { get => riskFactorsList2; set { riskFactorsList2 = value; NotifyStateChanged("RiskFactorsList2"); } }

        public IEnumerable<int> RiskFactorsValues { get => riskFactorsValues; set { riskFactorsValues = (IEnumerable<int>)value; NotifyStateChanged("RiskFactorsValues"); } }
        public IEnumerable<int> RiskFactorsValues2 { get => riskFactorsValues2; set { riskFactorsValues2 = (IEnumerable<int>)value; NotifyStateChanged("RiskFactorsValues2"); } }


        public FlexForm RiskFactorsDetails { get; set; }

        public FlexForm RiskFactorsDetails2 { get; set; }

        public bool FlexFormDisabledIndicatorRiskFactors { get; set; } = true;

        public FlexFormQuestionnaireGetRequestModel RiskFactorsFlexFormRequest { get; set; }

        public FlexFormQuestionnaireGetRequestModel RiskFactorsFlexFormRequest2 { get; set; }
        public IList<Field> ContactsList0 { get; set; }
        public IList<Field> ContactsList02 { get; set; }
        public IList<Field> ContactsList { get => contactsList; set { contactsList = value; NotifyStateChanged("ContactsList"); } }
        public IList<Field> ContactsList2 { get => contactsList2; set { contactsList2 = value; NotifyStateChanged("ContactsList2"); } }

        public IEnumerable<int> ContactsValues { get => contactsValues; set { contactsValues = (IEnumerable<int>)value; NotifyStateChanged("ContactsValues"); } }
        public IEnumerable<int> ContactsValues2 { get => contactsValues2; set { contactsValues2 = (IEnumerable<int>)value; NotifyStateChanged("ContactsValues2"); } }


        public IList<Field> FinalOutcomeList0 { get; set; }
        public IList<Field> FinalOutcomeList02 { get; set; }
        public IList<Field> FinalOutcomeList { get => finalOutcomeList; set { finalOutcomeList = value; NotifyStateChanged("FinalOutcomeList"); } }
        public IList<Field> FinalOutcomeList2 { get => finalOutcomeList2; set { finalOutcomeList2 = value; NotifyStateChanged("FinalOutcomeList2"); } }

        public IEnumerable<int> FinalOutcomeValues { get => finalOutcomeValues; set { finalOutcomeValues = (IEnumerable<int>)value; NotifyStateChanged("FinalOutcomeValues"); } }
        public IEnumerable<int> FinalOutcomeValues2 { get => finalOutcomeValues2; set { finalOutcomeValues2 = (IEnumerable<int>)value; NotifyStateChanged("FinalOutcomeValues2"); } }



        public int RecordSelection { get; set; }
        public int Record2Selection { get; set; }

        public bool chkCheckAll { get; set; }
        public bool chkCheckAll2 { get; set; }
        public bool chkCheckAllSymptoms { get; set; }
        public bool chkCheckAllSymptoms2 { get; set; }
        public bool chkCheckAllFacilityDetails { get; set; }
        public bool chkCheckAllFacilityDetails2 { get; set; }

        public bool chkCheckAllAntibioticDetails{ get; set; }
        public bool chkCheckAllAntibioticDetails2 { get; set; }

        public bool chkCheckAllSamples{ get; set; }
        public bool chkCheckAllSamples2 { get; set; }

        public bool chkCheckAllTest { get; set; }
        public bool chkCheckAllTest2 { get; set; }

        public bool chkCheckAllCaseInvestigation{ get; set; }
        public bool chkCheckAllCaseInvestigation2 { get; set; }

        public bool chkCheckAllRiskFactors { get; set; }
        public bool chkCheckAllRiskFactors2 { get; set; }

        public bool chkCheckAllContactList { get; set; }
        public bool chkCheckAllContactList2 { get; set; }

        public bool chkCheckAllFinalOutcome { get; set; }
        public bool chkCheckAllFinalOutcome2 { get; set; }

        public long SurvivorHumanDiseaseReportID { get; set; }
        public long SupersededHumanDiseaseReportID { get; set; }

        public long SurvivorAntibioticHumanDiseaseReportID { get; set; }
        public long SupersededAntibioticHumanDiseaseReportID { get; set; }

        public long SurvivorVaccineHumanDiseaseReportID { get; set; }
        public long SupersededVaccineHumanDiseaseReportID { get; set; }

        public long SurvivorSampleHumanDiseaseReportID { get; set; }
        public long SupersededSampleHumanDiseaseReportID { get; set; }

        public long SurvivorTestHumanDiseaseReportID { get; set; }
        public long SupersededTestHumanDiseaseReportID { get; set; }

        public long SurvivorContactHumanDiseaseReportID { get; set; }
        public long SupersededContactHumanDiseaseReportID { get; set; }

        public IList<Field> SurvivorSummaryList { get; set; }
        public IList<Field> SurvivorNotificationList { get; set; }
        public IList<Field> SurvivorSymptomsList { get; set; }
        public IList<Field> SurvivorFacilityDetailsList { get; set; }
        public IList<Field> SurvivorAntibioticHistoryList { get; set; }

        public IList<Field> SurvivorVaccineHistoryList { get; set; }
        public IList<Field> SurvivorClinicalNotesList { get; set; }

        public IList<Field> SurvivorSamplesList { get; set; }
        public IList<Field> SurvivorTestsList { get; set; }
        public IList<Field> SurvivorCaseInvestigationDetailsList { get; set; }
        public IList<Field> SurvivorRiskFactorsList { get; set; }

        public IList<Field> SurvivorContactsList { get; set; }
        public IList<Field> SurvivorFinalOutcomeList { get; set; }


        // List for JSON Parameters
        public IList<DiseaseReportAntiviralTherapiesViewModel> SurvivorAntibioticsHistoryDetails { get; set; }
        public IList<DiseaseReportVaccinationViewModel> SurvivorVaccinationHistoryDetails { get; set; }
        public IList<DiseaseReportSamplePageSampleDetailViewModel> SurvivorSamplesDetails { get; set; }
        public IList<DiseaseReportTestDetailForDiseasesViewModel> SurvivorTestsDetails { get; set; }

        public IList<DiseaseReportContactDetailsViewModel> SurvivorContactsDetails { get; set; }

        public IEnumerable<int> SurvivorNotificationValues { get; set; }
        public IEnumerable<int> SurvivorSymptomsValues { get; set; }
        public IEnumerable<int> SurvivorFacilityDetailsValues { get; set; }
        public IEnumerable<int> SurvivorAntibioticHistoryValues { get; set; }

        public IEnumerable<int> SurvivorVaccineHistoryValues { get; set; }

        public IEnumerable<int> SurvivorSamplesValues { get; set; }
        public IEnumerable<int> SurvivorTestsValues { get; set; }
        public IEnumerable<int> SurvivorCaseInvestigationDetailsValues { get; set; }
        public IEnumerable<int> SurvivorRiskFactorsValues { get; set; }

        public IEnumerable<int> SurvivorContactsValues { get; set; }
        public IEnumerable<int> SurvivorFinalOutcomeValues { get; set; }


        public FlexFormQuestionnaireGetRequestModel SurvivorRiskFactorsFlexFormRequest { get; set; }


        public long SurvivoridfHuman { get; set; }

        public long SurvivoridfHumanActual { get; set; }

        public long? SurvivoridfsYNRelatedToOutbreak { get; set; }

        public long? SurvivoridfsCaseProgressStatus { get; set; }
        public long? SurvivorDiseaseReportTypeID { get; set; }

        public string SurvivorstrHumanCaseId { get; set; }

        //public DateTime? SurvivordatCompletionPaperFormDate { get; set; }
        //public string SurvivorstrLocalIdentifier { get; set; }
        //public DateTime? SurvivordatOnSetDate { get; set; }
        //public string SurvivorInitialCaseStatus { get; set; }
        public bool? SurvivorblnClinicalDiagBasis { get; set; }
        public bool? SurvivorblnLabDiagBasis { get; set; }
        public bool? SurvivorblnEpiDiagBasis { get; set; }
        //public long? SurvivoridfsOutCome { get; set; }
        public string SurvivorstrNote { get; set; }

        public bool TabChangeIndicator { get; set; }
        public HumanDiseaseReportDeduplicationTabEnum Tab { get; set; }

        #endregion

        #region Methods


        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);


        #endregion
    }
}
