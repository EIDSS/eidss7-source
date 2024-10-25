using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Services
{
    public class VeterinaryAggregateActionsReportStateContainer : BaseServiceContainer
    {
        #region Member Variables

        private readonly ILogger<VeterinaryAggregateActionsReportStateContainer> _logger;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IOrganizationClient _organizationClient;
        private readonly IAggregateSettingsClient _aggregateSettingsClient;
        private readonly IAggregateReportClient _aggregateReportClient;
        private readonly IUserConfigurationService _configurationService;
        private bool _orgGetWasCalled;

        #endregion Member Variables

        #region Constructor

        public VeterinaryAggregateActionsReportStateContainer(
            ILogger<VeterinaryAggregateActionsReportStateContainer> logger,
            ICrossCuttingClient crossCuttingClient,
            IOrganizationClient organizationClient,
            IAggregateSettingsClient aggregateSettingsClient,
            IAggregateReportClient aggregateReportClient,
            IUserConfigurationService configurationService,
            ITokenService tokenService,
            IConfiguration configuration
            ) : base(logger, tokenService, configuration)
        {
            _logger = logger;
            _crossCuttingClient = crossCuttingClient;
            _organizationClient = organizationClient;
            _aggregateSettingsClient = aggregateSettingsClient;
            _aggregateReportClient = aggregateReportClient;
            _configurationService = configurationService;

            _reportLocationViewModel = new LocationViewModel();
            _veterinaryAggregateActionsReportPermissions = new UserPermissions();
            _employeeListPermissions = new UserPermissions();
            _diagnosticFlexFormRequest = new FlexFormQuestionnaireGetRequestModel
            {
                MatrixData = new List<FlexFormMatrixData>()
            };
            _treatmentFlexFormRequest = new FlexFormQuestionnaireGetRequestModel
            {
                MatrixData = new List<FlexFormMatrixData>()
            };
            _sanitaryFlexFormRequest = new FlexFormQuestionnaireGetRequestModel
            {
                MatrixData = new List<FlexFormMatrixData>()
            };
        }

        #endregion Constructor

        #region Property Backing Variables

        private long _reportKey;
        private string _reportId;
        private string _legacyId;
        private bool _isReadOnly;
        private long? _siteId;
        private long? _userId;

        private string _siteName;
        private long? _reportedByOrganizationId;
        private long? _notificationSentInstitutionId;
        private string _notificationSentInstitution;
        private long? _notificationSentOfficerId;
        private string _notificationSentOfficer;
        private DateTime? _notificationSentDate;
        private long? _notificationReceivedInstitutionId;
        private string _notificationReceivedInstitution;
        private long? _notificationReceivedOfficerId;
        private string _notificationReceivedOfficer;
        private DateTime? _notificationReceivedDate;
        private long? _notificationEnteredInstitutionId;
        private string _notificationEnteredInstitution;
        private long? _notificationEnteredOfficerId;
        private string _notificationEnteredOfficer;
        private DateTime? _notificationEnteredDate;
        private long? _periodType;
        private int _periodLowestLevel;
        private string _periodName;
        private int? _year;
        private int? _month;
        private int? _quarter;
        private int? _week;
        private bool _showYear;
        private bool _showMonth;
        private bool _showQuarter;
        private bool _showWeek;
        private bool _showDay;
        private DateTime? _day;
        private DateTime? _startDate;
        private DateTime? _endDate;
        private long? _countryId;
        private long? _regionId;
        private long? _rayonId;
        private long? _settlementId;
        private long? _administrativeUnitId;
        private long? _organizationalLocationId;
        private long? _organizationId;
        private bool _showOrganization;
        private long? _areaType;
        private LocationViewModel _reportLocationViewModel;
        private long? _diagnosticMatrixVersionId;
        private long? _diagnosticObservationId;
        private long? _diagnosticMatrixVersionIdDefault;
        private long? _diagnosticTemplateIdDefault;
        private bool _diagnosticFlexFormRenderIndicator;
        private FlexFormQuestionnaireGetRequestModel _diagnosticFlexFormRequest;
        private IList<MatrixVersionViewModel> _diagnosticMatrixList;
        private IList<FlexFormTemplateListViewModel> _diagnosticTemplatesList;
        private long? _treatmentMatrixVersionId;
        private long? _treatmentObservationId;
        private long? _treatmentMatrixVersionIdDefault;
        private long? _treatmentTemplateIdDefault;
        private bool _treatmentFlexFormRenderIndicator;
        private FlexFormQuestionnaireGetRequestModel _treatmentFlexFormRequest;
        private IList<MatrixVersionViewModel> _treatmentMatrixList;
        private IList<FlexFormTemplateListViewModel> _treatmentTemplatesList;
        private long? _sanitaryMatrixVersionId;
        private long? _sanitaryObservationId;
        private long? _sanitaryMatrixVersionIdDefault;
        private long? _sanitaryTemplateIdDefault;
        private bool _sanitaryFlexFormRenderIndicator;
        private FlexFormQuestionnaireGetRequestModel _sanitaryFlexFormRequest;
        private IList<MatrixVersionViewModel> _sanitaryMatrixList;
        private IList<FlexFormTemplateListViewModel> _sanitaryTemplatesList;
        private UserPermissions _veterinaryAggregateActionsReportPermissions;
        private UserPermissions _employeeListPermissions;
        private AggregateSettingsViewModel _aggregateSettings;
        private bool _informationReportDisabledIndicator;
        private bool _diagnosticReportDisabledIndicator;
        private bool _sanitaryReportDisabledIndicator;
        private bool _treatmentReportDisabledIndicator;

        #endregion Property Backing Variables

        #region Properties

        public long ReportKey
        { get => _reportKey; set { _reportKey = value; NotifyStateChanged("ReportKey"); } }

        public string ReportID
        { get => _reportId; set { _reportId = value; NotifyStateChanged("ReportID"); } }

        public bool IsReadOnly
        { get => _isReadOnly; set { _isReadOnly = value; NotifyStateChanged("IsReadOnly"); } }

        public string LegacyID
        { get => _legacyId; set { _legacyId = value; NotifyStateChanged("LegacyID"); } }

        public long? SiteID
        { get => _siteId; set { _siteId = value; NotifyStateChanged("SiteID"); } }

        public long? UserId
        { get => _userId; set { _userId = value; NotifyStateChanged("UserId"); } }

        public string SiteName
        { get => _siteName; set { _siteName = value; NotifyStateChanged("SiteName"); } }

        public long? ReportedByOrganizationID
        { get => _reportedByOrganizationId; set { _reportedByOrganizationId = value; NotifyStateChanged("ReportedByOrganizationID"); } }

        public long? NotificationSentInstitutionID
        { get => _notificationSentInstitutionId; set { _notificationSentInstitutionId = value; NotifyStateChanged("NotificationSentInstitutionID"); } }

        public string NotificationSentInstitution
        { get => _notificationSentInstitution; set { _notificationSentInstitution = value; NotifyStateChanged("NotificationSentInstitution"); } }

        public long? NotificationSentOfficerID
        { get => _notificationSentOfficerId; set { _notificationSentOfficerId = value; NotifyStateChanged("NotificationSentOfficerID"); } }

        public string NotificationSentOfficer
        { get => _notificationSentOfficer; set { _notificationSentOfficer = value; NotifyStateChanged("NotificationSentOfficer"); } }

        public DateTime? NotificationSentDate
        { get => _notificationSentDate; set { _notificationSentDate = value; NotifyStateChanged("NotificationSentDate"); } }

        public long? NotificationReceivedInstitutionID
        { get => _notificationReceivedInstitutionId; set { _notificationReceivedInstitutionId = value; NotifyStateChanged("NotificationReceivedInstitutionID"); } }

        public string NotificationReceivedInstitution
        { get => _notificationReceivedInstitution; set { _notificationReceivedInstitution = value; NotifyStateChanged("NotificationReceivedInstitution"); } }

        public long? NotificationReceivedOfficerID
        { get => _notificationReceivedOfficerId; set { _notificationReceivedOfficerId = value; NotifyStateChanged("NotificationReceivedOfficerID"); } }

        public string NotificationReceivedOfficer
        { get => _notificationReceivedOfficer; set { _notificationReceivedOfficer = value; NotifyStateChanged("NotificationReceivedOfficer"); } }

        public DateTime? NotificationReceivedDate
        { get => _notificationReceivedDate; set { _notificationReceivedDate = value; NotifyStateChanged("NotificationReceivedDate"); } }

        public long? NotificationEnteredInstitutionID
        { get => _notificationEnteredInstitutionId; set { _notificationEnteredInstitutionId = value; NotifyStateChanged("NotificationEnteredInstitutionID"); } }

        public string NotificationEnteredInstitution
        { get => _notificationEnteredInstitution; set { _notificationEnteredInstitution = value; NotifyStateChanged("NotificationEnteredInstitution"); } }

        public long? NotificationEnteredOfficerID
        { get => _notificationEnteredOfficerId; set { _notificationEnteredOfficerId = value; NotifyStateChanged("NotificationEnteredOfficerID"); } }

        public string NotificationEnteredOfficer
        { get => _notificationEnteredOfficer; set { _notificationEnteredOfficer = value; NotifyStateChanged("NotificationEnteredOfficer"); } }

        public DateTime? NotificationEnteredDate
        { get => _notificationEnteredDate; set { _notificationEnteredDate = value; NotifyStateChanged("NotificationEnteredDate"); } }

        public long? PeriodType
        { get => _periodType; set { _periodType = value; NotifyStateChanged("PeriodType"); } }

        public int PeriodLowestLevel
        { get => _periodLowestLevel; set { _periodLowestLevel = value; NotifyStateChanged("PeriodLowestLevel"); } }

        public string PeriodName
        { get => _periodName; set { _periodName = value; NotifyStateChanged("PeriodName"); } }

        public int? Year
        { get => _year; set { _year = value; NotifyStateChanged("Year"); } }

        public int? Month
        { get => _month; set { _month = value; NotifyStateChanged("Month"); } }

        public int? Quarter
        { get => _quarter; set { _quarter = value; NotifyStateChanged("Quarter"); } }

        public int? Week
        { get => _week; set { _week = value; NotifyStateChanged("Week"); } }

        public bool ShowYear
        { get => _showYear; set { _showYear = value; NotifyStateChanged("ShowYear"); } }

        public bool ShowQuarter
        { get => _showQuarter; set { _showQuarter = value; NotifyStateChanged("ShowQuarter"); } }

        public bool ShowMonth
        { get => _showMonth; set { _showMonth = value; NotifyStateChanged("ShowMonth"); } }

        public bool ShowWeek
        { get => _showWeek; set { _showWeek = value; NotifyStateChanged("ShowWeek"); } }

        public bool ShowDay
        { get => _showDay; set { _showDay = value; NotifyStateChanged("ShowDay"); } }

        public DateTime? Day
        { get => _day; set { _day = value; NotifyStateChanged("Day"); } }

        public DateTime? StartDate
        { get => _startDate; set { _startDate = value; NotifyStateChanged("StartDate"); } }

        public DateTime? EndDate
        { get => _endDate; set { _endDate = value; NotifyStateChanged("EndDate"); } }

        public long? OrganizationID
        { get => _organizationId; set { _organizationId = value; NotifyStateChanged("OrganizationID"); } }

        public bool ShowOrganization
        { get => _showOrganization; set { _showOrganization = value; NotifyStateChanged("ShowOrganization"); } }

        public long? AdministrativeUnitID
        { get => _administrativeUnitId; set { _administrativeUnitId = value; NotifyStateChanged("AdministrativeUnitID"); } }

        public long? OrganizationalLocationID
        { get => _organizationalLocationId; set { _organizationalLocationId = value; NotifyStateChanged("OrganizationalLocationID"); } }

        public long? AreaTypeID
        { get => _areaType; set { _areaType = value; NotifyStateChanged("AreaTypeID"); } }

        public long? CountryID
        { get => _countryId; set { _countryId = value; NotifyStateChanged("CountryID"); } }

        public long? RegionID
        { get => _regionId; set { _regionId = value; NotifyStateChanged("RegionID"); } }

        public long? RayonID
        { get => _rayonId; set { _rayonId = value; NotifyStateChanged("RayonID"); } }

        public long? SettlementID
        { get => _settlementId; set { _settlementId = value; NotifyStateChanged("SettlementID"); } }

        public LocationViewModel ReportLocationViewModel
        { get => _reportLocationViewModel; set { _reportLocationViewModel = value; NotifyStateChanged("ReportLocationViewModel"); } }

        public long? DiagnosticMatrixVersionID
        { get => _diagnosticMatrixVersionId; set { _diagnosticMatrixVersionId = value; NotifyStateChanged("DiagnosticMatrixVersionID"); } }

        public long? DiagnosticObservationID
        { get => _diagnosticObservationId; set { _diagnosticObservationId = value; NotifyStateChanged("DiagnosticObservationID"); } }

        public long? DiagnosticMatrixVersionIDDefault
        { get => _diagnosticMatrixVersionIdDefault; set { _diagnosticMatrixVersionIdDefault = value; NotifyStateChanged("DiagnosticMatrixVersionIDDefault"); } }

        public IList<MatrixVersionViewModel> DiagnosticMatrixList
        { get => _diagnosticMatrixList; set { _diagnosticMatrixList = value; NotifyStateChanged("DiagnosticMatrixList"); } }

        public IList<FlexFormTemplateListViewModel> DiagnosticTemplatesList
        { get => _diagnosticTemplatesList; set { _diagnosticTemplatesList = value; NotifyStateChanged("DiagnosticTemplatesList"); } }

        public long? DiagnosticTemplateIDDefault
        { get => _diagnosticTemplateIdDefault; set { _diagnosticTemplateIdDefault = value; NotifyStateChanged("DiagnosticTemplateIDDefault"); } }

        public FlexFormQuestionnaireGetRequestModel DiagnosticFlexFormRequest
        { get => _diagnosticFlexFormRequest; set { _diagnosticFlexFormRequest = value; NotifyStateChanged("DiagnosticFlexFormRequest"); } }

        public bool DiagnosticFlexFormRenderIndicator
        { get => _diagnosticFlexFormRenderIndicator; set { _diagnosticFlexFormRenderIndicator = value; NotifyStateChanged("DiagnosticFlexFormRenderIndicator"); } }

        public long? TreatmentMatrixVersionID
        { get => _treatmentMatrixVersionId; set { _treatmentMatrixVersionId = value; NotifyStateChanged("TreatmentMatrixVersionID"); } }

        public long? TreatmentObservationID
        { get => _treatmentObservationId; set { _treatmentObservationId = value; NotifyStateChanged("TreatmentObservationID"); } }

        public long? TreatmentMatrixVersionIDDefault
        { get => _treatmentMatrixVersionIdDefault; set { _treatmentMatrixVersionIdDefault = value; NotifyStateChanged("TreatmentMatrixVersionIDDefault"); } }

        public IList<MatrixVersionViewModel> TreatmentMatrixList
        { get => _treatmentMatrixList; set { _treatmentMatrixList = value; NotifyStateChanged("TreatmentMatrixList"); } }

        public IList<FlexFormTemplateListViewModel> TreatmentTemplatesList
        { get => _treatmentTemplatesList; set { _treatmentTemplatesList = value; NotifyStateChanged("TreatmentTemplatesList"); } }

        public long? TreatmentTemplateIDDefault
        { get => _treatmentTemplateIdDefault; set { _treatmentTemplateIdDefault = value; NotifyStateChanged("TreatmentTemplateIDDefault"); } }

        public FlexFormQuestionnaireGetRequestModel TreatmentFlexFormRequest
        { get => _treatmentFlexFormRequest; set { _treatmentFlexFormRequest = value; NotifyStateChanged("TreatmentFlexFormRequest"); } }

        public bool TreatmentFlexFormRenderIndicator
        { get => _treatmentFlexFormRenderIndicator; set { _treatmentFlexFormRenderIndicator = value; NotifyStateChanged("TreatmentFlexFormRenderIndicator"); } }

        public long? SanitaryMatrixVersionID
        { get => _sanitaryMatrixVersionId; set { _sanitaryMatrixVersionId = value; NotifyStateChanged("SanitaryMatrixVersionID"); } }

        public long? SanitaryObservationID
        { get => _sanitaryObservationId; set { _sanitaryObservationId = value; NotifyStateChanged("SanitaryObservationID"); } }

        public long? SanitaryMatrixVersionIDDefault
        { get => _sanitaryMatrixVersionIdDefault; set { _sanitaryMatrixVersionIdDefault = value; NotifyStateChanged("SanitaryMatrixVersionIDDefault"); } }

        public IList<MatrixVersionViewModel> SanitaryMatrixList
        { get => _sanitaryMatrixList; set { _sanitaryMatrixList = value; NotifyStateChanged("SanitaryMatrixList"); } }

        public IList<FlexFormTemplateListViewModel> SanitaryTemplatesList
        { get => _sanitaryTemplatesList; set { _sanitaryTemplatesList = value; NotifyStateChanged("SanitaryTemplatesList"); } }

        public long? SanitaryTemplateIDDefault
        { get => _sanitaryTemplateIdDefault; set { _sanitaryTemplateIdDefault = value; NotifyStateChanged("SanitaryTemplateIDDefault"); } }

        public FlexFormQuestionnaireGetRequestModel SanitaryFlexFormRequest
        { get => _sanitaryFlexFormRequest; set { _sanitaryFlexFormRequest = value; NotifyStateChanged("SanitaryFlexFormRequest"); } }

        public bool SanitaryFlexFormRenderIndicator
        { get => _sanitaryFlexFormRenderIndicator; set { _sanitaryFlexFormRenderIndicator = value; NotifyStateChanged("SanitaryFlexFormRenderIndicator"); } }

        public UserPermissions VeterinaryAggregateActionsReportPermissions
        { get => _veterinaryAggregateActionsReportPermissions; set { _veterinaryAggregateActionsReportPermissions = value; NotifyStateChanged("VeterinaryAggregateActionsReportPermissions"); } }

        public UserPermissions EmployeeListPermissions
        { get => _employeeListPermissions; set { _employeeListPermissions = value; NotifyStateChanged("EmployeeListPermissions"); } }

        public AggregateSettingsViewModel AggregateSettings
        { get => _aggregateSettings; set { _aggregateSettings = value; NotifyStateChanged("AggregateSettings"); } }

        #region Common List Properties

        public IList<Period> Years { get; set; }
        public IList<Period> Quarters { get; set; }
        public IList<Period> Months { get; set; }
        public IList<Period> Weeks { get; set; }
        public IList<OrganizationAdvancedGetListViewModel> Organizations { get; set; }
        public int OrganizationCount { get; set; }
        public IList<EventSaveRequestModel> PendingSaveEvents { get; set; }

        #endregion Common List Properties

        #endregion Properties

        #region Indicators

        public bool ReportInformationValidIndicator { get; set; }
        public bool ReportInformationModifiedIndicator { get; set; }
        public bool DiagnosticSectionValidIndicator { get; set; }
        public bool TreatmentSectionValidIndicator { get; set; }
        public bool SanitarySectionValidIndicator { get; set; }

        public bool InformationReportDisabledIndicator
        {
            get => _informationReportDisabledIndicator;
            set
            {
                _informationReportDisabledIndicator = value;
                NotifyStateChanged("InformationReportDisabledIndicator");
            }
        }

        public bool DiagnosticReportDisabledIndicator
        {
            get => _diagnosticReportDisabledIndicator;
            set
            {
                _diagnosticReportDisabledIndicator = value;
                NotifyStateChanged("DiagnosticReportDisabledIndicator");
            }
        }

        public bool SanitaryReportDisabledIndicator
        {
            get => _sanitaryReportDisabledIndicator;
            set
            {
                _sanitaryReportDisabledIndicator = value;
                NotifyStateChanged("SanitaryReportDisabledIndicator");
            }
        }

        public bool TreatmentReportDisabledIndicator
        {
            get => _treatmentReportDisabledIndicator;
            set
            {
                _treatmentReportDisabledIndicator = value;
                NotifyStateChanged("TreatmentReportDisabledIndicator");
            }
        }

        public bool DeletePermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }

        #endregion Indicators

        #region Events

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;

        public event Action OnStateLoaded;

        #endregion Events

        #region Common Data Load Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task LoadOrganizations()
        {
            try
            {
                if (Organizations is null && !_orgGetWasCalled)
                {
                    OrganizationAdvancedGetRequestModel request = new()
                    {
                        LangID = GetCurrentLanguage(),
                        AccessoryCode = HACodeList.LiveStockAndAvian,
                        AdvancedSearch = null,
                        SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite
                    };

                    var list = await _organizationClient.GetOrganizationAdvancedList(request).ConfigureAwait(false);

                    Organizations = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();

                    _orgGetWasCalled = true;
                    OrganizationCount = Organizations?.Count ?? 0;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void LoadYears(LoadDataArgs args)
        {
            List<Period> list = new();

            try
            {
                //Range of years to be 1900 to current year, descending
                for (var y = DateTime.Today.Year; y >= 1900; y += -1)
                {
                    list.Add(new Period() { PeriodNumber = y, PeriodName = y.ToString() });
                }

                Years = list.ToList();

                if (!IsNullOrEmpty(args.Filter))
                {
                    Years = Years.Where(x => x.PeriodName.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadMonths(LoadDataArgs args)
        {
            try
            {
                var yearPeriod = Year == null ? DateTime.Today.Year : int.Parse(Year.ToString());
                var d = DateTime.Today;
                var list = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());
                Months = new List<Period>();

                if (yearPeriod == d.Year)
                {
                    foreach (var monthPeriod in list.Where(monthPeriod => monthPeriod.intOrder <= d.Month))
                    {
                        if (monthPeriod.intOrder != null)
                            Months.Add(new Period
                            {
                                PeriodID = monthPeriod.idfsReference.ToString(),
                                PeriodName = monthPeriod.strTextString,
                                PeriodNumber = (int)monthPeriod.intOrder
                            });
                    }
                }
                else
                {
                    Months = list.Select(m => new Period()
                    {
                        PeriodID = m.idfsReference.ToString(),
                        PeriodName = m.strTextString,
                        PeriodNumber = list.IndexOf(m) + 1
                    }).ToList();
                }

                if (!IsNullOrEmpty(args.Filter))
                {
                    Months = Months.Where(x => x.PeriodName.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void LoadWeeks(LoadDataArgs args)
        {
            List<Period> list = new();

            try
            {
                var yearPeriod = Year ?? DateTime.Today.Year;
                var currentYear = DateTime.Now.Year;

                var dt = Common.FillWeekList(yearPeriod);
                list.AddRange(from DataRow row in dt.Rows
                              select new Period()
                              {
                                  PeriodNumber = int.Parse(row["PeriodNumber"].ToString() ?? "1"),
                                  PeriodName = row["PeriodName"].ToString(),
                                  StartDay = DateTime.Parse(row["StartDay"].ToString() ?? DateTime.MinValue.ToShortDateString()),
                                  FinishDay = DateTime.Parse(row["FinishDay"].ToString() ?? DateTime.MinValue.ToShortDateString()),
                              });

                Weeks = list.ToList();

                // if we are not the current year then we have to start in January 1
                if (_year != currentYear)
                {
                    if (Weeks.FirstOrDefault() != null)
                    {
                        Week = Weeks.FirstOrDefault()?.PeriodNumber;
                    }
                }
                else if (Weeks.LastOrDefault() != null)
                {
                    Week = Weeks.LastOrDefault()?.PeriodNumber;
                }

                if (!IsNullOrEmpty(args.Filter))
                {
                    Weeks = Weeks.Where(x => x.PeriodName.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void LoadQuarters(LoadDataArgs args)
        {
            List<Period> list = new();

            try
            {
                var yearPeriod = Year ?? DateTime.Today.Year;
                var startMonth = 1;
                for (var i = 1; i <= 4; i++)
                {
                    var endMonth = startMonth + 2;
                    var period = new Period()
                    {
                        PeriodNumber = i,
                        PeriodName = Common.GetQuarterText(i, yearPeriod),
                        StartDay = new DateTime(yearPeriod, startMonth, 1),
                        FinishDay = new DateTime(yearPeriod, endMonth, DateTime.DaysInMonth(yearPeriod, endMonth))
                    };
                    list.Add(period);
                    startMonth += 3;
                }

                Quarters = list.ToList();

                if (!IsNullOrEmpty(args.Filter))
                {
                    Quarters = Quarters.Where(x => x.PeriodName.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Common Data Load Methods

        #region Initialize Model

        public async Task InitializeModel()
        {
            VeterinaryAggregateActionsReportPermissions ??= new UserPermissions();
            VeterinaryAggregateActionsReportPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);

            var noCreateOrWritePermission = !VeterinaryAggregateActionsReportPermissions.Create ||
                                            !VeterinaryAggregateActionsReportPermissions.Write;
            InformationReportDisabledIndicator = noCreateOrWritePermission;
            DiagnosticReportDisabledIndicator = noCreateOrWritePermission;
            TreatmentReportDisabledIndicator = noCreateOrWritePermission;
            SanitaryReportDisabledIndicator = noCreateOrWritePermission;

            CreatePermissionIndicator = VeterinaryAggregateActionsReportPermissions.Create;
            WritePermissionIndicator = VeterinaryAggregateActionsReportPermissions.Write;
            ReadPermissionIndicator = VeterinaryAggregateActionsReportPermissions.Read;

            EmployeeListPermissions ??= new UserPermissions();
            EmployeeListPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            var request = new AggregateSettingsGetRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                IdfCustomizationPackage = Convert.ToInt64(GlobalConstants.CustomizationPackageID),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "idfsAggrCaseType",
                SortOrder = SortConstants.Ascending
            };
            var settings = await _aggregateSettingsClient.GetAggregateSettingsList(request).ConfigureAwait(false);
            if (settings != null && settings.Any())
            {
                AggregateSettings = settings.First(x => x.idfsAggrCaseType == Convert.ToInt64(AggregateValue.VeterinaryAction));
            }
            else
            {
                AggregateSettings = new AggregateSettingsViewModel();
            }

            // location display is based on aggregate settings
            var bottomAdmin = AggregateSettings.idfsStatisticAreaType;

            // set the properties on the location control
            ReportLocationViewModel ??= new LocationViewModel();
            SetAdministrativeLevels(bottomAdmin);
        }

        public async Task SetNewRecordDefaults()
        {
            ReportKey = 0;
            NotificationEnteredOfficer = GetDefaultUserName();
            SiteName = authenticatedUser.Organization;
            SiteID = Convert.ToInt64(authenticatedUser.SiteId);
            UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId);

            NotificationEnteredDate = DateTime.Now;
            NotificationEnteredOfficerID = Convert.ToInt64(authenticatedUser.PersonId);
            NotificationEnteredInstitution = authenticatedUser.Organization;
            NotificationEnteredInstitutionID = authenticatedUser.OfficeId;

            Year = DateTime.Today.Year;

            // set the time period to show according to aggregate settings
            SetTimePeriodsToShow(AggregateSettings.idfsStatisticPeriodType.ToString());

            // Load the time period lists
            LoadYears(new LoadDataArgs());
            await LoadMonths(new LoadDataArgs());
            LoadQuarters(new LoadDataArgs());
            LoadWeeks(new LoadDataArgs());

            // disabled indicator
            if ((ReportKey <= 0 && !VeterinaryAggregateActionsReportPermissions.Create)
                || (ReportKey > 0 && !VeterinaryAggregateActionsReportPermissions.Write))
            {
                InformationReportDisabledIndicator = true;
                DiagnosticReportDisabledIndicator = true;
                SanitaryReportDisabledIndicator = true;
                TreatmentReportDisabledIndicator = true;
            }

            // set the administrative levels to show according to aggregate settings
            SetAdministrativeLevels(AggregateSettings.idfsStatisticAreaType);

            // raise the state loaded event
            NotifyStateLoaded();
        }

        public void SetTimePeriodsToShow(string timePeriod)
        {
            // determine the period drop downs to show
            switch (timePeriod)
            {
                case StatisticPeriodType.Year:
                    ShowYear = true;
                    break;

                case StatisticPeriodType.Quarter:
                    ShowQuarter = true;
                    ShowYear = true;
                    break;

                case StatisticPeriodType.Month:
                    ShowMonth = true;
                    ShowYear = true;
                    break;

                case StatisticPeriodType.Week:
                    ShowWeek = true;
                    ShowYear = true;
                    break;

                case StatisticPeriodType.Day:
                    ShowDay = true;
                    ShowMonth = true;
                    ShowYear = true;
                    break;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="administrativeUnitType"></param>
        public void SetAdministrativeLevels(long administrativeUnitType)
        {
            var userPreferences = _configurationService.GetUserPreferences(authenticatedUser.UserName);
            var defaultAdministrativeLevel1Value =
                userPreferences.DefaultRegionInSearchPanels ? authenticatedUser.RegionId : (long?)null;
            var defaultAdministrativeLevel2Value =
                userPreferences.DefaultRayonInSearchPanels ? authenticatedUser.RayonId : (long?)null;

            // defaults for location control
            ReportLocationViewModel.IsHorizontalLayout = true;
            ReportLocationViewModel.ShowAdminLevel0 = true;
            ReportLocationViewModel.ShowAdminLevel1 = true;
            ReportLocationViewModel.ShowAdminLevel2 = true;
            ReportLocationViewModel.ShowAdminLevel3 = administrativeUnitType >= Convert.ToInt64(StatisticAreaType.Settlement);
            ReportLocationViewModel.ShowAdminLevel4 = administrativeUnitType > Convert.ToInt64(StatisticAreaType.Settlement);
            ReportLocationViewModel.ShowAdminLevel5 = administrativeUnitType > Convert.ToInt64(StatisticAreaType.Settlement);
            ReportLocationViewModel.ShowAdminLevel6 = administrativeUnitType > Convert.ToInt64(StatisticAreaType.Settlement);
            ReportLocationViewModel.AdministrativeLevelEnabled = true;
            ReportLocationViewModel.EnableAdminLevel0 = false;
            ReportLocationViewModel.EnableAdminLevel1 = !InformationReportDisabledIndicator;
            ReportLocationViewModel.EnableAdminLevel2 = !InformationReportDisabledIndicator;
            ReportLocationViewModel.EnableAdminLevel3 = !InformationReportDisabledIndicator;
            ReportLocationViewModel.EnableAdminLevel4 = !InformationReportDisabledIndicator;
            ReportLocationViewModel.EnableAdminLevel5 = !InformationReportDisabledIndicator;
            ReportLocationViewModel.EnableAdminLevel6 = !InformationReportDisabledIndicator;
            ReportLocationViewModel.EnableApartment = false;
            ReportLocationViewModel.EnableBuilding = false;
            ReportLocationViewModel.EnableBuilding = false;
            ReportLocationViewModel.EnabledElevation = false;
            ReportLocationViewModel.EnabledLatitude = false;
            ReportLocationViewModel.EnabledLongitude = false;
            ReportLocationViewModel.ShowSettlement = true;
            ReportLocationViewModel.ShowSettlementType = true;
            ReportLocationViewModel.ShowStreet = false;
            ReportLocationViewModel.ShowBuilding = false;
            ReportLocationViewModel.ShowApartment = false;
            ReportLocationViewModel.ShowElevation = false;
            ReportLocationViewModel.ShowHouse = false;
            ReportLocationViewModel.ShowLatitude = false;
            ReportLocationViewModel.ShowLongitude = false;
            ReportLocationViewModel.ShowMap = false;
            ReportLocationViewModel.ShowBuildingHouseApartmentGroup = false;
            ReportLocationViewModel.ShowPostalCode = false;
            ReportLocationViewModel.ShowCoordinates = false;
            ReportLocationViewModel.AdminLevel0Value = Convert.ToInt64(base.CountryID);
            ReportLocationViewModel.IsDbRequiredAdminLevel0 = false;
            ReportLocationViewModel.IsDbRequiredAdminLevel1 = false;
            ReportLocationViewModel.IsDbRequiredAdminLevel2 = false;
            ReportLocationViewModel.IsDbRequiredAdminLevel3 = false;
            ReportLocationViewModel.IsDbRequiredAdminLevel4 = false;
            ReportLocationViewModel.IsDbRequiredAdminLevel5 = false;
            ReportLocationViewModel.IsDbRequiredAdminLevel6 = false;
            ReportLocationViewModel.IsDbRequiredSettlement = false;
            ReportLocationViewModel.IsDbRequiredSettlementType = false;
            //ReportLocationViewModel.AlwaysDisabled = ReportDisabledIndicator;

            switch (administrativeUnitType)
            {
                case (long)AdministrativeUnitTypes.Country:
                    ReportLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    ReportLocationViewModel.EnableAdminLevel0 = false;
                    ReportLocationViewModel.ShowAdminLevel0 = true;
                    ReportLocationViewModel.ShowAdminLevel1 = false;
                    ReportLocationViewModel.ShowAdminLevel2 = false;
                    ReportLocationViewModel.ShowAdminLevel3 = false;
                    ReportLocationViewModel.ShowAdminLevel4 = false;
                    ReportLocationViewModel.ShowAdminLevel5 = false;
                    ReportLocationViewModel.ShowAdminLevel6 = false;
                    ReportLocationViewModel.ShowSettlement = false;
                    ReportLocationViewModel.ShowSettlementType = false;
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel0Value;
                    break;

                case (long)AdministrativeUnitTypes.Region:
                    ReportLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel1 = true;
                    ReportLocationViewModel.ShowAdminLevel0 = true;
                    ReportLocationViewModel.EnableAdminLevel0 = false;
                    ReportLocationViewModel.AdminLevel1Value ??= defaultAdministrativeLevel1Value;
                    ReportLocationViewModel.ShowAdminLevel1 = true;
                    ReportLocationViewModel.EnableAdminLevel1 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel2 = false;
                    ReportLocationViewModel.EnableAdminLevel2 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel3 = false;
                    ReportLocationViewModel.EnableAdminLevel3 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel4 = false;
                    ReportLocationViewModel.EnableAdminLevel4 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel5 = false;
                    ReportLocationViewModel.EnableAdminLevel5 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel6 = false;
                    ReportLocationViewModel.EnableAdminLevel6 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowSettlement = false;
                    ReportLocationViewModel.ShowSettlementType = false;
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel1Value;
                    break;

                case (long)AdministrativeUnitTypes.Rayon:
                    ReportLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel1 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel2 = true;
                    ReportLocationViewModel.ShowAdminLevel0 = true;
                    ReportLocationViewModel.EnableAdminLevel0 = false;
                    ReportLocationViewModel.AdminLevel1Value ??= defaultAdministrativeLevel1Value;
                    ReportLocationViewModel.AdminLevel2Value ??= defaultAdministrativeLevel2Value;
                    ReportLocationViewModel.ShowAdminLevel1 = true;
                    ReportLocationViewModel.EnableAdminLevel1 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel2 = true;
                    ReportLocationViewModel.EnableAdminLevel2 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel3 = false;
                    ReportLocationViewModel.EnableAdminLevel3 = false;
                    ReportLocationViewModel.ShowAdminLevel4 = false;
                    ReportLocationViewModel.ShowAdminLevel5 = false;
                    ReportLocationViewModel.ShowAdminLevel6 = false;
                    ReportLocationViewModel.ShowSettlement = false;
                    ReportLocationViewModel.ShowSettlementType = false;
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel2Value;
                    break;

                case (long)AdministrativeUnitTypes.Settlement:
                    ReportLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel1 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel2 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel3 = true;
                    ReportLocationViewModel.ShowAdminLevel0 = true;
                    ReportLocationViewModel.EnableAdminLevel0 = false;
                    ReportLocationViewModel.AdminLevel1Value = ReportLocationViewModel.AdminLevel1Value;
                    ReportLocationViewModel.AdminLevel2Value = ReportLocationViewModel.AdminLevel2Value;
                    ReportLocationViewModel.AdminLevel3Value = ReportLocationViewModel.AdminLevel3Value;
                    ReportLocationViewModel.ShowAdminLevel1 = true;
                    ReportLocationViewModel.EnableAdminLevel1 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel2 = true;
                    ReportLocationViewModel.EnableAdminLevel2 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel3 = true;
                    ReportLocationViewModel.EnableAdminLevel3 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel4 = false;
                    ReportLocationViewModel.ShowAdminLevel5 = false;
                    ReportLocationViewModel.ShowAdminLevel6 = false;
                    ReportLocationViewModel.ShowSettlement = true;
                    ReportLocationViewModel.EnableSettlement = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowSettlementType = true;
                    ReportLocationViewModel.EnableSettlementType = !InformationReportDisabledIndicator;
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel3Value ?? ReportLocationViewModel.AdminLevel2Value;
                    break;

                case (long)AdministrativeUnitTypes.Organization:
                    ReportLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel1 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel2 = true;
                    ReportLocationViewModel.IsDbRequiredAdminLevel3 = true;
                    ReportLocationViewModel.ShowAdminLevel0 = true;
                    ReportLocationViewModel.EnableAdminLevel0 = false;
                    ReportLocationViewModel.AdminLevel1Value = ReportLocationViewModel.AdminLevel1Value;
                    ReportLocationViewModel.AdminLevel2Value = ReportLocationViewModel.AdminLevel2Value;
                    ReportLocationViewModel.AdminLevel3Value = ReportLocationViewModel.AdminLevel3Value;
                    ReportLocationViewModel.ShowAdminLevel1 = true;
                    ReportLocationViewModel.EnableAdminLevel1 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel2 = true;
                    ReportLocationViewModel.EnableAdminLevel2 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel3 = true;
                    ReportLocationViewModel.EnableAdminLevel3 = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowAdminLevel4 = false;
                    ReportLocationViewModel.ShowAdminLevel5 = false;
                    ReportLocationViewModel.ShowAdminLevel6 = false;
                    ReportLocationViewModel.ShowSettlement = true;
                    ReportLocationViewModel.EnableSettlement = !InformationReportDisabledIndicator;
                    ReportLocationViewModel.ShowSettlementType = true;
                    ReportLocationViewModel.EnableSettlementType = !InformationReportDisabledIndicator;
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel3Value ?? ReportLocationViewModel.AdminLevel2Value;
                    ShowOrganization = true;
                    break;
            }

            if (InformationReportDisabledIndicator)
                ReportLocationViewModel.OperationType = LocationViewOperationType.ReadOnly;
        }

        public async Task SetStartAndEndDates()
        {
            // get the period selections based on statistical period type
            var yearPeriod = new Period();
            var period = new Period();
            switch (AggregateSettings.idfsStatisticPeriodType.ToString())
            {
                case StatisticPeriodType.Year:
                    yearPeriod = Years.FirstOrDefault(x => x.PeriodNumber == Year);
                    await LoadMonths(new LoadDataArgs());
                    period = Years.FirstOrDefault(x => x.PeriodNumber == Year);
                    break;

                case StatisticPeriodType.Quarter:
                    period = Quarters.FirstOrDefault(x => x.PeriodNumber == Quarter);
                    break;

                case StatisticPeriodType.Month:
                    yearPeriod = Years.FirstOrDefault(x => x.PeriodNumber == Year);
                    period = Months.FirstOrDefault(x => x.PeriodNumber == Month);
                    break;

                case StatisticPeriodType.Week:
                    period = Weeks.FirstOrDefault(x => x.PeriodNumber == Week);
                    break;
            }

            // determine the start and end dates based on timePeriod type
            var startingDate = DateTime.Now.Date;
            var endingDate = DateTime.Now.Date;
            switch (AggregateSettings.idfsStatisticPeriodType.ToString())
            {
                case StatisticPeriodType.Year:
                    if (period != null) startingDate = new DateTime(period.PeriodNumber, 1, 1);
                    endingDate = startingDate.AddYears(1).AddDays(-1);
                    break;

                case StatisticPeriodType.Quarter:
                    if (period != null)
                    {
                        startingDate = period.StartDay;
                        endingDate = period.FinishDay;
                    }

                    break;

                case StatisticPeriodType.Month:
                    if (yearPeriod != null)
                        if (period != null)
                            startingDate = new DateTime(yearPeriod.PeriodNumber, period.PeriodNumber, 1);
                    endingDate = startingDate.AddMonths(1).AddDays(-1);
                    break;

                case StatisticPeriodType.Week:
                    if (period != null)
                    {
                        startingDate = period.StartDay;
                        endingDate = period.FinishDay;
                    }

                    break;

                case StatisticPeriodType.Day:
                    startingDate = Day.GetValueOrDefault();
                    endingDate = Day.GetValueOrDefault();
                    break;
            }
            StartDate = startingDate;
            EndDate = endingDate;
        }

        public void SetTimePeriodValues()
        {
            // set the values of whatever time controls are showing
            var timePeriod = PeriodType != null ? PeriodType.ToString() : AggregateSettings.StrPeriodType;
            var startingDate = StartDate ?? DateTime.Now.Date;
            switch (timePeriod)
            {
                case StatisticPeriodType.Year:
                    Year = startingDate.Year;
                    break;

                case StatisticPeriodType.Quarter:
                    Quarter = Quarters != null ? Quarters.First(x => x.PeriodNumber == ((startingDate.Month - 1) / 3) + 1).PeriodNumber : 1;
                    Year = startingDate.Year;
                    break;

                case StatisticPeriodType.Month:
                    Month = startingDate.Month;
                    Year = startingDate.Year;
                    break;

                case StatisticPeriodType.Week:
                    var weekOfYear = GetWeek(startingDate);
                    Week = weekOfYear?.PeriodNumber ?? 1;
                    Year = startingDate.Year;
                    break;

                case StatisticPeriodType.Day:
                    Day = startingDate;
                    Month = startingDate.Month;
                    Year = startingDate.Year;
                    break;
            }
        }

        private Period GetWeek(DateTime dateTime)
        {
            if (Weeks == null || !Weeks.Any()) return null;
            return Weeks.FirstOrDefault(w => dateTime <= w.FinishDay && dateTime >= w.StartDay);
        }

        private string GetDefaultUserName()
        {
            var value = authenticatedUser;
            return value.LastName + (IsNullOrEmpty(value.FirstName) ? Empty : ", " + value.FirstName);
        }

        #endregion Initialize Model

        #region Set Administrative Unit on Location Change

        public void SetAdministrativeUnit()
        {
            switch (AggregateSettings.idfsStatisticAreaType)
            {
                case (long)AdministrativeUnitTypes.Country:
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel0Value;
                    break;

                case (long)AdministrativeUnitTypes.Region:
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel1Value;
                    break;

                case (long)AdministrativeUnitTypes.Rayon:
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel2Value;
                    break;

                case (long)AdministrativeUnitTypes.Settlement:
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel3Value ?? ReportLocationViewModel.AdminLevel2Value;
                    break;

                case (long)AdministrativeUnitTypes.Organization:
                    AdministrativeUnitID = ReportLocationViewModel.AdminLevel3Value ?? ReportLocationViewModel.AdminLevel2Value;
                    OrganizationalLocationID = OrganizationID;
                    break;
            }
        }

        #endregion Set Administrative Unit on Location Change

        #region Get Aggregate Actions Details

        public async Task GetAggregateActionsReportDetails()
        {
            if (ReportKey > 0)
            {
                var detailRequest = new AggregateReportGetListDetailRequestModel
                {
                    LanguageID = GetCurrentLanguage(),
                    idfsAggrCaseType = Convert.ToInt64(AggregateValue.VeterinaryAction),
                    idfAggrCase = ReportKey,
                    ApplyFiltrationIndicator = authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    UserOrganizationID = Convert.ToInt64(authenticatedUser.OfficeId),
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };
                var results = await _aggregateReportClient.GetAggregateReportDetail(detailRequest);
                var aggregateDetails = results.FirstOrDefault();
                if (aggregateDetails != null)
                {
                    //Get lowest administrative level for location
                    long? locationId;
                    if (aggregateDetails.idfsSettlement.HasValue)
                        locationId = aggregateDetails.idfsSettlement.Value;
                    else if (aggregateDetails.idfsRayon.HasValue)
                        locationId = aggregateDetails.idfsRayon.Value;
                    else if (aggregateDetails.idfsRegion.HasValue)
                        locationId = aggregateDetails.idfsRegion.Value;
                    else
                        locationId = null;

                    ReportKey = aggregateDetails.idfAggrCase.GetValueOrDefault();
                    ReportID = aggregateDetails.strCaseID;
                    AreaTypeID = aggregateDetails.idfsAreaType;
                    PeriodType = aggregateDetails.idfsPeriodType;
                    PeriodName = aggregateDetails.strPeriodName;
                    StartDate = aggregateDetails.datStartDate;
                    EndDate = aggregateDetails.datFinishDate;
                    OrganizationID = aggregateDetails.Organization;
                    AdministrativeUnitID = aggregateDetails.idfsAdministrativeUnit;
                    ReportLocationViewModel.AdminLevel0Value = aggregateDetails.idfsCountry;
                    ReportLocationViewModel.AdminLevel1Value = aggregateDetails.idfsRegion;
                    ReportLocationViewModel.AdminLevel2Value = aggregateDetails.idfsRayon;
                    ReportLocationViewModel.AdminLevel3Value = aggregateDetails.idfsSettlement;
                    ReportLocationViewModel.AdministrativeLevelId = locationId;
                    NotificationSentInstitutionID = aggregateDetails.idfSentByOffice;
                    NotificationSentOfficerID = aggregateDetails.idfSentByPerson;
                    NotificationSentDate = aggregateDetails.datSentByDate;
                    NotificationReceivedInstitutionID = aggregateDetails.idfReceivedByOffice;
                    NotificationReceivedOfficerID = aggregateDetails.idfReceivedByPerson;
                    NotificationReceivedDate = aggregateDetails.datReceivedByDate;
                    NotificationEnteredInstitutionID = aggregateDetails.idfEnteredByOffice;
                    NotificationEnteredInstitution = aggregateDetails.strEnteredByOffice;
                    NotificationEnteredOfficerID = aggregateDetails.idfEnteredByPerson;
                    NotificationEnteredOfficer = aggregateDetails.strEnteredByPerson;
                    NotificationEnteredDate = aggregateDetails.datEnteredByDate;
                    SiteID = aggregateDetails.idfsSite;
                    UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId);
                    DiagnosticFlexFormRequest.idfsFormTemplate = aggregateDetails.idfsDiagnosticFormTemplate;
                    DiagnosticObservationID = aggregateDetails.idfDiagnosticObservation;
                    DiagnosticFlexFormRequest.idfObservation = aggregateDetails.idfDiagnosticObservation;
                    DiagnosticFlexFormRequest.idfsFormType = Convert.ToInt64(AggregateValue.VeterinaryAction);
                    DiagnosticMatrixVersionID = aggregateDetails.idfDiagnosticVersionID;
                    SanitaryFlexFormRequest.idfsFormTemplate = aggregateDetails.idfsSanitaryFormTemplate;
                    SanitaryObservationID = aggregateDetails.idfSanitaryObservation;
                    SanitaryFlexFormRequest.idfObservation = aggregateDetails.idfSanitaryObservation;
                    SanitaryFlexFormRequest.idfsFormType = Convert.ToInt64(AggregateValue.VeterinaryAction);
                    SanitaryMatrixVersionID = aggregateDetails.idfSanitaryVersionID;
                    TreatmentFlexFormRequest.idfsFormTemplate = aggregateDetails.idfsProphylacticFormTemplate;
                    TreatmentObservationID = aggregateDetails.idfProphylacticObservation;
                    TreatmentFlexFormRequest.idfObservation = aggregateDetails.idfProphylacticObservation;
                    TreatmentFlexFormRequest.idfsFormType = Convert.ToInt64(AggregateValue.VeterinaryAction);
                    TreatmentMatrixVersionID = aggregateDetails.idfProphylacticVersionID;

                    // disabled indicator
                    if ((ReportKey <= 0 && !VeterinaryAggregateActionsReportPermissions.Create)
                        || (ReportKey > 0 && !VeterinaryAggregateActionsReportPermissions.Write)
                        || IsReadOnly)
                    {
                        InformationReportDisabledIndicator = true;
                    }

                    // set the time period to show according to the detail record
                    SetTimePeriodsToShow(PeriodType.ToString());

                    // set the location level to show according to the detail record
                    SetAdministrativeLevels(AreaTypeID.GetValueOrDefault());

                    // set the year before loading time period drop downs
                    Year = StartDate.GetValueOrDefault().Year;

                    // load the time period lists
                    LoadYears(new LoadDataArgs());
                    await LoadMonths(new LoadDataArgs());
                    LoadQuarters(new LoadDataArgs());
                    LoadWeeks(new LoadDataArgs());

                    // set the values for the time periods based on detail record
                    SetTimePeriodValues();

                    if (SiteID != Convert.ToInt64(authenticatedUser.SiteId))
                    {
                        if (aggregateDetails.DeletePermissionIndicator != null)
                        {
                            DeletePermissionIndicator = (bool) aggregateDetails.DeletePermissionIndicator;
                            VeterinaryAggregateActionsReportPermissions.Delete =
                                (bool) aggregateDetails.DeletePermissionIndicator;
                        }

                        if (aggregateDetails.ReadPermissionIndicator != null)
                        {
                            ReadPermissionIndicator = (bool) aggregateDetails.ReadPermissionIndicator;
                            VeterinaryAggregateActionsReportPermissions.Read =
                                (bool) aggregateDetails.ReadPermissionIndicator;
                        }

                        if (aggregateDetails.WritePermissionIndicator != null)
                        {
                            WritePermissionIndicator = (bool) aggregateDetails.WritePermissionIndicator;
                            VeterinaryAggregateActionsReportPermissions.Write =
                                (bool) aggregateDetails.WritePermissionIndicator;
                        }
                    }

                    // raise the state loaded event
                    NotifyStateLoaded();
                }
                else
                {
                    ReadPermissionIndicator = false;
                    VeterinaryAggregateActionsReportPermissions.Read = false;
                }
            }
        }

        #endregion Get Aggregate Actions Details

        #region Private Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);

        private void NotifyStateLoaded() => OnStateLoaded?.Invoke();

        #endregion Private Methods
    }
}