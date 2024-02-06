using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System;
using System.Collections.Generic;
using System.Linq;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Web.Services
{
    public class VeterinaryActiveSurveillanceSessionStateContainerService
    {
        #region Constructor

        public VeterinaryActiveSurveillanceSessionStateContainerService()
        {
            FarmDetail = new FarmMasterGetDetailViewModel();
            FarmDetailAggregate = new FarmMasterGetDetailViewModel();
            FarmLocationModel = new LocationViewModel();
            FarmLocationModelAggregate = new LocationViewModel();
            CampaignDiseaseIDs = new List<long?>();
            ActiveSurveillanceSessionPermissions = new UserPermissions();
            VeterinaryDiseaseResultPermissions = new UserPermissions();
            CanInterpretVeterinaryPermissions = new UserPermissions();
            CanManageReferenceTablesPermissions = new UserPermissions();
        }

        #endregion Constructor

        #region Private Members

        private long? sessionKey;
        private string sessionID;
        private string legacySessionID;
        private string campaignID;
        private long? campaignKey;
        private string campaignName;
        private string campaignType;
        private DateTime? campaignStartDate;
        private DateTime? campaignEndDate;
        private List<long?> campaignDiseaseIDs;
        private long? sessionStatusTypeID;
        private long? originalSessionStatusTypeID;
        private string sessionStatusTypeName;
        private long? administrativeLevelID;
        private DateTime? sessionStartDate;
        private DateTime? sessionEndDate;
        private long? reportTypeID;
        private string reportTypeName;
        private long? selectedFarmID;
        private long? selectedAggregateFarmID;
        private string diseaseString;
        private long? siteID;
        private string siteName;
        private long? officerID;
        private string officerName;
        private DateTime? dateEntered;
        private long? locationID;
        private long? sessionCategoryTypeID;
        private long? countryID;
        private long? regionID;
        private long? rayonID;
        private long? settlementID;
        private long? totalNumber;
        private long? totalNumberOfAnimalsSampled;
        private long? totalNumberOfSamples;
        private FarmMasterGetDetailViewModel farmDetail;
        private List<FarmInventoryGetListViewModel> farmInventory;
        private List<FarmInventoryGetListViewModel> pendingSaveFarmInventory;
        private FarmMasterGetDetailViewModel farmDetailAggregate;
        private List<FarmInventoryGetListViewModel> farmInventoryAggregate;
        private List<FarmInventoryGetListViewModel> pendingSaveFarmInventoryAggregate;
        private List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> diseaseSpeciesSamples;
        private List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> pendingSaveDiseaseSpeciesSamples;
        private List<SampleGetListViewModel> animalSamples;
        private List<SampleGetListViewModel> pendingSaveAnimalSamples;
        private List<SampleToDiseaseGetListViewModel> animalSampleToDiseases;
        private List<SampleToDiseaseGetListViewModel> pendingSaveAnimalSampleToDiseases;
        private SampleGetListViewModel animalSampleDetail;
        private List<FarmViewModel> farms;
        private List<FarmViewModel> pendingSaveFarms;
        private List<VeterinaryActiveSurveillanceSessionAggregateViewModel> animalSamplesAggregate;
        private List<VeterinaryActiveSurveillanceSessionAggregateViewModel> pendingSaveAnimalSamplesAggregate;
        private VeterinaryActiveSurveillanceSessionAggregateViewModel animalSampleDetailAggregate;
        private List<VeterinaryActiveSurveillanceSessionAggregateViewModel> aggregateRecords;
        private List<VeterinaryActiveSurveillanceSessionAggregateViewModel> pendingSaveAggregateRecords;
        private List<FarmViewModel> farmsAggregate;
        private List<FarmViewModel> pendingSaveFarmsAggregate;
        private List<LaboratoryTestGetListViewModel> tests;
        private List<LaboratoryTestGetListViewModel> pendingSaveTests;
        private List<LaboratoryTestInterpretationGetListViewModel> testInterpretations;
        private List<LaboratoryTestInterpretationGetListViewModel> pendingSaveTestInterpretations;
        private List<VeterinaryActiveSurveillanceSessionActionsViewModel> actions;
        private List<VeterinaryActiveSurveillanceSessionActionsViewModel> pendingSaveActions;
        private List<VeterinaryDiseaseReportViewModel> diseaseReports;
        private IList<EventSaveRequestModel> pendingSaveEvents;
        private LaboratoryTestGetListViewModel laboratoryTestDetail;
        private LaboratoryTestInterpretationGetListViewModel interpretationDetail;
        private VeterinaryActiveSurveillanceSessionActionsViewModel actionDetail;
        private LocationViewModel locationModel;
        private LocationViewModel farmLocationModel;
        private LocationViewModel farmLocationModelAggregate;
        private UserPermissions activeSurveillanceSessionPermissions;
        private UserPermissions veterinaryDiseaseResultPermissions;
        private UserPermissions canInterpretVeterinaryPermissions;
        private UserPermissions canManageReferenceTablesPermissions;
        private bool hasLinkedCampaign;
        private bool showSessionHeaderIndicator;
        private int? hACode;
        private int? specieshACode;
        private bool reportTypeDisabled;
        private bool isReadOnly;

        #endregion Private Members

        #region Drop Down Collections

        public List<BaseReferenceViewModel> SessionStatuses { get; set; }
        public List<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public List<BaseReferenceAdvancedListResponseModel> Species { get; set; }
        public List<BaseReferenceViewModel> ReportTypes { get; set; }
        public List<DiseaseSampleTypeByDiseaseResponseModel> SampleTypes { get; set; }

        #endregion Drop Down Collections

        #region Properties

        public long? ReportTypeID
        { get => reportTypeID; set { reportTypeID = value; NotifyStateChanged("ReportTypeID"); } }

        public string ReportTypeName
        { get => reportTypeName; set { reportTypeName = value; NotifyStateChanged("ReportTypeName"); } }

        public string SessionID
        { get => sessionID; set { sessionID = value; NotifyStateChanged("SessionID"); } }

        public long? SessionKey
        { get => sessionKey; set { sessionKey = value; NotifyStateChanged("SessionKey"); } }

        public string LegacySessionID
        { get => legacySessionID; set { legacySessionID = value; NotifyStateChanged("LegacySessionID"); } }

        public string CampaignID
        { get => campaignID; set { campaignID = value; NotifyStateChanged("CampaignID"); } }

        public long? CampaignKey
        { get => campaignKey; set { campaignKey = value; NotifyStateChanged("CampaignKey"); } }

        public string CampaignName
        { get => campaignName; set { campaignName = value; NotifyStateChanged("CampaignName"); } }

        public string CampaignType
        { get => campaignType; set { campaignType = value; NotifyStateChanged("CampaignType"); } }

        public DateTime? CampaignStartDate
        { get => campaignStartDate; set { campaignStartDate = value; NotifyStateChanged("CampaignStartDate"); } }

        public DateTime? CampaignEndDate
        { get => campaignEndDate; set { campaignEndDate = value; NotifyStateChanged("CampaignEndDate"); } }

        public List<long?> CampaignDiseaseIDs
        { get => campaignDiseaseIDs; set { campaignDiseaseIDs = value; NotifyStateChanged("CampaignDiseaseIDs"); } }

        public long? SessionStatusTypeID
        { get => sessionStatusTypeID; set { sessionStatusTypeID = value; NotifyStateChanged("SessionStatusTypeID"); } }

        public long? OriginalSessionStatusTypeID
        { get => originalSessionStatusTypeID; set { originalSessionStatusTypeID = value; NotifyStateChanged("OriginalSessionStatusTypeID"); } }

        public string SessionStatusTypeName
        { get => sessionStatusTypeName; set { sessionStatusTypeName = value; NotifyStateChanged("SessionStatusTypeName"); } }

        public string DiseaseString
        { get => diseaseString; set { diseaseString = value; NotifyStateChanged("DiseaseString"); } }

        public long? AdministrativeLevelID
        { get => administrativeLevelID; set { administrativeLevelID = value; NotifyStateChanged("AdministrativeLevelID"); } }

        public DateTime? SessionStartDate
        { get => sessionStartDate; set { sessionStartDate = value; NotifyStateChanged("SessionStartDate"); } }

        public DateTime? SessionEndDate
        { get => sessionEndDate; set { sessionEndDate = value; NotifyStateChanged("SessionEndDate"); } }

        public long? SelectedFarmMasterID
        { get => selectedFarmID; set { selectedFarmID = value; NotifyStateChanged("SelectedFarmID"); } }

        public long? SelectedAggregateFarmMasterID
        { get => selectedAggregateFarmID; set { selectedAggregateFarmID = value; NotifyStateChanged("SelectedAggregateFarmID"); } }

        public long? SiteID
        { get => siteID; set { siteID = value; NotifyStateChanged("SiteID"); } }

        public string SiteName
        { get => siteName; set { siteName = value; NotifyStateChanged("SiteName"); } }

        public long? OfficerID
        { get => officerID; set { officerID = value; NotifyStateChanged("OfficerID"); } }

        public string OfficerName
        { get => officerName; set { officerName = value; NotifyStateChanged("OfficerName"); } }

        public DateTime? DateEntered
        { get => dateEntered; set { dateEntered = value; NotifyStateChanged("DateEntered"); } }

        public long? LocationID
        { get => locationID; set { locationID = value; NotifyStateChanged("LocationID"); } }

        public long? SessionCategoryTypeID
        { get => sessionCategoryTypeID; set { sessionCategoryTypeID = value; NotifyStateChanged("SessionCategoryTypeID"); } }

        public long? CountryID
        { get => countryID; set { countryID = value; NotifyStateChanged("CountryID"); } }

        public long? RegionID
        { get => regionID; set { regionID = value; NotifyStateChanged("RegionID"); } }

        public long? RayonID
        { get => rayonID; set { rayonID = value; NotifyStateChanged("RayonID"); } }

        public long? SettlementID
        { get => settlementID; set { settlementID = value; NotifyStateChanged("SettlementID"); } }

        public long? TotalNumber
        { get => totalNumber; set { totalNumber = value; NotifyStateChanged("TotalNumber"); } }

        public int TotalNumberOfAnimalsSampled { get; set; }

        public int TotalNumberOfSamples { get; set; }

        public FarmMasterGetDetailViewModel FarmDetail
        { get => farmDetail; set { farmDetail = value; NotifyStateChanged("FarmDetail"); } }

        public SampleGetListViewModel AnimalSampleDetail
        { get => animalSampleDetail; set { animalSampleDetail = value; NotifyStateChanged("AnimalSampleDetail"); } }

        public FarmMasterGetDetailViewModel FarmDetailAggregate
        { get => farmDetailAggregate; set { farmDetailAggregate = value; NotifyStateChanged("FarmDetailAggregate"); } }

        public VeterinaryActiveSurveillanceSessionAggregateViewModel AnimalSampleDetailAggregate
        { get => animalSampleDetailAggregate; set { animalSampleDetailAggregate = value; NotifyStateChanged("AnimalSampleDetailAggregate"); } }

        public LaboratoryTestGetListViewModel LaboratoryTestDetail
        { get => laboratoryTestDetail; set { laboratoryTestDetail = value; NotifyStateChanged("LaboratoryTestDetail"); } }

        public LaboratoryTestInterpretationGetListViewModel InterpretationDetail
        { get => interpretationDetail; set { interpretationDetail = value; NotifyStateChanged("InterpretationDetail"); } }

        public VeterinaryActiveSurveillanceSessionActionsViewModel ActionDetail
        { get => actionDetail; set { actionDetail = value; NotifyStateChanged("ActionDetail"); } }

        public int? HACode
        { get => hACode; set { hACode = value; NotifyStateChanged("HACode"); } }

        public int? SpeciesHACode
        { get => specieshACode; set { specieshACode = value; NotifyStateChanged("SpecieshACode"); } }

        public bool ReportTypeDisabled
        { get => reportTypeDisabled; set { reportTypeDisabled = value; NotifyStateChanged("ReportTypeDisabled"); } }

        public LocationViewModel LocationModel
        { get => locationModel; set { locationModel = value; NotifyStateChanged("LocationModel"); } }

        public LocationViewModel FarmLocationModel
        { get => farmLocationModel; set { farmLocationModel = value; NotifyStateChanged("FarmLocationModel"); } }

        public LocationViewModel FarmLocationModelAggregate
        { get => farmLocationModelAggregate; set { farmLocationModelAggregate = value; NotifyStateChanged("FarmLocationModel"); } }

        public UserPermissions ActiveSurveillanceSessionPermissions
        { get => activeSurveillanceSessionPermissions; set { activeSurveillanceSessionPermissions = value; NotifyStateChanged("ActiveSurveillanceSessionPermissions"); } }

        public UserPermissions VeterinaryDiseaseResultPermissions
        { get => veterinaryDiseaseResultPermissions; set { veterinaryDiseaseResultPermissions = value; NotifyStateChanged("VeterinaryDiseaseResultPermissions"); } }

        public UserPermissions CanInterpretVeterinaryPermissions
        { get => canInterpretVeterinaryPermissions; set { canInterpretVeterinaryPermissions = value; NotifyStateChanged("CanInterpretVeterinaryPermissions"); } }

        public UserPermissions CanManageReferenceTablesPermissions
        { get => canManageReferenceTablesPermissions; set { canManageReferenceTablesPermissions = value; NotifyStateChanged("CanManageReferenceTablesPermissions"); } }

        public bool HasLinkedCampaign
        { get => hasLinkedCampaign; set { hasLinkedCampaign = value; NotifyStateChanged("HasLinkedCampaign"); } }

        public bool ShowSessionHeaderIndicator
        { get => showSessionHeaderIndicator; set { showSessionHeaderIndicator = value; NotifyStateChanged("ShowSessionHeaderIndicator"); } }

        public bool IsReadOnly
        { get => isReadOnly; set { isReadOnly = value; NotifyStateChanged("IsReadOnly"); } }

        #endregion Properties

        #region Collections

        public List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> DiseaseSpeciesSamples
        { get => diseaseSpeciesSamples; set { diseaseSpeciesSamples = value; NotifyStateChanged("DiseaseSpeciesSamples"); } }

        public List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> PendingSaveDiseaseSpeciesSamples
        { get => pendingSaveDiseaseSpeciesSamples; set { pendingSaveDiseaseSpeciesSamples = value; NotifyStateChanged("PendingSaveDiseaseSpeciesSamples"); } }

        public List<FarmViewModel> Farms
        { get => farms; set { farms = value; NotifyStateChanged("Farms"); } }

        public List<FarmViewModel> PendingSaveFarms
        { get => pendingSaveFarms; set { pendingSaveFarms = value; NotifyStateChanged("PendingSaveFarms"); } }

        public List<FarmInventoryGetListViewModel> FarmInventory
        { get => farmInventory; set { farmInventory = value; NotifyStateChanged("FarmInventory"); } }

        public List<FarmInventoryGetListViewModel> PendingSaveFarmInventory
        { get => pendingSaveFarmInventory; set { pendingSaveFarmInventory = value; NotifyStateChanged("PendingSaveFarmInventory"); } }

        public List<SampleGetListViewModel> AnimalSamples
        { get => animalSamples; set { animalSamples = value; NotifyStateChanged("AnimalSamples"); } }

        public List<SampleGetListViewModel> PendingSaveAnimalSamples
        { get => pendingSaveAnimalSamples; set { pendingSaveAnimalSamples = value; NotifyStateChanged("PendingSaveAnimalSamples"); } }

        public List<SampleToDiseaseGetListViewModel> AnimalSampleToDiseases
        { get => animalSampleToDiseases; set { animalSampleToDiseases = value; NotifyStateChanged("AnimalSampleToDiseases"); } }

        public List<SampleToDiseaseGetListViewModel> PendingSaveAnimalSampleToDiseases
        { get => pendingSaveAnimalSampleToDiseases; set { pendingSaveAnimalSampleToDiseases = value; NotifyStateChanged("PendingSaveAnimalSampleToDiseases"); } }

        public List<VeterinaryActiveSurveillanceSessionAggregateViewModel> AggregateRecords
        { get => aggregateRecords; set { aggregateRecords = value; NotifyStateChanged("AggregateRecords"); } }

        public List<VeterinaryActiveSurveillanceSessionAggregateViewModel> PendingSaveAggregateRecords
        { get => pendingSaveAggregateRecords; set { pendingSaveAggregateRecords = value; NotifyStateChanged("PendingSaveAggregateRecords"); } }

        public List<FarmViewModel> FarmsAggregate
        { get => farmsAggregate; set { farmsAggregate = value; NotifyStateChanged("FarmsAggregate"); } }

        public List<FarmViewModel> PendingSaveFarmsAggregate
        { get => pendingSaveFarmsAggregate; set { pendingSaveFarmsAggregate = value; NotifyStateChanged("PendingSaveFarmsAggregate"); } }

        public List<FarmInventoryGetListViewModel> FarmInventoryAggregate
        { get => farmInventoryAggregate; set { farmInventoryAggregate = value; NotifyStateChanged("FarmInventoryAggregate"); } }

        public List<FarmInventoryGetListViewModel> PendingSaveFarmInventoryAggregate
        { get => pendingSaveFarmInventoryAggregate; set { pendingSaveFarmInventoryAggregate = value; NotifyStateChanged("PendingSaveFarmInventoryAggregate"); } }

        public List<VeterinaryActiveSurveillanceSessionAggregateViewModel> AnimalSamplesAggregate
        { get => animalSamplesAggregate; set { animalSamplesAggregate = value; NotifyStateChanged("AnimalSamplesAggregate"); } }

        public List<VeterinaryActiveSurveillanceSessionAggregateViewModel> PendingSaveAnimalSamplesAggregate
        { get => pendingSaveAnimalSamplesAggregate; set { pendingSaveAnimalSamplesAggregate = value; NotifyStateChanged("PendingSaveAnimalSamplesAggregate"); } }

        public List<LaboratoryTestGetListViewModel> Tests
        { get => tests; set { tests = value; NotifyStateChanged("Tests"); } }

        public List<LaboratoryTestGetListViewModel> PendingSaveTests
        { get => pendingSaveTests; set { pendingSaveTests = value; NotifyStateChanged("PendingSaveTests"); } }

        public List<LaboratoryTestInterpretationGetListViewModel> TestInterpretations
        { get => testInterpretations; set { testInterpretations = value; NotifyStateChanged("TestInterpretations"); } }

        public List<LaboratoryTestInterpretationGetListViewModel> PendingSaveTestInterpretations
        { get => pendingSaveTestInterpretations; set { pendingSaveTestInterpretations = value; NotifyStateChanged("PendingSaveTestInterpretations"); } }

        public List<VeterinaryActiveSurveillanceSessionActionsViewModel> Actions
        { get => actions; set { actions = value; NotifyStateChanged("Actions"); } }

        public List<VeterinaryActiveSurveillanceSessionActionsViewModel> PendingSaveActions
        { get => pendingSaveActions; set { pendingSaveActions = value; NotifyStateChanged("PendingSaveActions"); } }

        public List<VeterinaryDiseaseReportViewModel> DiseaseReports
        { get => diseaseReports; set { diseaseReports = value; NotifyStateChanged("DiseaseReports"); } }

        public IList<EventSaveRequestModel> PendingSaveEvents
        { get => pendingSaveEvents; set { pendingSaveEvents = value; NotifyStateChanged("PendingSaveEvents"); } }

        #endregion Collections

        #region Validation Indicators

        public bool SessionHeaderValidIndicator { get; set; }
        public bool SessionHeaderModifiedIndicator { get; set; }
        public bool SessionInformationValidIndicator { get; set; }
        public bool SessionInformationModifiedIndicator { get; set; }
        public bool SessionDetailedInformationValidIndicator { get; set; }
        public bool SessionDetailedInformationModifiedIndicator { get; set; }
        public bool SessionTestsValidIndicator { get; set; }
        public bool SessionTestsModifiedIndicator { get; set; }
        public bool SessionActionsValidIndicator { get; set; }
        public bool SessionActionsModifiedIndicator { get; set; }
        public bool SessionAggregateInformationValidIndicator { get; set; }
        public bool SessionAggregateInformationModifiedIndicator { get; set; }
        public bool SessionDiseaseReportsValidIndicator { get; set; }
        public bool SessionDiseaseReportsModifiedIndicator { get; set; }
        public bool SessionReviewValidIndicator { get; set; }
        public bool SessionReviewModifiedIndicator { get; set; }
        public bool SessionIsClosed { get; set; }

        #endregion Validation Indicators

        #region Non Tracked Properties

        public int DiseaseSpeciesCount { get; set; }
        public int DiseaseSpeciesDatabaseQueryCount { get; set; }
        public int DiseaseSpeciesLastDatabasePage { get; set; }
        public int DiseaseSpeciesNewRecordCount { get; set; }

        #endregion Non Tracked Properties

        #region Events

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;

        public event Action OnCampaignLinked;

        #endregion Events

        #region Private Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        public void NotifyStateChanged(string property) => OnChange?.Invoke(property);

        public void NotifyCampaignLinked()
        {
            OnCampaignLinked?.Invoke();
        }

        #endregion Private Methods
    }
}