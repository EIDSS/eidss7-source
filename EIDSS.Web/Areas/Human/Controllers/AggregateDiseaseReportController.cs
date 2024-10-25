#region Using Statements

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class AggregateDiseaseReportController : BaseController
    {
        #region Global Values

        private readonly IAggregateReportClient _aggregateReportClient;
        private readonly IAggregateSettingsClient _aggregateSettingsClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfigurationClient _configurationClient;
        private readonly ISiteClient _siteClient;
        private readonly IOrganizationClient _organizationClient;
        private readonly IFlexFormClient _flexFormClient;
        private readonly IHumanAggregateDiseaseMatrixClient _humanAggregateDiseaseMatrixClient;
        private readonly ISiteAlertsSubscriptionClient _siteAlertsSubscriptionClient;

        private readonly IConfiguration _configuration;

        private readonly IStringLocalizer _localizer;

        private readonly UserPermissions _permissions;
        private readonly UserPermissions _permissionsCanAccessEmployeesList;
        public long DuplicateKey { get; set; }
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly UserPreferences _userPreferences;

        //AggregateDiseaseReportViewModel aggregateDiseaseReportViewModel;
        private AggregateReportSearchViewModel _aggregateReportSearchViewModel;

        private IEnumerable<EventSubscriptionTypeModel> EventTypes { get; set; }
        public IList<EventSaveRequestModel> Events { get; set; }

        #endregion

        #region Constructors

        public AggregateDiseaseReportController(IAggregateReportClient aggregateReportClient,
                IAggregateSettingsClient aggregateSettingsClient,
                ICrossCuttingClient crossCuttingClient,
                IConfigurationClient configurationClient,
                ISiteClient siteClient,
                ITokenService tokenService,
                IConfiguration configuration,
                IOrganizationClient organizationClient,
                IFlexFormClient flexFormClient,
                IHumanAggregateDiseaseMatrixClient humanAggregateDiseaseMatrixClient,
                ISiteAlertsSubscriptionClient siteAlertsSubscriptionClient,
                IStringLocalizer localizer,
                ILogger<AggregateDiseaseReportController> logger) : base(logger, tokenService)
        {
            _aggregateReportClient = aggregateReportClient;
            _aggregateSettingsClient = aggregateSettingsClient;
            _crossCuttingClient = crossCuttingClient;
            _configurationClient = configurationClient;
            _siteClient = siteClient;
            _organizationClient = organizationClient;
            _flexFormClient = flexFormClient;
            _humanAggregateDiseaseMatrixClient = humanAggregateDiseaseMatrixClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = _authenticatedUser.Preferences;
            _configuration = configuration;
            _localizer = localizer;
            _permissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports);
            _permissionsCanAccessEmployeesList = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
            _siteAlertsSubscriptionClient = siteAlertsSubscriptionClient;
        }

        #endregion

        #region Search Human Aggregate Disease Report

        public IActionResult Index()
        {
            _aggregateReportSearchViewModel = new AggregateReportSearchViewModel
            {
                Permissions = _permissions
            };

            return View(_aggregateReportSearchViewModel);
        }

        #endregion

        #region Human Aggregate Disease Report Details

        private async Task FillConfigurationSettingsAsync(ReportDetailsSectionViewModel model)
        {
            LocationViewModel searchLocationViewModel = new();

            var siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_authenticatedUser.SiteId), Convert.ToInt64(_authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                AggregateSettingsGetRequestModel aggregateSettingsGetRequestModel = new()
                {
                    IdfCustomizationPackage = siteDetails.CustomizationPackageID,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = SortConstants.Ascending,
                    idfsSite = siteDetails.SiteID
                };

                var aggregateSettings = await _configurationClient.GetAggregateSettings(aggregateSettingsGetRequestModel);

                var aggregateSetting = aggregateSettings.FirstOrDefault(a => a.idfsAggrCaseType == Convert.ToInt64(AggregateValue.Human));
                if (model.AdministrativeLevelID == null)
                {
                    if (aggregateSetting != null)
                    {
                        model.AdministrativeLevelID = aggregateSetting.idfsStatisticAreaType;
                        model.TimeIntervalID = aggregateSetting.idfsStatisticPeriodType;
                    }

                    model.AggregateDiseaseReportDetails.idfsAreaType = model.AdministrativeLevelID;
                    model.AggregateDiseaseReportDetails.idfsPeriodType = model.TimeIntervalID;
                }

                FillMinimumTimeUnit(model);

                if (model.AggregateDiseaseReportDetails.idfAggrCase == null)
                {
                    model.DetailsLocationViewModel.AdminLevel0Value = siteDetails.CountryID;
                    searchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;
                    model.AggregateDiseaseReportDetails.strCountry = siteDetails.CountryID.ToString();
                    model.DetailsLocationViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
                    model.DetailsLocationViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;

                    model.DetailsLocationViewModel.AdminLevel1Value = _userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;
                    model.DetailsLocationViewModel.AdminLevel2Value = _userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;
                }

                //Set Other Admin Level Values - if needed
                const string orgControl = "ReportDetailsSection_Organization";

                // Location Control
                searchLocationViewModel.IsHorizontalLayout = true;
                searchLocationViewModel.EnableAdminLevel1 = true;
                searchLocationViewModel.ShowAdminLevel0 = false;
                searchLocationViewModel.ShowAdminLevel1 = ActiveAdminLevel(1, aggregateSetting);
                searchLocationViewModel.ShowAdminLevel2 = ActiveAdminLevel(2, aggregateSetting);
                searchLocationViewModel.ShowAdminLevel3 = ActiveAdminLevel(3, aggregateSetting);
                searchLocationViewModel.ShowAdminLevel4 = ActiveAdminLevel(4, aggregateSetting);
                searchLocationViewModel.ShowAdminLevel5 = ActiveAdminLevel(5, aggregateSetting);
                searchLocationViewModel.ShowAdminLevel6 = ActiveAdminLevel(6, aggregateSetting);
                searchLocationViewModel.ShowStreet = false;
                searchLocationViewModel.ShowBuilding = false;
                searchLocationViewModel.ShowApartment = false;
                searchLocationViewModel.ShowElevation = false;
                searchLocationViewModel.ShowHouse = false;
                searchLocationViewModel.ShowLatitude = false;
                searchLocationViewModel.ShowLongitude = false;
                searchLocationViewModel.ShowMap = false;
                searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                searchLocationViewModel.ShowPostalCode = false;
                searchLocationViewModel.ShowCoordinates = false;
                searchLocationViewModel.IsDbRequiredAdminLevel1 = false;
                searchLocationViewModel.IsDbRequiredSettlement = false;
                searchLocationViewModel.IsDbRequiredSettlementType = false;
                searchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                searchLocationViewModel.ShowBuildingHouseApartmentGroup = true;

                switch (model.AdministrativeLevelID)
                {
                    case (long)AdministrativeUnitTypes.Country:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.ShowAdminLevel1 = false;
                        searchLocationViewModel.EnableAdminLevel1 = false;
                        searchLocationViewModel.ShowAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.ShowAdminLevel3 = false;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        searchLocationViewModel.ShowSettlementType = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel0Value;
                        break;

                    case (long)AdministrativeUnitTypes.Region:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.ShowAdminLevel3 = false;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        searchLocationViewModel.ShowSettlementType = false;
                        searchLocationViewModel.DivSettlementGroup = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel1Value;
                        break;

                    case (long)AdministrativeUnitTypes.Rayon:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.DetailsLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = false;
                        searchLocationViewModel.ShowSettlementType = false;
                        searchLocationViewModel.DivSettlementGroup = false;

                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.ShowSettlement = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel2Value;
                        break;

                    case (long)AdministrativeUnitTypes.Settlement:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.DetailsLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.AdminLevel3Value = model.DetailsLocationViewModel.AdminLevel3Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel3 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;
                        searchLocationViewModel.ShowSettlementType = true;

                        model.DetailsLocationViewModel.IsDbRequiredSettlementType = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel3Value ??
                            model.DetailsLocationViewModel.AdminLevel2Value;
                        break;

                    default:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.DetailsLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.AdminLevel3Value = model.DetailsLocationViewModel.AdminLevel3Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel3 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;
                        model.DetailsLocationViewModel.IsDbRequiredSettlementType = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel3Value ??
                            model.DetailsLocationViewModel.AdminLevel2Value;
                        model.OrganizationVisibleIndicator = true;
                        model.OrganizationRequiredIndicator = true;

                        searchLocationViewModel.CallingObjectID = "ReportDetailsSection";
                        var selectedAdminLevelElement = "SelectedAdminLevel";
                        if (!string.IsNullOrEmpty(searchLocationViewModel.CallingObjectID))
                        {
                            selectedAdminLevelElement =
                                $"{searchLocationViewModel.CallingObjectID}_SelectedAdminLevel";
                        }
                        searchLocationViewModel.AdminLevelRefreshJavascriptFunction = "refreshDetailsOrgByLocationAdminSelection(" + orgControl + "," + selectedAdminLevelElement + ");";
                        break;
                }

                model.DetailsLocationViewModel = searchLocationViewModel;
            }
        }

        private void FillMinimumTimeUnit(ReportDetailsSectionViewModel model, bool saveDataRangeIndicator = false)
        {
            try
            {
                model.QuarterVisibleIndicator = false;
                model.MonthVisibleIndicator = false;
                model.WeekVisibleIndicator = false;
                model.DayVisibleIndicator = false;

                Select2DataItem defaultData;
                DateTime startDate;
                if (model.AggregateDiseaseReportDetails.datStartDate != null)
                {
                    startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                    defaultData = new Select2DataItem { id = startDate.Year.ToString(), text = startDate.Year.ToString() };
                }
                else
                    defaultData = new Select2DataItem { id = DateTime.Today.Year.ToString(), text = DateTime.Today.Year.ToString() };
                model.Years.defaultSelect2Selection = defaultData;

                var id = GlobalConstants.NullValue.ToLower();
                var text = string.Empty;

                switch (model.TimeIntervalID)
                {
                    case (long)TimePeriodTypes.Year:
                        if (saveDataRangeIndicator)
                        {
                            //SaveDateRange();
                        }
                        //if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        //{
                        //    StartDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                        //    defaultData = new Select2DataItem() { id = StartDate.Year.ToString(), text = StartDate.Year.ToString() };
                        //}
                        //else
                        //    defaultData = new Select2DataItem() { id = System.DateTime.Today.Year.ToString(), text = System.DateTime.Today.Year.ToString() };
                        //model.Years.defaultSelect2Selection = defaultData;
                        break;

                    case (long)TimePeriodTypes.Quarter:
                        model.QuarterVisibleIndicator = true;
                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            id = ((startDate.Month - 1) / 3 + 1).ToString();
                            text = GetQuarterText(int.Parse(id), startDate.Year);
                            model.Quarter = (startDate.Month - 1) / 3 + 1;
                        }
                        defaultData = new Select2DataItem { id = id, text = text };
                        model.Quarters.defaultSelect2Selection = defaultData;
                        break;

                    case (long)TimePeriodTypes.Month:
                        model.MonthVisibleIndicator = true;
                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            //id = (((StartDate.Month - 1) / 3) + 1).ToString();
                            ////text = model.Quarters.;

                            //defaultData = new Select2DataItem() { id = StartDate.Year.ToString(), text = StartDate.Year.ToString() };
                            //model.Years.defaultSelect2Selection = defaultData;

                            var select2data = Common.GetMonthSelect2DataItem(startDate, GetCurrentLanguage());
                            id = startDate.Month.ToString();
                            text = select2data.text;
                            model.Month = startDate.Month;
                            //model.Months.defaultSelect2Selection = new Select2DataItem() { id = StartDate.Month.ToString(), text = select2data.text };
                        }
                        defaultData = new Select2DataItem { id = id, text = text };
                        model.Months.defaultSelect2Selection = defaultData;
                        break;

                    case (long)TimePeriodTypes.Week:
                        model.WeekVisibleIndicator = true;
                        Common.GetWeekNumberOfDate(DateTime.Now, GetCurrentLanguage()).ToString();
                        Common.GetWeekNumberOfDate(DateTime.Now.AddDays(-7), GetCurrentLanguage()).ToString();
                        Common.GetWeekNumberOfDate(DateTime.Now.AddDays(7), GetCurrentLanguage()).ToString();
                        Common.GetWeekNumberOfDate(new DateTime(DateTime.Now.Year, 12, 31), GetCurrentLanguage()).ToString();

                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            var select2data = Common.GetWeekSelect2DataItem(startDate, GetCurrentLanguage());
                            id = Common.GetWeekNumberOfDate(startDate, GetCurrentLanguage()).ToString();
                            text = select2data.text;
                            model.Week = Convert.ToInt32(id);
                        }
                        defaultData = new Select2DataItem { id = id, text = text };
                        model.Weeks.defaultSelect2Selection = defaultData;
                        break;

                    case (long)TimePeriodTypes.Day:
                        model.MonthVisibleIndicator = true;
                        model.DayVisibleIndicator = true;
                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            var select2data = Common.GetMonthSelect2DataItem(startDate, GetCurrentLanguage());
                            id = startDate.Month.ToString();
                            text = select2data.text;
                            model.Month = startDate.Month;
                            model.Day = startDate;
                        }
                        defaultData = new Select2DataItem { id = id, text = text };
                        model.Months.defaultSelect2Selection = defaultData;
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public async Task<IActionResult> Details(long? id)
        {
            string strId;
            string text;

            FlexFormTemplateGetRequestModel request = new()
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormTemplate = null,
                idfsFormType = (long)FlexibleFormTypes.HumanAggregate
            };
            var templateList = await _flexFormClient.GetTemplateList(request);

            AggregateReportDetailsViewModel model = new()
            {
                Permissions = _permissions,
                ReportDetailsSection = new ReportDetailsSectionViewModel
                {
                    AggregateDiseaseReportDetails = new AggregateReportGetDetailViewModel(),
                    SentByOrganizations = new Select2Configruation(),
                    SentByOfficers = new Select2Configruation(),
                    ReceivedByOrganizations = new Select2Configruation(),
                    ReceivedByOfficers = new Select2Configruation(),
                    Years = new Select2Configruation(),
                    Quarters = new Select2Configruation(),
                    Months = new Select2Configruation(),
                    Weeks = new Select2Configruation(),
                    Organizations = new Select2Configruation(),
                    DetailsLocationViewModel = new LocationViewModel
                    {
                        //CallingObjectID = "ReportDetailsSection_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = true,
                        ShowAdminLevel1 = true,
                        ShowAdminLevel2 = true,
                        ShowAdminLevel3 = false,
                        ShowAdminLevel4 = false,
                        ShowAdminLevel5 = false,
                        ShowAdminLevel6 = false,
                        ShowSettlement = true,
                        ShowSettlementType = true,
                        ShowStreet = false,
                        ShowBuilding = false,
                        ShowApartment = false,
                        ShowElevation = false,
                        ShowHouse = true,
                        ShowLatitude = false,
                        ShowLongitude = false,
                        ShowMap = false,
                        ShowBuildingHouseApartmentGroup = false,
                        ShowPostalCode = false,
                        ShowCoordinates = false,
                        IsDbRequiredAdminLevel1 = true,
                        IsDbRequiredAdminLevel2 = true,
                        IsDbRequiredApartment = false,
                        IsDbRequiredBuilding = false,
                        IsDbRequiredHouse = false,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        IsDbRequiredStreet = false,
                        IsDbRequiredPostalCode = false,
                        AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    }
                },
                DiseaseMatrixSection = new DiseaseMatrixSectionViewModel
                {
                    MatrixVersions = new Select2Configruation(),
                    Templates = new Select2Configruation(),
                    AggregateCase = new FlexFormQuestionnaireGetRequestModel(),
                },
            };

            model.ReportDetailsSection.PermissionsCanAccessEmployeesList = _permissionsCanAccessEmployeesList;
            model.ReportDetailsSection.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            model.ReportDetailsSection.EmployeeDetails = new Web.ViewModels.Administration.EmployeePersonalInfoPageViewModel
            {
                PersonalIdTypeDD = new Select2Configruation(),
                DepartmentDD = new Select2Configruation(),
                eIDSSModalConfiguration = new List<EIDSSModalConfiguration>(),
                EmployeeCategoryList = new List<BaseReferenceViewModel>(),
                OrganizationDD = new Select2Configruation(),
                PositionDD = new Select2Configruation(),
                SiteDD = new Select2Configruation(),
                CanManageReferencesandConfiguratuionsPermission = _permissionsCanAccessEmployeesList
            };
            var userAccountPermissions = GetUserPermissions(PagePermission.CanManageUserAccounts);
            model.ReportDetailsSection.EmployeeDetails.UserPermissions = userAccountPermissions;
            var canAccessOrganizationsList = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
            model.ReportDetailsSection.EmployeeDetails.CanAccessOrganizationsList = canAccessOrganizationsList;

            if (id != null)
            {
                if (model.Permissions.Write)
                    model.EnableFinishButton = true;

                var settingsRequest = new AggregateSettingsGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfCustomizationPackage = Convert.ToInt64(GlobalConstants.CustomizationPackageID),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = SortConstants.Ascending,
                    idfsSite = long.Parse(_authenticatedUser.SiteId)
                };

                var aggregateSettings = await _aggregateSettingsClient.GetAggregateSettingsList(settingsRequest);
                if (aggregateSettings != null && aggregateSettings.Any())
                {
                }

                //model.ReportDetailsSection.DetailsLocationViewModel.TimeIntervalTypeID = defaultSettings?.idfsStatisticPeriodType;
                //model.ReportDetailsSection.DetailsLocationViewModel.AdministrativeUnitTypeID = defaultSettings?.idfsStatisticAreaType;

                var detailRequest = new AggregateReportGetListDetailRequestModel
                {
                    LanguageID = GetCurrentLanguage(),
                    idfsAggrCaseType = (long)AggregateDiseaseReportTypes.HumanAggregateDiseaseReport,
                    idfAggrCase = (long)id,
                    ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
                };
                var response = await _aggregateReportClient.GetAggregateReportDetail(detailRequest);
                if (response.Count > 0)
                {
                    model.ReportDetailsSection.AggregateDiseaseReportDetails = response[0];
                    model.ReportDetailsSection.AdministrativeLevelID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAreaType.GetValueOrDefault();
                    model.ReportDetailsSection.TimeIntervalID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsPeriodType.GetValueOrDefault();

                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsRegion;
                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsRayon;
                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSettlement;

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization != null)
                    {
                        strId = model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization.ToString();
                        text = model.ReportDetailsSection.AggregateDiseaseReportDetails.strOrganization;
                        model.ReportDetailsSection.Organizations.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                    }

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate != null && templateList.Count > 0)
                    {
                        strId = templateList.Find(v => v.idfsFormTemplate == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate).idfsFormTemplate.ToString();
                        text = templateList.Find(v => v.idfsFormTemplate == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate).DefaultName;
                        model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                    }
                    else
                    {
                        if (templateList.Count > 0)
                        {
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate = templateList.Find(v => v.blnUNI) == null ? null : templateList.Find(v => v.blnUNI).idfsFormTemplate;
                            strId = templateList.Find(v => v.blnUNI) == null ? string.Empty : templateList.Find(v => v.blnUNI).idfsFormTemplate.ToString();
                            text = templateList.Find(v => v.blnUNI) == null ? string.Empty : templateList.Find(v => v.blnUNI).DefaultName;
                            model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                        }
                        else
                        {
                            model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = GlobalConstants.NullValue.ToLower(), text = string.Empty };
                        }
                    }

                    var matrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType(MatrixTypes.HumanAggregateCase);
                    strId = matrixVersionList.Find(v => v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion) == null ? string.Empty : matrixVersionList.Find(v => v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion).IdfVersion.ToString();
                    text = matrixVersionList.Find(v => v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion) == null ? string.Empty : matrixVersionList.Find(v => v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion).MatrixName;

                    if (!string.IsNullOrEmpty(strId))
                    {
                        model.DiseaseMatrixSection.MatrixVersions.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                        model.DiseaseMatrixSection.idfVersion = long.Parse(strId);
                    }

                    model.DiseaseMatrixSection.AggregateCase.idfsFormTemplate = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate;
                    model.DiseaseMatrixSection.AggregateCase.idfObservation = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation;
                }
            }
            else
            {
                if (model.Permissions.Create)
                    model.EnableFinishButton = true;

                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByOffice = authenticatedUser.OfficeId;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByPerson = Convert.ToInt64(authenticatedUser.PersonId);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.strEnteredByOffice = authenticatedUser.Organization;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.strEnteredByPerson = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.datEnteredByDate = DateTime.Today;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite = Convert.ToInt64(authenticatedUser.SiteId);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAggrCaseType = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice = null;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByPerson = null;

                model.ReportDetailsSection.LegacyIDVisibleIndicator = false;

                var defaultData = new Select2DataItem { id = DateTime.Today.Year.ToString(), text = DateTime.Today.Year.ToString() };
                model.ReportDetailsSection.Years.defaultSelect2Selection = defaultData;
                defaultData = new Select2DataItem { id = null, text = string.Empty };
                //defaultData = new Select2DataItem() { id = GlobalConstants.NullValue.ToLower(), text = string.Empty };
                model.ReportDetailsSection.Quarters.defaultSelect2Selection = defaultData;
                model.ReportDetailsSection.Months.defaultSelect2Selection = defaultData;
                model.ReportDetailsSection.Weeks.defaultSelect2Selection = defaultData;

                //The currently activated Flexible Form template for Human Aggregate Disease Reports shall be displayed
                strId = templateList.Find(v => v.blnUNI) == null ? string.Empty : templateList.Find(v => v.blnUNI).idfsFormTemplate.ToString();
                text = templateList.Find(v => v.blnUNI) == null ? string.Empty : templateList.Find(v => v.blnUNI).DefaultName;
                model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                model.DiseaseMatrixSection.AggregateCase.idfsFormTemplate = templateList.Find(v => v.blnUNI) == null ? null : templateList.Find(v => v.blnUNI).idfsFormTemplate;

                //The default matrix for the Human Aggregate Disease Report shall be the currently activated matrix
                var matrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType(MatrixTypes.HumanAggregateCase);
                strId = matrixVersionList.Find(v => v.BlnIsActive == true) == null ? string.Empty : matrixVersionList.Find(v => v.BlnIsActive == true).IdfVersion.ToString();
                text = matrixVersionList.Find(v => v.BlnIsActive == true) == null ? string.Empty : matrixVersionList.Find(v => v.BlnIsActive == true).MatrixName;
                model.DiseaseMatrixSection.MatrixVersions.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                model.DiseaseMatrixSection.idfVersion = long.Parse(strId);
            }

            if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation == null)
            {
                // await SaveObservationAsync(model.ReportDetailsSection);
            }

            await FillConfigurationSettingsAsync(model.ReportDetailsSection);

            model.ReportDetailsSection.DetailsLocationViewModel.CallingObjectID = "ReportDetailsSection_";

            ////The default matrix for the Human Aggregate Disease Report shall be the currently activated matrix
            //var MatrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.AggregateCase);
            //strID = MatrixVersionList.Find(v => v.BlnIsActive == true).IdfVersion.ToString();
            //text = MatrixVersionList.Find(v => v.BlnIsActive == true).MatrixName;
            //model.DiseaseMatrixSection.MatrixVersions.defaultSelect2Selection = new Select2DataItem() { id = strID, text = text };
            //model.DiseaseMatrixSection.idfVersion = long.Parse(strID);

            //Generate report parameters
            model.ReportPrintViewModel = new DiseaseReportPrintViewModel
            {
                Parameters = new List<KeyValuePair<string, string>>(),
                ReportName = "HumanAggregateDiseaseReport"
            };

            //(long)FlexibleFormTypes.HumanAggregate;
            if (id != null)
            {
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("idfAggrCaseList", id.Value.ToString()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("idfsAggrCaseType", ((long)FlexibleFormTypes.HumanAggregate).ToString()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("LangID", GetCurrentLanguage()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("SiteID", _authenticatedUser.SiteId));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("PersonID", _authenticatedUser.PersonId));
            }

            await LoadFlexFormsAsync(model.DiseaseMatrixSection);

            return View(model);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="id"></param>
        /// <param name="reviewPageNo"></param>
        /// <returns></returns>
        public async Task<IActionResult> DetailsReviewPage(long? id, int reviewPageNo)
        {
            string strId;
            string text;

            FlexFormTemplateGetRequestModel request = new()
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormTemplate = null,
                idfsFormType = (long)FlexibleFormTypes.HumanAggregate
            };
            var templateList = await _flexFormClient.GetTemplateList(request);

            AggregateReportDetailsViewModel model = new()
            {
                Permissions = _permissions,
                ReportDetailsSection = new ReportDetailsSectionViewModel
                {
                    AggregateDiseaseReportDetails = new AggregateReportGetDetailViewModel(),
                    SentByOrganizations = new Select2Configruation(),
                    SentByOfficers = new Select2Configruation(),
                    ReceivedByOrganizations = new Select2Configruation(),
                    ReceivedByOfficers = new Select2Configruation(),
                    Years = new Select2Configruation(),
                    Quarters = new Select2Configruation(),
                    Months = new Select2Configruation(),
                    Weeks = new Select2Configruation(),
                    Organizations = new Select2Configruation(),
                    DetailsLocationViewModel = new LocationViewModel
                    {
                        CallingObjectID = "ReportDetailsSection_",
                        IsHorizontalLayout = true,
                        EnableAdminLevel1 = true,
                        ShowAdminLevel0 = true,
                        ShowAdminLevel1 = true,
                        ShowAdminLevel2 = true,
                        ShowAdminLevel3 = false,
                        ShowAdminLevel4 = false,
                        ShowAdminLevel5 = false,
                        ShowAdminLevel6 = false,
                        ShowSettlement = true,
                        ShowSettlementType = false,
                        ShowStreet = false,
                        ShowBuilding = false,
                        ShowApartment = false,
                        ShowElevation = false,
                        ShowHouse = true,
                        ShowLatitude = false,
                        ShowLongitude = false,
                        ShowMap = false,
                        ShowBuildingHouseApartmentGroup = false,
                        ShowPostalCode = false,
                        ShowCoordinates = false,
                        IsDbRequiredAdminLevel1 = true,
                        IsDbRequiredAdminLevel2 = true,
                        IsDbRequiredApartment = false,
                        IsDbRequiredBuilding = false,
                        IsDbRequiredHouse = false,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        IsDbRequiredStreet = false,
                        IsDbRequiredPostalCode = false,
                        AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    }
                },
                DiseaseMatrixSection = new()
                {
                    MatrixVersions = new(),
                    Templates = new(),
                    AggregateCase = new(),
                },
            };

            model.ReportDetailsSection.PermissionsCanAccessEmployeesList = _permissionsCanAccessEmployeesList;
            model.ReportDetailsSection.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            model.ReportDetailsSection.EmployeeDetails = new Web.ViewModels.Administration.EmployeePersonalInfoPageViewModel
            {
                PersonalIdTypeDD = new Select2Configruation(),
                DepartmentDD = new Select2Configruation(),
                eIDSSModalConfiguration = new List<EIDSSModalConfiguration>(),
                EmployeeCategoryList = new List<BaseReferenceViewModel>(),
                OrganizationDD = new Select2Configruation(),
                PositionDD = new Select2Configruation(),
                SiteDD = new Select2Configruation(),
                CanManageReferencesandConfiguratuionsPermission = _permissionsCanAccessEmployeesList
            };
            var userAccountPermissions = GetUserPermissions(PagePermission.CanManageUserAccounts);
            model.ReportDetailsSection.EmployeeDetails.UserPermissions = userAccountPermissions;
            var canAccessOrganizationsList = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
            model.ReportDetailsSection.EmployeeDetails.CanAccessOrganizationsList = canAccessOrganizationsList;

            model.idfAggrCase = id;
            model.StartIndex = reviewPageNo;

            if (id != null)
            {
                if (model.Permissions.Write)
                    model.EnableFinishButton = true;

                var detailRequest = new AggregateReportGetListDetailRequestModel
                {
                    LanguageID = GetCurrentLanguage(),
                    idfAggrCase = (long)id,
                    idfsAggrCaseType = (long)AggregateDiseaseReportTypes.HumanAggregateDiseaseReport,
                    ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
                };
                var response = await _aggregateReportClient.GetAggregateReportDetail(detailRequest);
                if (response.Count > 0)
                {
                    model.ReportDetailsSection.AggregateDiseaseReportDetails = response[0];
                    model.ReportDetailsSection.AdministrativeLevelID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAreaType.GetValueOrDefault();
                    model.ReportDetailsSection.TimeIntervalID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsPeriodType.GetValueOrDefault();

                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsRegion;
                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsRayon;
                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSettlement;

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization != null)
                    {
                        strId = model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization.ToString();
                        text = model.ReportDetailsSection.AggregateDiseaseReportDetails.strOrganization;
                        model.ReportDetailsSection.Organizations.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                    }

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate != null && templateList.Count > 0)
                    {
                        strId = templateList.Find(v => v.idfsFormTemplate == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate).idfsFormTemplate.ToString();
                        text = templateList.Find(v => v.idfsFormTemplate == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate).DefaultName;
                        model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                    }
                    else
                    {
                        if (templateList.Count > 0)
                        {
                            model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate = templateList.Find(v => v.blnUNI).idfsFormTemplate;
                            strId = templateList.Find(v => v.blnUNI).idfsFormTemplate.ToString();
                            text = templateList.Find(v => v.blnUNI).DefaultName;
                            model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                        }
                        else
                        {
                            model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = GlobalConstants.NullValue.ToLower(), text = string.Empty };
                        }
                    }

                    var matrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType(MatrixTypes.HumanAggregateCase);

                    if (matrixVersionList.Any(v =>
                            v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion))
                    {
                        strId = matrixVersionList.Find(v =>
                                v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion)
                            .IdfVersion.ToString();
                        text = matrixVersionList.Find(v =>
                                v.IdfVersion == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion)
                            .MatrixName;
                        model.DiseaseMatrixSection.MatrixVersions.defaultSelect2Selection =
                            new Select2DataItem {id = strId, text = text};
                        model.DiseaseMatrixSection.idfVersion = long.Parse(strId);
                    }

                    model.DiseaseMatrixSection.AggregateCase.idfsFormTemplate = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate;
                    model.DiseaseMatrixSection.AggregateCase.idfObservation = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation;
                }
            }
            else
            {
                if (model.Permissions.Create)
                    model.EnableFinishButton = true;

                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByOffice = authenticatedUser.OfficeId;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByPerson = Convert.ToInt64(authenticatedUser.PersonId);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.strEnteredByOffice = authenticatedUser.Organization;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.strEnteredByPerson = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.datEnteredByDate = DateTime.Today;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite = Convert.ToInt64(authenticatedUser.SiteId);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAggrCaseType = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport);

                model.ReportDetailsSection.LegacyIDVisibleIndicator = false;

                var defaultData = new Select2DataItem { id = DateTime.Today.Year.ToString(), text = DateTime.Today.Year.ToString() };
                model.ReportDetailsSection.Years.defaultSelect2Selection = defaultData;
                defaultData = new Select2DataItem { id = GlobalConstants.NullValue.ToLower(), text = string.Empty };
                model.ReportDetailsSection.Quarters.defaultSelect2Selection = defaultData;
                model.ReportDetailsSection.Months.defaultSelect2Selection = defaultData;
                //model.ReportDetailsSection.Months = await GetMonthsAsync(System.DateTime.Today.Year);
                model.ReportDetailsSection.Weeks.defaultSelect2Selection = defaultData;

                //The currently activated Flexible Form template for Human Aggregate Disease Reports shall be displayed
                strId = templateList.Find(v => v.intRowStatus == 0).idfsFormTemplate.ToString();
                text = templateList.Find(v => v.intRowStatus == 0).DefaultName;
                model.DiseaseMatrixSection.Templates.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                model.DiseaseMatrixSection.AggregateCase.idfsFormTemplate = templateList.Find(v => v.intRowStatus == 0).idfsFormTemplate;

                //The default matrix for the Human Aggregate Disease Report shall be the currently activated matrix
                var matrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType(MatrixTypes.HumanAggregateCase);
                strId = matrixVersionList.Find(v => v.BlnIsActive == true).IdfVersion.ToString();
                text = matrixVersionList.Find(v => v.BlnIsActive == true).MatrixName;
                model.DiseaseMatrixSection.MatrixVersions.defaultSelect2Selection = new Select2DataItem { id = strId, text = text };
                model.DiseaseMatrixSection.idfVersion = long.Parse(strId);
            }

            await FillConfigurationSettingsAsync(model.ReportDetailsSection);

            model.ReportDetailsSection.DetailsLocationViewModel.CallingObjectID = "ReportDetailsSection_";
            model.ReportDetailsSection.DetailsLocationViewModel.SettlementId = model.ReportDetailsSection.DetailsLocationViewModel.Settlement;

            ////The default matrix for the Human Aggregate Disease Report shall be the currently activated matrix
            //var MatrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.AggregateCase);
            //strID = MatrixVersionList.Find(v => v.BlnIsActive == true).IdfVersion.ToString();
            //text = MatrixVersionList.Find(v => v.BlnIsActive == true).MatrixName;
            //model.DiseaseMatrixSection.MatrixVersions.defaultSelect2Selection = new Select2DataItem() { id = strID, text = text };
            //model.DiseaseMatrixSection.idfVersion = long.Parse(strID);

            //Generate report parameters
            model.ReportPrintViewModel = new DiseaseReportPrintViewModel
            {
                Parameters = new List<KeyValuePair<string, string>>(),
                ReportName = "HumanAggregateDiseaseReport"
            };

            //(long)FlexibleFormTypes.HumanAggregate;
            if (id != null)
            {
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("idfAggrCaseList", id.Value.ToString()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("idfsAggrCaseType", ((long)FlexibleFormTypes.HumanAggregate).ToString()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("LangID", GetCurrentLanguage()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("SiteID", _authenticatedUser.SiteId));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("PersonID", _authenticatedUser.PersonId));
            }

            await LoadFlexFormsAsync(model.DiseaseMatrixSection);

            //return View(model);
            return View("Details", model);
        }

        private async Task LoadFlexFormsAsync(DiseaseMatrixSectionViewModel model)
        {
            try
            {
                model.AggregateCase.MatrixColumns = new List<string>
                {
                    _localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                    _localizer.GetString(ColumnHeadingResourceKeyConstants.ICD10ColumnHeading)
                };

                model.AggregateCase.MatrixColumnStyles = new List<string>
                {
                    "position: sticky; background-color:white !important; left: 0px; min-width: 270px",
                    "position: sticky; background-color:white !important; left: 270px;"
                };
                model.AggregateCase.Title = "Human Aggregate Case";
                model.AggregateCase.SubmitButtonID = "btnSubmit";
                model.AggregateCase.LangID = GetCurrentLanguage();
                model.AggregateCase.idfsFormType = (long)FlexibleFormTypes.HumanAggregate;
                model.AggregateCase.ObserationFieldID = "idfCaseObservation";
                model.AggregateCase.idfObservation = model.AggregateCase.idfObservation;
                //model.AggregateCase.idfsFormTemplate = null;

                if (model.idfVersion != null)
                {
                    HumanAggregateCaseMatrixGetRequestModel request = new()
                    {
                        IdfVersion = (long)model.idfVersion,
                        PageSize = 1000,
                        Page = 1,
                        SortOrder = "asc",
                        SortColumn = "intNumRow",
                        LanguageId = GetCurrentLanguage()
                    };

                    var lstRow = await _humanAggregateDiseaseMatrixClient.GetHumanAggregateDiseaseMatrixList(request);

                    model.AggregateCase.MatrixData = new List<FlexFormMatrixData>();

                    foreach (var row in lstRow)
                    {
                        var matrixData = new FlexFormMatrixData
                        {
                            MatrixData = new List<string>(),

                            idfRow = row.IdfHumanCaseMTX
                        };
                        matrixData.MatrixData.Add(row.StrDefault);
                        matrixData.MatrixData.Add(row.StrIDC10);
                        model.AggregateCase.MatrixData.Add(matrixData);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost()]
        [Route("ReLoadFlexForms")]
        public async Task<IActionResult> ReLoadFlexFormsAsync([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                DiseaseMatrixSectionViewModel model = new()
                {
                    AggregateCase = new FlexFormQuestionnaireGetRequestModel(),
                    idfVersion = Convert.ToInt64(jsonObject["VersionID"]),
                    idfsFormTemplate = Convert.ToInt64(jsonObject["TemplateID"])
                };
                model.AggregateCase.idfObservation = string.IsNullOrEmpty(jsonObject["idfCaseObservation"]?.ToString()) ? null : Convert.ToInt64(jsonObject["idfCaseObservation"]);

                await LoadFlexFormsAsync(model);

                //return View(model);
                return PartialView("_HumanAggregateCaseFlexFormMatrixViewPartial", model.AggregateCase);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Review

        [HttpPost()]
        [Route("SaveAggregateDiseaseReport")]
        public async Task<JsonResult> SaveAggregateDiseaseReport([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                AggregateReportDetailsViewModel model = new()
                {
                    ReportDetailsSection = new()
                    {
                        Year = string.IsNullOrEmpty(jsonObject["Year"]?.ToString()) ? null : Convert.ToInt32(jsonObject["Year"]),
                        Quarter = jsonObject["Quarter"] == null ? null : string.IsNullOrEmpty(jsonObject["Quarter"].ToString()) ? null : Convert.ToInt32(jsonObject["Quarter"]),
                        Month = jsonObject["Month"] == null ? null : string.IsNullOrEmpty(jsonObject["Month"].ToString()) ? null : Convert.ToInt32(jsonObject["Month"]),
                        Week = jsonObject["Week"] == null ? null : string.IsNullOrEmpty(jsonObject["Week"].ToString()) ? null : Convert.ToInt32(jsonObject["Week"]),
                        Day = jsonObject["Day"] == null ? null : string.IsNullOrEmpty(jsonObject["Day"].ToString()) ? null : DateTime.Parse(jsonObject["Day"].ToString())
                    },
                    DiseaseMatrixSection = new()
                };

                model.ReportDetailsSection.DetailsLocationViewModel = new LocationViewModel();
                model.ReportDetailsSection.AggregateDiseaseReportDetails = new AggregateReportGetDetailViewModel
                {
                    idfAggrCase = jsonObject["idfAggrCase"] == null ? null : string.IsNullOrEmpty(jsonObject["idfAggrCase"].ToString()) ? null : Convert.ToInt64(jsonObject["idfAggrCase"]),
                    idfsSite = jsonObject["idfsSite"] == null ? null : string.IsNullOrEmpty(jsonObject["idfsSite"].ToString()) ? null : Convert.ToInt64(jsonObject["idfsSite"]),
                    idfsAggrCaseType = Convert.ToInt64(jsonObject["idfsAggrCaseType"]),
                    idfsAdministrativeUnit = jsonObject["idfsAdministrativeUnit"] == null ? null : string.IsNullOrEmpty(jsonObject["idfsAdministrativeUnit"].ToString()) ? null : Convert.ToInt64(jsonObject["idfsAdministrativeUnit"]),
                    strCaseID = jsonObject["strCaseID"].ToString(),
                    idfsAreaType = string.IsNullOrEmpty(jsonObject["idfsAreaType"].ToString()) ? null : Convert.ToInt64(jsonObject["idfsAreaType"]),
                    idfsPeriodType = string.IsNullOrEmpty(jsonObject["idfsPeriodType"].ToString()) ? null : Convert.ToInt64(jsonObject["idfsPeriodType"]),
                    idfCaseObservation = string.IsNullOrEmpty(jsonObject["idfCaseObservation"].ToString()) ? null : Convert.ToInt64(jsonObject["idfCaseObservation"]),
                    idfsCaseFormTemplate = string.IsNullOrEmpty(jsonObject["idfsCaseFormTemplate"].ToString()) ? null : Convert.ToInt64(jsonObject["idfsCaseFormTemplate"]),
                    datStartDate = string.IsNullOrEmpty(jsonObject["datStartDate"].ToString()) ? null : DateTime.Parse(jsonObject["datStartDate"].ToString()),
                    datFinishDate = string.IsNullOrEmpty(jsonObject["datFinishDate"].ToString()) ? null : DateTime.Parse(jsonObject["datFinishDate"].ToString()),
                    idfEnteredByOffice = Convert.ToInt64(jsonObject["idfEnteredByOffice"]),
                    idfEnteredByPerson = Convert.ToInt64(jsonObject["idfEnteredByPerson"]),
                    datEnteredByDate = string.IsNullOrEmpty(jsonObject["datEnteredByDate"].ToString()) ? null : DateTime.Parse(jsonObject["datEnteredByDate"].ToString()),
                    idfSentByOffice = Convert.ToInt64(jsonObject["idfSentByOffice"]),
                    idfSentByPerson = Convert.ToInt64(jsonObject["idfSentByPerson"]),
                    datSentByDate = string.IsNullOrEmpty(jsonObject["datSentByDate"].ToString()) ? null : DateTime.Parse(jsonObject["datSentByDate"].ToString()),
                    idfReceivedByOffice = jsonObject["idfReceivedByOffice"] == null ? null : string.IsNullOrEmpty(jsonObject["idfReceivedByOffice"].ToString()) ? null : Convert.ToInt64(jsonObject["idfReceivedByOffice"]),
                    idfReceivedByPerson = jsonObject["idfReceivedByPerson"] == null ? null : string.IsNullOrEmpty(jsonObject["idfReceivedByPerson"].ToString()) ? null : Convert.ToInt64(jsonObject["idfReceivedByPerson"]),
                    datReceivedByDate = jsonObject["datReceivedByDate"] == null ? null : string.IsNullOrEmpty(jsonObject["datReceivedByDate"].ToString()) ? null : DateTime.Parse(jsonObject["datReceivedByDate"].ToString())
                };

                model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel0Value = string.IsNullOrEmpty(jsonObject["CountryID"].ToString()) ? null : Convert.ToInt64(jsonObject["CountryID"]);
                model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value = string.IsNullOrEmpty(jsonObject["AdministrativeLevel1ID"].ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel1ID"]);
                model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value = string.IsNullOrEmpty(jsonObject["AdministrativeLevel2ID"].ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel2ID"]);
                model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value = string.IsNullOrEmpty(jsonObject["AdministrativeLevel3ID"].ToString()) ? null : Convert.ToInt64(jsonObject["AdministrativeLevel3ID"]);
                //model.ReportDetailsSection.DetailsLocationViewModel.Settlement = string.IsNullOrEmpty(jsonObject["SettlementID"].ToString()) ? null : Convert.ToInt64(jsonObject["SettlementID"]);

                model.DiseaseMatrixSection.idfVersion = Convert.ToInt64(jsonObject["VersionID"]);
                model.DiseaseMatrixSection.idfsFormTemplate = Convert.ToInt64(jsonObject["TemplateID"]);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate = model.DiseaseMatrixSection.idfsFormTemplate;

                model.ReportDetailsSection.Organization = jsonObject["Organization"] == null ? null : string.IsNullOrEmpty(jsonObject["Organization"].ToString()) ? null : Convert.ToInt64(jsonObject["Organization"]);

                //ModelState.ClearValidationState(nameof(AggregateDiseaseReportGetDetailViewModel));
                //if (!TryValidateModel(model.ReportDetailsSection.AggregateDiseaseReportDetails, nameof(AggregateDiseaseReportGetDetailViewModel)))
                //{
                //    model.ErrorMessage = "The record is not valid.  Please verify all data and correct any errors.";
                //    return Json(model);
                //}
                if (await ValidateAggregateDiseaseReportAsync(model.ReportDetailsSection, true) == false)
                {
                    var administrativeUnit = string.Empty;
                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization != null)
                    {
                        administrativeUnit += " <Region/Rayon/Settlement/Organization>";
                    }
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value != null)
                    {
                        administrativeUnit += " <Region/Rayon/Settlement>";
                    }
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value != null)
                    {
                        administrativeUnit += " <Region/Rayon>";
                    }
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value != null)
                    {
                        administrativeUnit += " <Region>";
                    }

                    var duplicateRecordMessage = string.Format(
                        _localizer.GetString(MessageResourceKeyConstants
                            .VeterinaryAggregateDiseaseReportDuplicateReportExistsMessage),
                        Convert.ToDateTime(model.ReportDetailsSection.AggregateDiseaseReportDetails.datStartDate)
                            .ToShortDateString(),
                        Convert.ToDateTime(model.ReportDetailsSection.AggregateDiseaseReportDetails.datFinishDate)
                            .ToShortDateString(),
                        administrativeUnit);

                    //var duplicate_field = model.ReportDetailsSection.AggregateDiseaseReportDetails.datStartDate + " - " + model.ReportDetailsSection.AggregateDiseaseReportDetails.datFinishDate;
                    //string duplicateRecordsFound = string.Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), duplicate_field);
                    //string duplicateRecordsFound = "It is not possible to create two aggregate reports with the same period (" + duplicate_field + ") and administrative unit (";

                    //if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value != null)
                    //{
                    //    //duplicateRecordsFound += model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Text + " (" + model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text + ")";
                    //    duplicateRecordsFound += "Rayon " + "(Region))";
                    //}
                    //else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text != null)
                    //{
                    //    duplicateRecordsFound += model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Text;
                    //}
                    //duplicateRecordsFound += "). Such Aggregate Disease Report already exists. Do you want to open that record?";
                    //model.InformationalMessage = duplicateRecordsFound;
                    model.InformationalMessage = duplicateRecordMessage;
                    model.WarningMessage = "Duplicate Record";
                    model.duplicateKey = DuplicateKey;
                }
                else
                //if (ModelState.IsValid)
                {
                    model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite ??= Convert.ToInt64(authenticatedUser.SiteId);
                    model.PendingSaveEvents ??= new List<EventSaveRequestModel>();

                    long? locationId = null;
                    if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value is not null)
                        locationId = model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value;
                    else if (model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value is not null)
                        locationId = model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value;

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase == null)
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite
                            ? SystemEventLogTypes.NewHumanAggregateDiseaseReportWasCreatedAtYourSite
                            : SystemEventLogTypes.NewHumanAggregateDiseaseReportWasCreatedAtAnotherSite;
                        model.PendingSaveEvents.Add(await CreateEvent(0,
                                null, eventTypeId, (long)model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite, locationId, null)
                            .ConfigureAwait(false));
                    }
                    else
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite
                            ? SystemEventLogTypes.HumanAggregateDiseaseReportWasChangedAtYourSite
                            : SystemEventLogTypes.HumanAggregateDiseaseReportWasChangedAtAnotherSite;
                        model.PendingSaveEvents.Add(await CreateEvent((long)model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase,
                                null, eventTypeId, (long)model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite, locationId, null)
                            .ConfigureAwait(false));
                    }

                    AggregateReportSaveRequestModel request = new()
                    {
                        AggregateReportID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase,
                        EIDSSAggregateReportID = model.ReportDetailsSection.AggregateDiseaseReportDetails.strCaseID,
                        AggregateReportTypeID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAggrCaseType,
                        GeographicalAdministrativeUnitID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAdministrativeUnit,
                        OrganizationalAdministrativeUnitID = model.ReportDetailsSection.AggregateDiseaseReportDetails.Organization,
                        ReceivedByOrganizationID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByOffice,
                        ReceivedByPersonID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfReceivedByPerson,
                        SentByOrganizationID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice,
                        SentByPersonID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByPerson,
                        EnteredByOrganizationID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByOffice,
                        EnteredByPersonID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByPerson,
                        CaseObservationID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation,
                        CaseObservationFormTemplateID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate,
                        DiagnosticObservationID = null,
                        DiagnosticObservationFormTemplateID = null,
                        ProphylacticObservationID = null,
                        ProphylacticObservationFormTemplateID = null,
                        SanitaryObservationID = null,
                        CaseVersion = model.DiseaseMatrixSection.idfVersion,
                        DiagnosticVersion = null,
                        ProphylacticVersion = null,
                        SanitaryVersion = null,
                        SanitaryObservationFormTemplateID = null,
                        ReceivedByDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datReceivedByDate,
                        SentByDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datSentByDate,
                        EnteredByDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datEnteredByDate,
                        StartDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datStartDate,
                        FinishDate = model.ReportDetailsSection.AggregateDiseaseReportDetails.datFinishDate,
                        ModificationForArchiveDate = null,
                        SiteID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite ?? Convert.ToInt64(authenticatedUser.SiteId),
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),

                        Events = JsonConvert.SerializeObject(model.PendingSaveEvents)
                    };

                    var response = await _aggregateReportClient.SaveAggregateReport(request);

                    if (response.ReturnCode != null)
                    {
                        switch (response.ReturnCode)
                        {
                            // Success
                            case 0:
                                if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase == null)
                                {
                                    model.ReportDetailsSection.AggregateDiseaseReportDetails.idfAggrCase = response.AggregateReportID;
                                    model.ReportDetailsSection.AggregateDiseaseReportDetails.strCaseID = response.EIDSSAggregateReportID;
                                }
                                model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                model.InformationalMessage += " " + _localizer.GetString(MessageResourceKeyConstants.MessagesRecordIDisMessage) + " " + response.EIDSSAggregateReportID + ".";
                                break;

                            default:
                                throw new ApplicationException("Unable to save Human Aggregate Disease Report.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save Human Aggregate Disease Report.");
                    }
                }

                return Json(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task<bool> ValidateAggregateDiseaseReportAsync(ReportDetailsSectionViewModel model, bool saveObservationIDIndicator)
        {
            var periodEnteredIndicator = false;
            //string period = model.AggregateDiseaseReportDetails.idfsPeriodType.ToString();
            var period = (long)model.AggregateDiseaseReportDetails.idfsPeriodType;
            var administrativeUnitEnteredIndicator = false;
            //string administrativeUnit;
            var administrativeUnit = (long)model.AggregateDiseaseReportDetails.idfsAreaType;
            DateTime sDate = new();
            DateTime eDate = new();
            //DateTime? sDate = null;
            //DateTime? eDate = null;

            //if (hdfPeriodTypeID.Value.IsValueNullOrEmpty())
            //{
            //    period = hdfMinimumTimeIntervalID.Value;
            //}
            //else
            //{
            //    period = hdfPeriodTypeID.Value;
            //}

            switch (period)
            {
                case (long)TimePeriodTypes.Day:
                    if (model.Day != null)
                    {
                        periodEnteredIndicator = true;
                        sDate = Convert.ToDateTime(model.Day);
                        eDate = Convert.ToDateTime(model.Day);
                    }
                    break;

                case (long)TimePeriodTypes.Month:
                    if (model.Year != null & model.Month != null)
                    {
                        periodEnteredIndicator = true;
                        sDate = new DateTime(Convert.ToInt16(model.Year.ToString()), (int)model.Month, 1);
                        eDate = sDate.AddMonths(1).AddDays(-1);
                    }
                    break;

                case (long)TimePeriodTypes.Quarter:
                    if (model.Year != null & model.Quarter != null)
                    {
                        periodEnteredIndicator = true;
                        var dRange = GetQuarterText((int)model.Quarter, (int)model.Year).Split("-");

                        if (dRange.Length == 3)
                        {
                            sDate = Convert.ToDateTime(dRange[1].Trim());
                            eDate = Convert.ToDateTime(dRange[2].Trim());
                        }
                        else
                        {
                            if (dRange[0].Contains("–"))
                            {
                                var list = dRange[0].Split("–");
                                sDate = Convert.ToDateTime(list[1].Trim());
                            }
                            //sDate = Convert.ToDateTime(dRange[0].Trim());
                            eDate = Convert.ToDateTime(dRange[1].Trim());
                        }
                    }
                    break;

                case (long)TimePeriodTypes.Week:
                    if (model.Year != null & model.Week != null)
                    {
                        periodEnteredIndicator = true;
                        Common.GetFirstAndLastDateOfWeek((int)model.Year, (int)model.Week, GetCurrentLanguage(), ref sDate, ref eDate);
                    }
                    break;

                case (long)TimePeriodTypes.Year:
                    if (model.Year != null)
                    {
                        periodEnteredIndicator = true;
                        sDate = new DateTime(Convert.ToInt16(model.Year.ToString()), 1, 1);
                        eDate = sDate.AddYears(1).AddDays(-1);
                    }
                    break;
            }

            model.AggregateDiseaseReportDetails.datStartDate = sDate;
            model.AggregateDiseaseReportDetails.datFinishDate = eDate;

            //if (hdfAdministrativeUnitTypeID.Value.IsValueNullOrEmpty())
            //{
            //    administrativeUnit = hdfMinimumAdministrativeLevelID.Value;
            //}
            //else
            //{
            //    administrativeUnit = hdfAdministrativeUnitTypeID.Value;
            //}

            switch (administrativeUnit)
            {
                case (long)AdministrativeUnitTypes.Settlement:
                    if (model.DetailsLocationViewModel.AdminLevel3Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel3Value;
                    }
                    break;

                case (long)AdministrativeUnitTypes.Rayon:
                    if (model.DetailsLocationViewModel.AdminLevel2Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel2Value;
                    }
                    break;

                case (long)AdministrativeUnitTypes.Region:
                    if (model.DetailsLocationViewModel.AdminLevel1Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel1Value;
                    }
                    break;

                case (long)AdministrativeUnitTypes.Country:
                    if (model.DetailsLocationViewModel.AdminLevel0Value != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel0Value;
                    }
                    break;

                default:
                    if (model.Organization != null)
                    {
                        administrativeUnitEnteredIndicator = true;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel3Value;
                        model.AggregateDiseaseReportDetails.Organization = model.Organization;
                    }
                    break;
            }

            if (periodEnteredIndicator & administrativeUnitEnteredIndicator)
            {
                var administrativeUnitId = (long?)null;

                if (model.AggregateDiseaseReportDetails.idfsAdministrativeUnit != null)
                {
                    administrativeUnitId = model.AggregateDiseaseReportDetails.idfsAdministrativeUnit;
                }
                else if (model.AggregateDiseaseReportDetails.Organization != null)
                {
                    administrativeUnitId = model.AggregateDiseaseReportDetails.Organization;
                }

                AggregateReportSearchRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport),
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "ReportID",
                    SortOrder = SortConstants.Descending,
                    TimeIntervalTypeID = period,
                    AdministrativeUnitTypeID = administrativeUnit,
                    AdministrativeUnitID = administrativeUnitId,
                    StartDate = model.AggregateDiseaseReportDetails.datStartDate,
                    EndDate = model.AggregateDiseaseReportDetails.datFinishDate,
                    OrganizationID = model.AggregateDiseaseReportDetails.Organization
                };

                var duplicateList = await _aggregateReportClient.GetAggregateReportList(request);

                if (model.AggregateDiseaseReportDetails.idfAggrCase == null && duplicateList.Count > 0)
                {
                    DuplicateKey = duplicateList[0].ReportKey;
                    return false;
                }
                else if (duplicateList.Any(x => x.ReportKey != (long)model.AggregateDiseaseReportDetails.idfAggrCase))
                {
                    return false;
                }
                else
                {
                    if (model.AggregateDiseaseReportDetails.idfCaseObservation == null && saveObservationIDIndicator)
                    {
                        // await SaveObservationAsync(model);
                    }

                    //return true;
                }

                //upHiddenFields.Update();
            }

            return true;
        }

        private async Task GetEventTypes()
        {
            try
            {
                if (EventTypes == null)
                {
                    var requestModel = new EventSubscriptionGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "EventName",
                        SortOrder = SortConstants.Ascending,
                        SiteAlertName = ""
                    };

                    var list = await _siteAlertsSubscriptionClient.GetSiteAlertsSubscriptionList(requestModel);

                    EventTypes = list;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// Creates a notification save model to add to a notifications collection for various
        /// events that occur in the EIDSS application.
        /// </summary>
        /// <param name="objectId">Identifier of the parent object; for example a human disease report, veterinary disease report, laboratory test, sample, etc.</param>
        /// <param name="diseaseId">Identifier for a disease of a disease report</param>
        /// <param name="eventTypeId"></param>
        /// <param name="siteId">The site identifier that is stored on the parent object/record.</param>
        /// <param name="locationId">Administrative levels 2 or 3 if populated.</param>
        /// <param name="customMessage">Override the base reference system event type which a more customized alert message.</param>
        /// <returns></returns>
        public async Task<EventSaveRequestModel> CreateEvent(long objectId, long? diseaseId, SystemEventLogTypes eventTypeId, long siteId, long? locationId, string customMessage)
        {
            if (EventTypes is null)
                await GetEventTypes();

            Events ??= new List<EventSaveRequestModel>();

            var identity = (Events.Count + 1) * -1;

            if (EventTypes != null && EventTypes.Any(x => x.EventTypeId == (long)eventTypeId))
            {
            }

            EventSaveRequestModel eventRecord = new()
            {
                LoginSiteId = Convert.ToInt64(authenticatedUser.SiteId),
                EventId = identity,
                ObjectId = objectId,
                EventTypeId = (long)eventTypeId,
                InformationString = string.IsNullOrEmpty(customMessage) ? null : customMessage,
                LocationId = locationId,
                SiteId = siteId, //site id of where the record was created.
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            return eventRecord;
        }

        #endregion

        #region Common functions

        private static DataTable CreatePeriodTable()
        {
            DataTable dt = new();
            dt.Columns.Add(new DataColumn("PeriodNumber", typeof(int)));
            dt.Columns.Add(new DataColumn("StartDay", typeof(DateTime)));
            dt.Columns.Add(new DataColumn("FinishDay", typeof(DateTime)));
            dt.Columns.Add(new DataColumn("PeriodName", typeof(string)));
            dt.Columns.Add(new DataColumn("PeriodID", typeof(string)));
            dt.PrimaryKey = new[] { dt.Columns["PeriodNumber"] };
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="year"></param>
        /// <returns></returns>
        public DataTable FillQuarterList(int year)
        {
            var mQuarterList =
                //if (m_QuarterList != null)
                //    m_QuarterList.Clear();
                CreatePeriodTable();

            DateTime d = new(year, 1, 1);

            for (var i = 1; i <= 4; i++)
            {
                if (year == DateTime.Today.Year && d > DateTime.Today)
                {
                    break; // TODO: might not be correct. Was : Exit For
                }

                var q = mQuarterList.NewRow();
                q["StartDay"] = d;
                q["PeriodNumber"] = i;
                q["PeriodID"] = year + "_" + i;
                d = d.AddMonths(3);
                d = d.AddDays(-1);
                q["FinishDay"] = d;
                d = d.AddDays(1);
                //Bug 3830 - Concatenate "Period Number" to the Quarter display values as specified in VAUC05  - Asim
                q["PeriodName"] = string.Format("{2} - {0:d} - {1:d}", q["StartDay"], q["FinishDay"], i);

                mQuarterList.Rows.Add(q);
            }

            return mQuarterList;
        }

        private static void AddMonthRow(DataTable monthTable, int year, int monthNum, string monthName)
        {
            DateTime d = new(year, monthNum, 1);
            if (d.Year == DateTime.Today.Year && d > DateTime.Today)
            {
                return;
            }
            var m = monthTable.NewRow();
            m["PeriodName"] = monthName;
            m["StartDay"] = d;
            m["PeriodNumber"] = d.Month;
            m["PeriodID"] = year + "_" + d.Month;
            d = d.AddMonths(1);
            m["FinishDay"] = d.AddDays(-1);
            monthTable.Rows.Add(m);
        }

        public async Task<DataTable> FillMonthListAsync(int year)
        {
            DataTable mMonthList;
            try
            {
                var monthNamesList = await _crossCuttingClient.GetReportMonthNameList(GetCurrentLanguage());

                //if (m_MonthList != null)
                //    m_MonthList.Clear();
                mMonthList = CreatePeriodTable();

                var intMonth = 1;
                var monthDict = new Dictionary<int, string>();

                for (var index = 0; index <= monthNamesList.Count - 1; index++)
                {
                    monthDict.Add(int.Parse(monthNamesList[index].idfsReference.ToString()), monthNamesList[index].strTextString);
                }

                foreach (var item in monthDict.Keys)
                {
                    AddMonthRow(mMonthList, year, intMonth, monthDict[item]);
                    intMonth += 1;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return mMonthList;
        }

        private List<WeekPeriod> GetWeeksList(int year)
        {
            List<WeekPeriod> weeksList = new();
            var firstDayOfYear = new DateTime(year, 1, 1);
            var start = (int)firstDayOfYear.DayOfWeek;
            var target = 0;
            if (target <= start) target += 7;
            var wStartDate = firstDayOfYear.AddDays(target - start);
            //System.DateTime wStartDate = new DateTime(year, 1, 1);
            var lastDayOfYear = wStartDate.AddYears(1).AddDays(-1);
            short weekNum = 1;

            try
            {
                //if year selected is current year, set last date to today
                if (lastDayOfYear > DateTime.Today)
                    lastDayOfYear = DateTime.Today;

                //in the loop, each week starts 7 days after the previous start date
                while (wStartDate < lastDayOfYear)
                {
                    WeekPeriod wPer = new()
                    {
                        Year = short.Parse(year.ToString()),
                        WeekNumber = weekNum,
                        WeekStartDate = wStartDate,
                        WeekEndDate = wStartDate.AddDays(6)
                    };
                    weeksList.Add(wPer);

                    weekNum += 1;
                    wStartDate = wStartDate.AddDays(7);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return weeksList;
        }

        public DataTable FillWeekList(int year, bool addSequencePrefix = false)
        {
            DataTable mWeekList = new();
            try
            {
                mWeekList.Clear();
                mWeekList = CreatePeriodTable();
                short sequence = 1;
                foreach (var wp in GetWeeksList(year))
                {
                    if (wp.WeekStartDate.Year == DateTime.Today.Year && wp.WeekStartDate > DateTime.Today)
                    {
                        break; // TODO: might not be correct. Was : Exit For
                    }
                    var weekRow = mWeekList.NewRow();
                    weekRow["PeriodNumber"] = wp.WeekNumber;
                    weekRow["StartDay"] = wp.WeekStartDate;
                    weekRow["PeriodID"] = year + "_" + wp.WeekNumber;
                    weekRow["FinishDay"] = wp.WeekEndDate;
                    if (addSequencePrefix)
                    {
                        weekRow["PeriodName"] = $"{sequence} - {wp.WeekStartDate:d} - {wp.WeekEndDate:d}";
                    }
                    else
                    {
                        weekRow["PeriodName"] = $"{wp.WeekStartDate:d} - {wp.WeekEndDate:d}";
                    }
                    mWeekList.Rows.Add(weekRow);
                    sequence += 1;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return mWeekList;
        }

        [HttpGet]
        public JsonResult GetQuarterList(string data)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                using var doc = JsonDocument.Parse(data);
                var root = doc.RootElement;
                var year = int.Parse(root[0].GetProperty("id").ToString() ?? string.Empty);

                var dt = FillQuarterList(year);
                select2DataItems.AddRange(from DataRow row in dt.Rows select new Select2DataItem {id = row["PeriodNumber"].ToString(), text = row["PeriodName"].ToString()});

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        [HttpGet]
        public async Task<JsonResult> GetMonthListAsync(string data)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                using var doc = JsonDocument.Parse(data);
                var root = doc.RootElement;
                var year = int.Parse(root[0].GetProperty("id").ToString() ?? string.Empty);

                var dt = await FillMonthListAsync(year);
                select2DataItems.AddRange(from DataRow row in dt.Rows select new Select2DataItem {id = row["PeriodNumber"].ToString(), text = row["PeriodName"].ToString()});

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        [HttpGet]
        public JsonResult GetWeekList(string data)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                using var doc = JsonDocument.Parse(data);
                var root = doc.RootElement;
                var year = int.Parse(root[0].GetProperty("id").ToString() ?? string.Empty);

                var dt = FillWeekList(year);
                select2DataItems.AddRange(from DataRow row in dt.Rows select new Select2DataItem {id = row["PeriodNumber"].ToString(), text = row["PeriodName"].ToString()});

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        //public async Task<List<Period>> GetMonthsAsync(int year)
        //{
        //    List<Period> list = new();
        //    DataTable dt = new DataTable();

        //    try
        //    {
        //        dt = await FillMonthListAsync(year);
        //        for (int i = 0; i < dt.Rows.Count; i++)
        //        {
        //            Period period = new Period();
        //            period.PeriodNumber = Convert.ToInt32(dt.Rows[i]["PeriodNumber"]);
        //            period.StartDay = Convert.ToDateTime(dt.Rows[i]["StartDay"].ToString());
        //            period.FinishDay = Convert.ToDateTime(dt.Rows[i]["FinishDay"].ToString());
        //            period.PeriodName = dt.Rows[i]["PeriodName"].ToString();
        //            period.PeriodID = dt.Rows[i]["PeriodID"].ToString();
        //            list.Add(period);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, null);
        //        throw;
        //    }

        //    return list;
        //}

        [HttpGet]
        public async Task<JsonResult> GetOrganizationsByAdministrativeLevelID(int page, long? data, string term)
        {
            Pagination pagination = new(); //Pagination
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            OrganizationGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.SortColumn = "AbbreviatedName";
                request.SortOrder = "ASC";
                request.PageSize = 100;
                request.Page = page;
                request.AdministrativeLevelID = data;
                request.AccessoryCode = (int?)AccessoryCodes.HumanHACode;
                request.FullName = term;

                var list = await _organizationClient.GetOrganizationList(request);
                if (list != null)
                {
                    select2DataItems.Add(new Select2DataItem { id = GlobalConstants.NullValue.ToLower(), text = string.Empty });

                    select2DataItems.AddRange(list.Select(item => new Select2DataItem {id = item.OrganizationKey.ToString(), text = item.AbbreviatedName}));
                }
                pagination.more = true; //Add Pagination
                select2DataObj.results = select2DataItems;
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public string GetQuarterText(int id, int year)
        {
            var text = id switch
            {
                1 => $"1 - 1/1/{year.ToString()} - 3/31/{year.ToString()}",
                2 => $"2 - 4/1/{year.ToString()} - 6/30/{year.ToString()}",
                3 => $"3 - 7/1/{year.ToString()} - 9/30/{year.ToString()}",
                4 => $"4 – 10/1/{year.ToString()} - 12/31/{year.ToString()}",
                _ => string.Empty
            };
            return text;
        }

        #endregion

        #region Delete Aggregate Disease Report

        /// <summary>
        /// Deletes an Aggregate Disease Report.
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        public async Task<IActionResult> Delete([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (jsonObject["id"] != null)
                {
                    var reportId = long.Parse(jsonObject["id"].ToString());
                    response = await _aggregateReportClient.DeleteAggregateReport(reportId, authenticatedUser.UserName);

                    return response.ReturnCode switch
                    {
                        null => throw new ApplicationException("Unable to delete Aggregate Disease Report."),
                        0 => Json(response.ReturnMessage),
                        _ => throw new ApplicationException("Unable to delete Aggregate Disease Report.")
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(response.ReturnMessage);
        }

        [HttpPost]
        public async Task<IActionResult> Print([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                //long reportID = long.Parse(jsonObject["id"].ToString());
                if (jsonObject["id"] != null)
                {
                    var reportId = long.Parse(jsonObject["id"].ToString());
                    response = await _aggregateReportClient.DeleteAggregateReport(reportId, authenticatedUser.UserName);

                    return response.ReturnCode switch
                    {
                        null => throw new ApplicationException("Unable to delete Aggregate Disease Report."),
                        0 => Json(response.ReturnMessage),
                        _ => throw new ApplicationException("Unable to delete Aggregate Disease Report.")
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(response.ReturnMessage);
        }

        private static bool ActiveAdminLevel(int iAdminLevel, AggregateSettingsModel aggregateSetting)
        {
            var bActive = iAdminLevel switch
            {
                1 => aggregateSetting.idfsStatisticAreaType is StatisticAreaTypeIds.Region or StatisticAreaTypeIds.Rayon or StatisticAreaTypeIds.Settlement,
                2 => aggregateSetting.idfsStatisticAreaType is StatisticAreaTypeIds.Region or StatisticAreaTypeIds.Rayon,
                3 => aggregateSetting.idfsStatisticAreaType == StatisticAreaTypeIds.Region,
                _ => false
            };

            return bActive;
        }

        #endregion
    }

    internal class WeekPeriod
    {
        public short Year { get; set; }

        public short WeekNumber { get; set; }

        public DateTime WeekStartDate { get; set; }

        public DateTime WeekEndDate { get; set; }
    }

    public class Period
    {
        public int PeriodNumber { get; set; }
        public DateTime StartDay { get; set; }
        public DateTime FinishDay { get; set; }
        public string PeriodName { get; set; }
        public string PeriodID { get; set; }
    }
}