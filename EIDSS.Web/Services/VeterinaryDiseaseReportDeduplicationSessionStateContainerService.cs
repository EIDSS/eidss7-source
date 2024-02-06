using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Components.Administration.Deduplication;
using EIDSS.Web.Components.FlexForm;
using EIDSS.Web.Enumerations;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Services
{
    public class VeterinaryDiseaseReportDeduplicationSessionStateContainerService
    {
        #region backing fields
        private IList<Field> infoList { get; set; }
        private IList<Field> infoList2 { get; set; }
        private IList<Field> notificationList { get; set; }
        private IList<Field> notificationList2 { get; set; }

        private IList<FarmInventoryGetListViewModel> farmInventory;
        private IList<FarmInventoryGetListViewModel> farmInventory2;
        private IList<FarmInventoryGetListViewModel> survivorFarmInventory;

        private IList<VaccinationGetListViewModel> vaccinations;
        private IList<VaccinationGetListViewModel> vaccinations2;
        private IList<VaccinationGetListViewModel> survivorVaccinations;

        private IList<AnimalGetListViewModel> animals;
        private IList<AnimalGetListViewModel> animals2;
        private IList<AnimalGetListViewModel> survivorAnimals;

        private IList<SampleGetListViewModel> samples;
        private IList<SampleGetListViewModel> samples2;
        private IList<SampleGetListViewModel> survivorSamples;

        private IList<PensideTestGetListViewModel> pensideTests;
        private IList<PensideTestGetListViewModel> pensideTests2;
        private IList<PensideTestGetListViewModel> survivorPensideTests;

        private IList<LaboratoryTestGetListViewModel> labTests;
        private IList<LaboratoryTestGetListViewModel> labTests2;
        private IList<LaboratoryTestGetListViewModel> survivorLabTests;

        private IList<LaboratoryTestInterpretationGetListViewModel> interpretations;
        private IList<LaboratoryTestInterpretationGetListViewModel> interpretations2;
        private IList<LaboratoryTestInterpretationGetListViewModel> survivorInterpretations;

        private IList<CaseLogGetListViewModel> caseLogs;
        private IList<CaseLogGetListViewModel> caseLogs2;
        private IList<CaseLogGetListViewModel> survivorCaseLogs;


        #endregion
        #region Globals

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;

        public VeterinaryReportTypeEnum ReportType { get; set; }

        public long VeterinaryDiseaseReportID { get; set; }
        public long VeterinaryDiseaseReportID2 { get; set; }

        public int RecordSelection { get; set; }
        public int Record2Selection { get; set; }

        public long SurvivorVeterinaryDiseaseReportID { get; set; }
        public long SupersededVeterinaryDiseaseReportID { get; set; }

        public IList<Field> SurvivorInfoList { get; set; }
        public IList<Field> SurvivorNotificationList { get; set; }

        public bool chkCheckAll { get; set; }
        public bool chkCheckAll2 { get; set; }
        //public bool chkCheckAllNotification { get; set; }
        //public bool chkCheckAllNotification2 { get; set; }
        public bool chkCheckAllVaccination { get; set; }
        public bool chkCheckAllVaccination2 { get; set; }
        public bool chkCheckAllAnimals { get; set; }
        public bool chkCheckAllAnimals2 { get; set; }
        public bool chkCheckAllSamples { get; set; }
        public bool chkCheckAllSamples2 { get; set; }
        public bool chkCheckAllCaseLog { get; set; }
        public bool chkCheckAllCaseLog2 { get; set; }

        public bool TabChangeIndicator { get; set; }
        public AvianDiseaseReportDeduplicationTabEnum AvianTab { get; set; }
        public LivestockDiseaseReportDeduplicationTabEnum LivestockTab { get; set; }
        public VeterinaryDiseaseReportDeduplicationTabEnum Tab { get; set; }

        public IList<VeterinaryDiseaseReportViewModel> Records { get; set; }
        public IList<VeterinaryDiseaseReportViewModel> SelectedRecords { get; set; }
        public IList<VeterinaryDiseaseReportViewModel> SearchRecords { get; set; }

        public IList<Field> InfoList { get => infoList; set { infoList = value; NotifyStateChanged("InfoList"); } }
        public IList<Field> InfoList2 { get => infoList2; set { infoList2 = value; NotifyStateChanged("InfoList2"); } }
        public IList<Field> InfoList0 { get; set; }
        public IList<Field> InfoList02 { get; set; }

        public IList<Field> NotificationList { get => notificationList; set { notificationList = value; NotifyStateChanged("notificationList"); } }
        public IList<Field> NotificationList2 { get => notificationList2; set { notificationList2 = value; NotifyStateChanged("notificationList2"); } }
        public IList<Field> NotificationList0 { get; set; }
        public IList<Field> NotificationList02 { get; set; }


        public IList<FarmInventoryGetListViewModel> FarmInventory { get => farmInventory; set { farmInventory = value; NotifyStateChanged("FarmInventory"); } }
        public IList<FarmInventoryGetListViewModel> FarmInventory2 { get => farmInventory2; set { farmInventory2 = value; NotifyStateChanged("FarmInventory2"); } }
        public IList<FarmInventoryGetListViewModel> SurvivorFarmInventory { get => survivorFarmInventory; set { survivorFarmInventory = value; NotifyStateChanged("SurvivorFarmInventory"); } }

        public FlexFormQuestionnaireGetRequestModel FarmEpiFlexFormRequest { get; set; }
        public FlexFormQuestionnaireGetRequestModel FarmEpiFlexFormRequest2 { get; set; }
        public FlexFormQuestionnaireGetRequestModel SurvivorFarmEpiFlexFormRequest { get; set; }

        //public FlexForm FarmEpiDetails { get; set; }
        //public FlexForm FarmEpiDetails2 { get; set; }

        public bool FlexFormDisabledIndicator { get; set; } = true;

        public FlexFormQuestionnaireGetRequestModel ControlMeasuresFlexFormRequest { get; set; }
        public FlexFormQuestionnaireGetRequestModel ControlMeasuresFlexFormRequest2 { get; set; }
        public FlexFormQuestionnaireGetRequestModel SurvivorControlMeasuresFlexFormRequest { get; set; }

        public FlexFormQuestionnaireGetRequestModel SpeciesFlexFormRequest { get; set; }
        public FlexFormQuestionnaireGetRequestModel SpeciesFlexFormRequest2 { get; set; }
        public FlexFormQuestionnaireGetRequestModel SurvivorSpeciesFlexFormRequest { get; set; }

        public string Species { get; set; }
        public string Species2 { get; set; }
        public string SurvivorSpecies { get; set; }

        public IList<VaccinationGetListViewModel> Vaccinations { get => vaccinations; set { vaccinations = value; NotifyStateChanged("Vaccinations"); } }
        public IList<VaccinationGetListViewModel> Vaccinations2 { get => vaccinations2; set { vaccinations2 = value; NotifyStateChanged("Vaccinations2"); } }
        public IList<VaccinationGetListViewModel> SurvivorVaccinations { get => survivorVaccinations; set { survivorVaccinations = value; NotifyStateChanged("SurvivorVaccinations"); } }
        public int VaccinationsCount { get; set; }
        public int VaccinationsCount2 { get; set; }
        public int SurvivorVaccinationsCount { get; set; }
        public IList<VaccinationGetListViewModel> SelectedVaccinations { get; set; }
        public IList<VaccinationGetListViewModel> SelectedVaccinations2 { get; set; }

        public IList<AnimalGetListViewModel> Animals { get => animals; set { animals = value; NotifyStateChanged("Animals"); } }
        public IList<AnimalGetListViewModel> Animals2 { get => animals2; set { animals2 = value; NotifyStateChanged("Animals2"); } }
        public IList<AnimalGetListViewModel> SurvivorAnimals { get => survivorAnimals; set { survivorAnimals = value; NotifyStateChanged("SurvivorAnimals"); } }
        public int AnimalsCount { get; set; }
        public int AnimalsCount2 { get; set; }
        public int SurvivorAnimalsCount { get; set; }
        public IList<AnimalGetListViewModel> SelectedAnimals { get; set; }
        public IList<AnimalGetListViewModel> SelectedAnimals2 { get; set; }

        public IList<SampleGetListViewModel> Samples { get => samples; set { samples = value; NotifyStateChanged("Samples"); } }
        public IList<SampleGetListViewModel> Samples2 { get => samples2; set { samples2 = value; NotifyStateChanged("Samples2"); } }
        public IList<SampleGetListViewModel> SurvivorSamples { get => survivorSamples; set { survivorSamples = value; NotifyStateChanged("SurvivorSamples"); } }
        public int SamplesCount { get; set; }
        public int SamplesCount2 { get; set; }
        public int SurvivorSamplesCount { get; set; }
        public IList<SampleGetListViewModel> SelectedSamples { get; set; }
        public IList<SampleGetListViewModel> SelectedSamples2 { get; set; }

        public IList<PensideTestGetListViewModel> PensideTests { get => pensideTests; set { pensideTests = value; NotifyStateChanged("PensideTests"); } }
        public IList<PensideTestGetListViewModel> PensideTests2 { get => pensideTests2; set { pensideTests2 = value; NotifyStateChanged("PensideTests2"); } }
        public IList<PensideTestGetListViewModel> SurvivorPensideTests { get => survivorPensideTests; set { survivorPensideTests = value; NotifyStateChanged("SurvivorPensideTests"); } }
        public int PensideTestsCount { get; set; }
        public int PensideTestsCount2 { get; set; }
        public int SurvivorPensideTestsCount { get; set; }
        public IList<PensideTestGetListViewModel> SelectedPensideTests { get; set; }
        public IList<PensideTestGetListViewModel> SelectedPensideTests2 { get; set; }

        public IList<LaboratoryTestGetListViewModel> LabTests { get => labTests; set { labTests = value; NotifyStateChanged("LabTests"); } }
        public IList<LaboratoryTestGetListViewModel> LabTests2 { get => labTests2; set { labTests2 = value; NotifyStateChanged("LabTests2"); } }
        public IList<LaboratoryTestGetListViewModel> SurvivorLabTests { get => survivorLabTests; set { survivorLabTests = value; NotifyStateChanged("SurvivorLabTests"); } }
        public int LabTestsCount { get; set; }
        public int LabTestsCount2 { get; set; }
        public int SurvivorLabTestsCount { get; set; }
        public IList<LaboratoryTestGetListViewModel> SelectedLabTests { get; set; }
        public IList<LaboratoryTestGetListViewModel> SelectedLabTests2 { get; set; }

        public IList<LaboratoryTestInterpretationGetListViewModel> Interpretations { get => interpretations; set { interpretations = value; NotifyStateChanged("Interpretations"); } }
        public IList<LaboratoryTestInterpretationGetListViewModel> Interpretations2 { get => interpretations2; set { interpretations2 = value; NotifyStateChanged("Interpretations2"); } }
        public IList<LaboratoryTestInterpretationGetListViewModel> SurvivorInterpretations { get => survivorInterpretations; set { survivorInterpretations = value; NotifyStateChanged("SurvivorInterpretations"); } }
        public int InterpretationsCount { get; set; }
        public int InterpretationsCount2 { get; set; }
        public int SurvivorInterpretationsCount { get; set; }
        public IList<LaboratoryTestInterpretationGetListViewModel> SelectedInterpretations { get; set; }
        public IList<LaboratoryTestInterpretationGetListViewModel> SelectedInterpretations2 { get; set; }

        public IList<CaseLogGetListViewModel> CaseLogs { get => caseLogs; set { caseLogs = value; NotifyStateChanged("CaseLogs"); } }
        public IList<CaseLogGetListViewModel> CaseLogs2 { get => caseLogs2; set { caseLogs2 = value; NotifyStateChanged("CaseLogs2"); } }
        public IList<CaseLogGetListViewModel> SurvivorCaseLogs { get => survivorCaseLogs; set { survivorCaseLogs = value; NotifyStateChanged("SurvivorCaseLogs"); } }
        public int CaseLogsCount { get; set; }
        public int CaseLogsCount2 { get; set; }
        public int SurvivorCaseLogsCount { get; set; }
        public IList<CaseLogGetListViewModel> SelectedCaseLogs { get; set; }
        public IList<CaseLogGetListViewModel> SelectedCaseLogs2 { get; set; }

        #endregion

        #region Methods


        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);


        #endregion

    }
}
