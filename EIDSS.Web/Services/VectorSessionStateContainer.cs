using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Web.Abstracts;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Services
{
    public class VectorSessionStateContainer : BaseServiceContainer
    {
        #region Member Variables

        private readonly ILogger<VectorSessionStateContainer> _logger;
        private readonly IOrganizationClient _organizationClient;

        #endregion Member Variables

        #region Constructor

        public VectorSessionStateContainer(
            ILogger<VectorSessionStateContainer> logger,
            IOrganizationClient organizationClient,
            ITokenService tokenService,
            IConfiguration configuration
            ) : base(logger, tokenService, configuration)
        {
            _logger = logger;
            _organizationClient = organizationClient;

            _locationViewModel = new LocationViewModel();
            _detailLocationViewModel = new LocationViewModel();
            _summaryLocationViewModel = new LocationViewModel();
            VectorSurveillanceSessionPermissions = new UserPermissions();
            VectorSurveillanceSessionPermissions = TokenService.GerUserPermissions(PagePermission.AccessToVectorSurveillanceSession);
            EmployeeRecordPermissions = new UserPermissions();
            EmployeeRecordPermissions = TokenService.GerUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
        }

        #endregion Constructor

        #region Property Backing Variables

        private long? _vectorSessionKey;
        private string _sessionId;
        private string _detailSessionId;
        private string _fieldSessionId;
        private string _detailFieldSessionId;
        private long? _outbreakKey;
        private long? _siteId;
        private string _outbreakId;
        private bool _addToOutbreakIndicator;
        private DateTime? _startDate;
        private DateTime? _closeDate;
        private string _description;
        private long? _vectorTypeId;
        private long? _diseaseId;
        private long? _statusId;
        private int? _collectionEffort;
        private long? _geoLocationId;
        private long? _geoLocationTypeId;
        private string _locationDescription;
        private double? _locationDirection;
        private double? _locationDistance;
        private long? _locationGroundTypeId;
        private string _foreignAddress;
        private long? _vectorSessionSummaryKey;
        private string _summaryRecordId;
        private double? _summaryLocationDirection;
        private double? _summaryLocationDistance;
        private long? _summaryLocationGroundTypeId;
        private string _summaryLocationDescription;
        private string _summaryForeignAddress;
        private string _summaryLocationStreetName;
        private int? _poolsAndVectors;
        private long? _summaryInfoSexId;
        private long? _summaryInfoSpeciesId;
        private long? _summaryVectorTypeId;
        private int _summaryRowStatus;
        private int _summaryRowAction;
        private DateTime? _summaryCollectionDateTime;
        private long? _summaryGeoLocationTypeId;
        private long? _vectorDetailedCollectionKey;
        private long? _detailedCollectionIdfVector;
        private int _selectedVectorTab;
        private LocationViewModel _summaryLocationViewModel;
        private LocationViewModel _locationViewModel;
        private LocationViewModel _detailLocationViewModel;
        private double? _detailLocationDirection;
        private double? _detailLocationElevation;
        private double? _detailLocationDistance;
        private long? _detailLocationGroundTypeId;
        private string _detailLocationDescription;
        private long? _detailLocationSurroundings;
        private string _detailForeignAddress;
        private string _detailLocationStreetName;
        private long? _detailGeoLocationTypeId;
        private long? _detailLocationId;
        private string _detailPoolVectorIid;
        private string _detailFieldPoolVectorId;
        private long? _detailVectorTypeId;
        private string _detailGeoReferenceSource;
        private long? _detailBasisOfRecordId;
        private long? _detailHostReferenceId;
        private long? _detailCollectedByInstitutionId;
        private long? _detailCollectedByPersonId;
        private DateTime? _detailCollectionDate;
        private long? _detailCollectionTimePeriodId;
        private long? _detailCollectionMethodId;
        private long? _detailEctoparasitesCollectedId;
        private int? _detailQuantity;
        private long? _detailSpeciesId;
        private long? _detailSpeciesSexId;
        private long? _detailIdentifiedByInstitutionId;
        private long? _detailIdentifiedByPersonId;
        private long? _detailIdentifiedByMethodId;
        private DateTime? _detailIdentifiedDate;
        private string _detailComment;
        private long? _detailObservationId;
        private int _detailRowStatus;
        private int _detailRowAction;
        private int _aggregateCollectionsCount;
        private int _aggregateCollectionsDatabaseQueryCount;
        private int _aggregateNewCollectionsCount;
        private int _aggregateCollectionsLastDatabasePage;
        private IList<VectorSessionDetailResponseModel> _aggregateCollectionList;
        private IList<VectorSessionDetailResponseModel> _pendingAggregateCollectionList;
        private IList<USP_VCTS_VECT_GetDetailResponseModel> _detailedCollectionList;
        private IList<VectorDetailedCollectionViewModel> _detailedCollectionsDetailsList;
        private IList<VectorDetailedCollectionViewModel> _pendingDetailedCollectionsDetailsList;
        private IList<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel> _aggregateCollectionDiseaseList;
        private IList<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel> _pendingAggregateCollectionDiseaseList;
        private IList<VectorSampleGetListViewModel> _detailedCollectionsSamplesList;
        private IList<VectorSampleGetListViewModel> _pendingDetailedCollectionsSamplesList;
        private IList<FieldTestGetListViewModel> _detailedCollectionsFieldTestsList;
        private IList<FieldTestGetListViewModel> _pendingDetailedCollectionsFieldTestsList;
        private IList<USP_VCTS_LABTEST_GetListResponseModel> _laboratoryTestsList;
        private FieldTestGetListViewModel _fieldTestDetail;
        private VectorSampleGetListViewModel _sampleDetail;
        private FlexFormQuestionnaireGetRequestModel _vectorFlexForm;
        private bool _detailCollectionDisabledIndicator;
        private bool _aggregateCollectionDisabledIndicator;
        private bool _reportDisabledIndicator;

        #endregion Property Backing Variables

        #region Properties

        #region Surveillance Session Properties

        public long? VectorSessionKey
        { get => _vectorSessionKey; set { _vectorSessionKey = value; NotifyStateChanged("VectorSessionKey"); } }

        public string SessionID
        { get => _sessionId; set { _sessionId = value; NotifyStateChanged("SessionID"); } }

        public string DetailSessionID
        { get => _detailSessionId; set { _detailSessionId = value; NotifyStateChanged("DetailSessionID"); } }

        public string FieldSessionID
        { get => _fieldSessionId; set { _fieldSessionId = value; NotifyStateChanged("FieldSessionID"); } }

        public long? SiteID
        { get => _siteId; set { _siteId = value; NotifyStateChanged("SiteID"); } }

        public long? OutbreakKey
        { get => _outbreakKey; set { _outbreakKey = value; NotifyStateChanged("OutbreakKey"); } }

        public string OutbreakID
        { get => _outbreakId; set { _outbreakId = value; NotifyStateChanged("OutbreakID"); } }

        public bool AddingToOutbreakIndicator
        { get => _addToOutbreakIndicator; set { _addToOutbreakIndicator = value; NotifyStateChanged("AddingToOutbreakIndicator"); } }

        public DateTime? StartDate
        { get => _startDate; set { _startDate = value; NotifyStateChanged("StartDate"); } }

        public DateTime? CloseDate
        { get => _closeDate; set { _closeDate = value; NotifyStateChanged("CloseDate"); } }

        public string Description
        { get => _description; set { _description = value; NotifyStateChanged("Description"); } }

        public string VectorTypeString { get; set; }

        public long? VectorTypeID
        { get => _vectorTypeId; set { _vectorTypeId = value; NotifyStateChanged("VectorTypeID"); } }

        public string DiseaseString { get; set; }

        public long? DiseaseID
        { get => _diseaseId; set { _diseaseId = value; NotifyStateChanged("DiseaseID"); } }

        public long? StatusID
        { get => _statusId; set { _statusId = value; NotifyStateChanged("StatusID"); } }

        public int? CollectionEffort
        { get => _collectionEffort; set { _collectionEffort = value; NotifyStateChanged("CollectionEffort"); } }

        public long? GeoLocationID
        { get => _geoLocationId; set { _geoLocationId = value; NotifyStateChanged("GeoLocationID"); } }

        public long? GeoLocationTypeID
        { get => _geoLocationTypeId; set { _geoLocationTypeId = value; NotifyStateChanged("GeoLocationTypeID"); } }

        public double? LocationDirection
        { get => _locationDirection; set { _locationDirection = value; NotifyStateChanged("LocationDirection"); } }

        public double? LocationDistance
        { get => _locationDistance; set { _locationDistance = value; NotifyStateChanged("LocationDistance"); } }

        public long? LocationGroundTypeID
        { get => _locationGroundTypeId; set { _locationGroundTypeId = value; NotifyStateChanged("LocationGroundTypeID"); } }

        public string LocationDescription
        { get => _locationDescription; set { _locationDescription = value; NotifyStateChanged("LocationDescription"); } }

        public string ForeignAddress
        { get => _foreignAddress; set { _foreignAddress = value; NotifyStateChanged("ForeignAddress"); } }

        public LocationViewModel LocationViewModel
        { get => _locationViewModel; set { _locationViewModel = value; NotifyStateChanged("LocationViewModel"); } }

        public IList<VectorSessionDetailResponseModel> AggregateCollectionList
        { get => _aggregateCollectionList; set { _aggregateCollectionList = value; NotifyStateChanged("AggregateCollectionList"); } }

        public IList<VectorSessionDetailResponseModel> PendingAggregateCollectionList
        { get => _pendingAggregateCollectionList; set { _pendingAggregateCollectionList = value; NotifyStateChanged("PendingAggregateCollectionList"); } }

        public IList<USP_VCTS_VECT_GetDetailResponseModel> DetailedCollectionList
        { get => _detailedCollectionList; set { _detailedCollectionList = value; NotifyStateChanged("DetailedCollectionList"); } }

        #endregion Surveillance Session Properties

        #region Detailed Collection Properties

        public IList<VectorDetailedCollectionViewModel> DetailedCollectionsDetailsList
        { get => _detailedCollectionsDetailsList; set { _detailedCollectionsDetailsList = value; NotifyStateChanged("DetailedCollectionsDetailsList"); } }

        public IList<VectorDetailedCollectionViewModel> PendingDetailedCollectionsDetailsList
        { get => _pendingDetailedCollectionsDetailsList; set { _pendingDetailedCollectionsDetailsList = value; NotifyStateChanged("PendingDetailedCollectionsDetailsList"); } }

        public IList<VectorSampleGetListViewModel> DetailedCollectionsSamplesList
        { get => _detailedCollectionsSamplesList; set { _detailedCollectionsSamplesList = value; NotifyStateChanged("DetailedCollectionsSamplesList"); } }

        public IList<VectorSampleGetListViewModel> PendingDetailedCollectionsSamplesList
        { get => _pendingDetailedCollectionsSamplesList; set { _pendingDetailedCollectionsSamplesList = value; NotifyStateChanged("PendingDetailedCollectionsSamplesList"); } }

        public IList<FieldTestGetListViewModel> DetailedCollectionsFieldTestsList
        { get => _detailedCollectionsFieldTestsList; set { _detailedCollectionsFieldTestsList = value; NotifyStateChanged("DetailedCollectionsFieldTestsList"); } }

        public IList<FieldTestGetListViewModel> PendingDetailedCollectionsFieldTestsList
        { get => _pendingDetailedCollectionsFieldTestsList; set { _pendingDetailedCollectionsFieldTestsList = value; NotifyStateChanged("PendingDetailedCollectionsFieldTestsList"); } }

        public IList<USP_VCTS_LABTEST_GetListResponseModel> LaboratoryTestsList
        { get => _laboratoryTestsList; set { _laboratoryTestsList = value; NotifyStateChanged("LaboratoryTestsList"); } }

        public LocationViewModel DetailLocationViewModel
        { get => _detailLocationViewModel; set { _detailLocationViewModel = value; NotifyStateChanged("DetailLocationViewModel"); } }

        public string DetailFieldSessionID
        { get => _detailFieldSessionId; set { _detailFieldSessionId = value; NotifyStateChanged("DetailFieldSessionID"); } }

        public double? DetailLocationDirection
        { get => _detailLocationDirection; set { _detailLocationDirection = value; NotifyStateChanged("DetailLocationDirection"); } }

        public double? DetailLocationElevation
        { get => _detailLocationElevation; set { _detailLocationElevation = value; NotifyStateChanged("DetailLocationElevation"); } }

        public double? DetailLocationDistance
        { get => _detailLocationDistance; set { _detailLocationDistance = value; NotifyStateChanged("DetailLocationDistance"); } }

        public long? DetailLocationGroundTypeID
        { get => _detailLocationGroundTypeId; set { _detailLocationGroundTypeId = value; NotifyStateChanged("DetailLocationGroundTypeID"); } }

        public long? DetailLocationSurroundings
        { get => _detailLocationSurroundings; set { _detailLocationSurroundings = value; NotifyStateChanged("DetailLocationSurroundings"); } }

        public long? DetailLocationID
        { get => _detailLocationId; set { _detailLocationId = value; NotifyStateChanged("DetailLocationID"); } }

        public string DetailLocationDescription
        { get => _detailLocationDescription; set { _detailLocationDescription = value; NotifyStateChanged("DetailLocationDescription"); } }

        public string DetailForeignAddress
        { get => _detailForeignAddress; set { _detailForeignAddress = value; NotifyStateChanged("DetailForeignAddress"); } }

        public string DetailLocationStreetName
        { get => _detailLocationStreetName; set { _detailLocationStreetName = value; NotifyStateChanged("DetailLocationStreetName"); } }

        public long? DetailGeoLocationTypeID
        { get => _detailGeoLocationTypeId; set { _detailGeoLocationTypeId = value; NotifyStateChanged("DetailGeoLocationTypeID"); } }

        public string DetailPoolVectorIID
        { get => _detailPoolVectorIid; set { _detailPoolVectorIid = value; NotifyStateChanged("DetailPoolVectorIID"); } }

        public string DetailFieldPoolVectorID
        { get => _detailFieldPoolVectorId; set { _detailFieldPoolVectorId = value; NotifyStateChanged("DetailFieldPoolVectorID"); } }

        public long? DetailVectorTypeID
        { get => _detailVectorTypeId; set { _detailVectorTypeId = value; NotifyStateChanged("DetailVectorTypeID"); } }

        public string DetailGeoReferenceSource
        { get => _detailGeoReferenceSource; set { _detailGeoReferenceSource = value; NotifyStateChanged("DetailGeoReferenceSource"); } }

        public long? DetailBasisOfRecordID
        { get => _detailBasisOfRecordId; set { _detailBasisOfRecordId = value; NotifyStateChanged("DetailBasisOfRecordID"); } }

        public long? DetailHostReferenceID
        { get => _detailHostReferenceId; set { _detailHostReferenceId = value; NotifyStateChanged("DetailHostReferenceID"); } }

        public long? DetailCollectedByInstitutionID
        { get => _detailCollectedByInstitutionId; set { _detailCollectedByInstitutionId = value; NotifyStateChanged("DetailCollectedByInstitutionID"); } }

        public long? DetailCollectedByPersonID
        { get => _detailCollectedByPersonId; set { _detailCollectedByPersonId = value; NotifyStateChanged("DetailCollectedByPersonID"); } }

        public DateTime? DetailCollectionDate
        { get => _detailCollectionDate; set { _detailCollectionDate = value; NotifyStateChanged("DetailCollectionDate"); } }

        public long? DetailCollectionTimePeriodID
        { get => _detailCollectionTimePeriodId; set { _detailCollectionTimePeriodId = value; NotifyStateChanged("DetailCollectionTimePeriodID"); } }

        public long? DetailCollectionMethodID
        { get => _detailCollectionMethodId; set { _detailCollectionMethodId = value; NotifyStateChanged("DetailCollectionMethodID"); } }

        public long? DetailEctoparasitesCollectedID
        { get => _detailEctoparasitesCollectedId; set { _detailEctoparasitesCollectedId = value; NotifyStateChanged("DetailEctoparasitesCollectedID"); } }

        public int? DetailQuantity
        { get => _detailQuantity; set { _detailQuantity = value; NotifyStateChanged("DetailQuantity"); } }

        public long? DetailSpeciesID
        { get => _detailSpeciesId; set { _detailSpeciesId = value; NotifyStateChanged("DetailSpeciesID"); } }

        public long? DetailSpeciesSexID
        { get => _detailSpeciesSexId; set { _detailSpeciesSexId = value; NotifyStateChanged("DetailSpeciesSexID"); } }

        public long? DetailIdentifiedByInstitutionID
        { get => _detailIdentifiedByInstitutionId; set { _detailIdentifiedByInstitutionId = value; NotifyStateChanged("DetailIdentifiedByInstitutionID"); } }

        public long? DetailIdentifiedByPersonID
        { get => _detailIdentifiedByPersonId; set { _detailIdentifiedByPersonId = value; NotifyStateChanged("DetailIdentifiedByPersonID"); } }

        public long? DetailIdentifiedByMethodID
        { get => _detailIdentifiedByMethodId; set { _detailIdentifiedByMethodId = value; NotifyStateChanged("DetailIdentifiedByMethodID"); } }

        public DateTime? DetailIdentifiedDate
        { get => _detailIdentifiedDate; set { _detailIdentifiedDate = value; NotifyStateChanged("DetailIdentifiedDate"); } }

        public string DetailComment
        { get => _detailComment; set { _detailComment = value; NotifyStateChanged("DetailComment"); } }

        public long? DetailObservationID
        { get => _detailObservationId; set { _detailObservationId = value; NotifyStateChanged("DetailObservationID"); } }

        public int DetailRowStatus
        { get => _detailRowStatus; set { _detailRowStatus = value; NotifyStateChanged("DetailRowStatus"); } }

        public int DetailRowAction
        { get => _detailRowAction; set { _detailRowAction = value; NotifyStateChanged("DetailRowAction"); } }

        public FlexFormQuestionnaireGetRequestModel VectorFlexForm
        { get => _vectorFlexForm; set { _vectorFlexForm = value; NotifyStateChanged("VectorFlexForm"); } }

        public long? VectorDetailedCollectionKey
        { get => _vectorDetailedCollectionKey; set { _vectorDetailedCollectionKey = value; NotifyStateChanged("VectorDetailedCollectionKey"); } }

        public long? DetailedCollectionIdfVector
        { get => _detailedCollectionIdfVector; set { _detailedCollectionIdfVector = value; NotifyStateChanged("DetailedCollectionIdfVector"); } }

        public FieldTestGetListViewModel FieldTestDetail
        { get => _fieldTestDetail; set { _fieldTestDetail = value; NotifyStateChanged("FieldTestDetail"); } }

        public VectorSampleGetListViewModel SampleDetail
        { get => _sampleDetail; set { _sampleDetail = value; NotifyStateChanged("SampleDetail"); } }

        #endregion Detailed Collection Properties

        #region Aggregate Collection Properties

        public long? VectorSessionSummaryKey
        { get => _vectorSessionSummaryKey; set { _vectorSessionSummaryKey = value; NotifyStateChanged("VectorSessionSummaryKey"); } }

        public string SummaryRecordID
        { get => _summaryRecordId; set { _summaryRecordId = value; NotifyStateChanged("SummaryRecordID"); } }

        public double? SummaryLocationDirection
        { get => _summaryLocationDirection; set { _summaryLocationDirection = value; NotifyStateChanged("SummaryLocationDirection"); } }

        public double? SummaryLocationDistance
        { get => _summaryLocationDistance; set { _summaryLocationDistance = value; NotifyStateChanged("SummaryLocationDistance"); } }

        public long? SummaryLocationGroundTypeID
        { get => _summaryLocationGroundTypeId; set { _summaryLocationGroundTypeId = value; NotifyStateChanged("SummaryLocationGroundTypeID"); } }

        public string SummaryLocationDescription
        { get => _summaryLocationDescription; set { _summaryLocationDescription = value; NotifyStateChanged("SummaryLocationDescription"); } }

        public string SummaryLocationStreetName
        { get => _summaryLocationStreetName; set { _summaryLocationStreetName = value; NotifyStateChanged("SummaryLocationStreetName"); } }

        public string SummaryForeignAddress
        { get => _summaryForeignAddress; set { _summaryForeignAddress = value; NotifyStateChanged("SummaryForeignAddress"); } }

        public int? PoolsAndVectors
        { get => _poolsAndVectors; set { _poolsAndVectors = value; NotifyStateChanged("PoolsAndVectors"); } }

        public long? SummaryInfoSexID
        { get => _summaryInfoSexId; set { _summaryInfoSexId = value; NotifyStateChanged("SummaryInfoSexID"); } }

        public long? SummaryInfoSpeciesID
        { get => _summaryInfoSpeciesId; set { _summaryInfoSpeciesId = value; NotifyStateChanged("SummaryInfoSpeciesID"); } }

        public int SummaryRowStatus
        { get => _summaryRowStatus; set { _summaryRowStatus = value; NotifyStateChanged("SummaryRowStatus"); } }

        public int SummaryRowAction
        { get => _summaryRowAction; set { _summaryRowAction = value; NotifyStateChanged("SummaryRowAction"); } }

        public long? SummaryVectorTypeID
        { get => _summaryVectorTypeId; set { _summaryVectorTypeId = value; NotifyStateChanged("SummaryVectorTypeID"); } }

        public long? SummaryGeoLocationTypeID
        { get => _summaryGeoLocationTypeId; set { _summaryGeoLocationTypeId = value; NotifyStateChanged("SummaryGeoLocationTypeID"); } }

        public DateTime? SummaryCollectionDateTime
        { get => _summaryCollectionDateTime; set { _summaryCollectionDateTime = value; NotifyStateChanged("SummaryCollectionDateTime"); } }

        public int AggregateCollectionsCount
        { get => _aggregateCollectionsCount; set { _aggregateCollectionsCount = value; NotifyStateChanged("AggregateCollectionsCount"); } }

        public int AggregateCollectionsDatabaseQueryCount
        { get => _aggregateCollectionsDatabaseQueryCount; set { _aggregateCollectionsDatabaseQueryCount = value; NotifyStateChanged("AggregateCollectionsDatabaseQueryCount"); } }

        public int AggregateNewCollectionsCount
        { get => _aggregateNewCollectionsCount; set { _aggregateNewCollectionsCount = value; NotifyStateChanged("AggregateNewCollectionsCount"); } }

        public int AggregateCollectionsLastDatabasePage
        { get => _aggregateCollectionsLastDatabasePage; set { _aggregateCollectionsLastDatabasePage = value; NotifyStateChanged("AggregateCollectionsLastDatabasePage"); } }

        public IList<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel> AggregateCollectionDiseaseList
        { get => _aggregateCollectionDiseaseList; set { _aggregateCollectionDiseaseList = value; NotifyStateChanged("AggregateCollectionDiseaseList"); } }

        public IList<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel> PendingAggregateCollectionDiseaseList
        { get => _pendingAggregateCollectionDiseaseList; set { _pendingAggregateCollectionDiseaseList = value; NotifyStateChanged("PendingAggregateCollectionDiseaseList"); } }

        public LocationViewModel SummaryLocationViewModel
        { get => _summaryLocationViewModel; set { _summaryLocationViewModel = value; NotifyStateChanged("SummaryLocationViewModel"); } }

        #endregion Aggregate Collection Properties

        #region Common Properties

        public int SelectedVectorTab
        { get => _selectedVectorTab; set { _selectedVectorTab = value; NotifyStateChanged("SelectedVectorTab"); } }

        public UserPermissions VectorSurveillanceSessionPermissions { get; set; }

        public UserPermissions EmployeeRecordPermissions { get; set; }

        public List<EventSaveRequestModel> PendingSaveEvents { get; set; }

        public List<EventSaveRequestModel> PendingSaveFieldTestEvents { get; set; }

        #endregion Common Properties

        #endregion Properties

        #region Drop Down Collections

        public List<BaseReferenceViewModel> AnimalSexList { get; set; }
        public List<BaseReferenceViewModel> GeoTypes { get; set; }
        public List<BaseReferenceViewModel> GroundTypes { get; set; }
        public List<BaseReferenceEditorsViewModel> VectorTypesList { get; set; }
        public List<BaseReferenceEditorsViewModel> SpeciesList { get; set; }
        public List<OrganizationAdvancedGetListViewModel> Organizations { get; set; }

        #endregion Drop Down Collections

        #region Flags and Indicators

        public bool IsReadOnly { get; set; }
        public bool SessionSummaryValidIndicator { get; set; }
        public bool SessionSummaryModifiedIndicator { get; set; }
        public bool SessionLocationValidIndicator { get; set; }
        public bool SessionLocationModifiedIndicator { get; set; }
        public bool DetailCollectionsValidIndicator { get; set; }
        public bool DetailCollectionsVectorDataValidIndicator { get; set; }
        public bool DetailedCollectionsModifiedIndicator { get; set; }
        public bool AggregateCollectionsValidIndicator { get; set; }
        public bool AggregateCollectionsModifiedIndicator { get; set; }
        public bool AggregateCollectionLocationValidIndicator { get; set; }
        public bool AggregateCollectionLocationModifiedIndicator { get; set; }
        public bool AggregateCollectionsDiseaseListValidIndicator { get; set; }
        public bool AggregateCollectionsDiseaseListModifiedIndicator { get; set; }
        public bool CopyAllData { get; set; }
        public bool CopyVectorData { get; set; }
        public bool CopyVectorSpecificData { get; set; }
        public bool CopySamples { get; set; }
        public bool CopyFieldTests { get; set; }
        public bool DetailedCollectionTabDisabled { get; set; }
        public bool AggregateCollectionTabDisabled { get; set; }

        public bool ReportDisabledIndicator
        { get => _reportDisabledIndicator; set { _reportDisabledIndicator = value; NotifyStateChanged("ReportDisabledIndicator"); } }

        public bool DetailCollectionDisabledIndicator
        { get => _detailCollectionDisabledIndicator; set { _detailCollectionDisabledIndicator = value; NotifyStateChanged("DetailCollectionDisabledIndicator"); } }

        public bool AggregateCollectionDisabledIndicator
        { get => _aggregateCollectionDisabledIndicator; set { _aggregateCollectionDisabledIndicator = value; NotifyStateChanged("AggregateCollectionDisabledIndicator"); } }

        #endregion Flags and Indicators

        #region Events

        /// <summary>
        /// The delegate with the property name
        /// </summary>
        public event Action<string> OnChange;

        #endregion Events

        #region Methods

        #region Common Data Load Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task LoadOrganizations()
        {
            try
            {
                if (Organizations is null)
                {
                    OrganizationAdvancedGetRequestModel request = new()
                    {
                        LangID = GetCurrentLanguage(),
                        AccessoryCode = EIDSSConstants.HACodeList.VectorHACode,
                        AdvancedSearch = null,
                        SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite
                    };

                    var list = await _organizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                    Organizations = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Common Data Load Methods

        #region Private Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        protected void NotifyStateChanged(string property)
        {
            OnChange?.Invoke(property);
        }

        #endregion Private Methods

        #endregion Methods
    }
}