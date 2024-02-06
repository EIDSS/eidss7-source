#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Human.SearchHumanAggregateDiseaseReport
{
    public class SearchHumanAggregateDiseaseReportBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IAggregateReportClient AggregateReportClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IAggregateSettingsClient AggregateSettingsClient { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        private ILogger<SearchHumanAggregateDiseaseReportBase> Logger { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        #endregion Parameters

        #region Properties

        protected RadzenDataGrid<AggregateReportGetListViewModel> Grid { get; set; }
        protected RadzenTemplateForm<AggregateReportSearchViewModel> Form { get; set; }
        protected IEnumerable<AggregateReportGetListViewModel> SearchResults { get; set; }
        protected AggregateReportSearchViewModel Model { get; set; }
        protected IEnumerable<BaseReferenceViewModel> TimeIntervalUnits { get; set; }
        protected IEnumerable<BaseReferenceViewModel> AdminLevelUnits { get; set; }
        protected IEnumerable<OrganizationGetListViewModel> Organizations { get; set; }

        #endregion Properties

        #region Member Variables

        protected int Count;
        protected int TimeIntervalCount;
        protected int AdminLevelCount;
        protected bool IsLoading;
        protected bool DisableAddButton;
        protected bool DisableEditButton;
        protected bool ShowCancelButton;
        protected bool ShowCancelSearchResultsButton;
        protected bool ShowClearButton;
        protected bool ShowSearchButton;
        protected bool ShowPrintButton;
        protected bool ExpandSearchCriteria;
        protected bool ExpandAdvancedSearchCriteria;
        protected bool ExpandSearchResults;
        protected bool ShowCriteria;
        protected bool ShowResults;
        protected bool SearchSubmitted;

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _shouldRender = true;
        private bool _isRecordSelected;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation _token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            //initialize Model
            await InitializeModelAsync();

            //set grid for not loaded
            IsLoading = false;

            //set up the accordions
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            ShowResults = false;
            SetButtonStates();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion Lifecycle Methods

        #region Refresh Location

        protected async Task RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            Model.SearchLocationViewModel = locationViewModel;
            await GetOrganizationsByAdministrativeLevelIdAsync(locationViewModel);
        }

        #endregion Refresh Location

        #region Print Search Results

        protected async Task PrintSearchResults()
        {
            if (Form.IsValid)
            {
                try
                {
                    ReportViewModel reportModel = new();

                    // required parameters
                    reportModel.AddParameter("LanguageID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants
                            .HumanAggregateDiseaseReportPageHeading));
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("AggregateReportTypeID", Model.SearchCriteria.AggregateReportTypeID.ToString());
                    reportModel.AddParameter("ReportID", Model.SearchCriteria.ReportID);
                    reportModel.AddParameter("sortColumn", "ReportID");
                    reportModel.AddParameter("sortOrder", "DESC");
                    reportModel.AddParameter("pageSize", Grid.Count.ToString());
                    reportModel.AddParameter("AdministrativeUnitTypeID", Model.SearchCriteria.AdministrativeUnitTypeID.ToString());
                    reportModel.AddParameter("TimeIntervalTypeID", Model.SearchCriteria.TimeIntervalTypeID.ToString());
                    reportModel.AddParameter("StartDate", Model.SearchCriteria.StartDate.ToString());
                    reportModel.AddParameter("EndDate", Model.SearchCriteria.EndDate.ToString());
                    reportModel.AddParameter("AdministrativeUnitID", Model.SearchCriteria.AdministrativeUnitID.ToString());
                    reportModel.AddParameter("OrganizationID", Model.SearchCriteria.OrganizationID.ToString());
                    reportModel.AddParameter("SelectAllIndicator", Model.SearchCriteria.SelectAllIndicator.ToString());
                    reportModel.AddParameter("UserSiteID", authenticatedUser.SiteId);
                    reportModel.AddParameter("UserEmployeeID", authenticatedUser.PersonId);
                    reportModel.AddParameter("UserOrganizationID", authenticatedUser.Organization);
                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId >= (long) SiteTypes.ThirdLevel ? "1" : "0");

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.HumanAggregateDiseaseReportPageHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "SearchForHumanAggregateDiseaseReport"}, {"Parameters", reportModel.Parameters}},
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.HumanActiveSurveillanceSession,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1050px"
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        #endregion Print Search Results

        #region Clear and Reset

        protected async Task ResetSearchAsync()
        {
            //initialize new Model with defaults
            //InitializeModelAsync();
            Model.SearchLocationViewModel.AdminLevel3Value = null;
            Model.SearchCriteria.OrganizationID = null;
            await FillConfigurationSettings(Model.SearchCriteria.AdministrativeUnitTypeID, Model);
            await RefreshLocationViewModelHandlerAsync(Model.SearchLocationViewModel);

            //set grid for not loaded
            IsLoading = false;

            //reset the cancellation _token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            //set up the accordions and buttons
            SearchSubmitted = false;
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            ExpandAdvancedSearchCriteria = false;
            ExpandSearchResults = false;
            ShowResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearchAsync()
        {
            var buttons = new List<DialogButton>();
            var yesButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            var noButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);
            buttons.Add(noButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

            if (result is DialogReturnResult dialogResult
                && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                //cancel search and user said yes
                _source?.Cancel();
                _shouldRender = false;
                var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                //cancel search but user said no so leave everything alone and cancel thread
                _source?.Cancel();
            }
        }

        #endregion Clear and Reset

        #region Accordion

        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search criteria toggle
                case 0:

                    if (ExpandSearchResults && ExpandSearchCriteria == false)
                    {
                        ExpandSearchResults = !ExpandSearchResults;
                    }
                    ExpandSearchCriteria = !ExpandSearchCriteria;
                    break;

                //search results toggle
                case 1:

                    ExpandSearchResults = !ExpandSearchResults;
                    break;
            }
            SetButtonStates();
        }

        #endregion Accordion

        #region Dialogs

        protected async Task ShowNoSearchCriteriaDialog()
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {"DialogName", "NoCriteria"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.EnterAtLeastOneParameterMessage)}
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString("Search timed out, try narrowing your search criteria.")}
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

        #endregion Dialogs

        #region Load Search Results

        protected async Task LoadData(LoadDataArgs args)
        {
            if (SearchSubmitted)
            {
                try
                {
                    IsLoading = true;
                    ShowResults = true;

                    var request = new AggregateReportSearchRequestModel
                    {
                        AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport),
                        TimeIntervalTypeID = Model.SearchCriteria.TimeIntervalTypeID,
                        AdministrativeUnitTypeID = Model.SearchCriteria.AdministrativeUnitTypeID,
                        ReportID = Model.SearchCriteria.ReportID,
                        StartDate = Model.SearchCriteria.StartDate,
                        EndDate = Model.SearchCriteria.EndDate,
                        OrganizationID = Model.SearchCriteria.OrganizationID
                    };

                    //Get lowest administrative level.
                    if (Model.SearchLocationViewModel.AdminLevel3Value != null)
                        request.AdministrativeUnitID = IsNullOrEmpty(Model.SearchLocationViewModel.AdminLevel3Value.ToString()) ? null : Convert.ToInt64(Model.SearchLocationViewModel.AdminLevel3Value);
                    else if (Model.SearchLocationViewModel.AdminLevel2Value != null)
                        request.AdministrativeUnitID = IsNullOrEmpty(Model.SearchLocationViewModel.AdminLevel2Value.ToString()) ? null : Convert.ToInt64(Model.SearchLocationViewModel.AdminLevel2Value);
                    else if (Model.SearchLocationViewModel.AdminLevel1Value != null)
                        request.AdministrativeUnitID = IsNullOrEmpty(Model.SearchLocationViewModel.AdminLevel1Value.ToString()) ? null : Convert.ToInt64(Model.SearchLocationViewModel.AdminLevel1Value);
                    else
                        request.AdministrativeUnitID = null;

                    //sorting
                    request.SortColumn = !IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "EIDSSReportID";
                    request.SortOrder = args.Sorts.FirstOrDefault() != null
                        ? SortConstants.Descending
                        : SortConstants.Ascending;
                    //paging
                    if (args.Skip is > 0)
                        request.Page = args.Skip.Value / Grid.PageSize + 1;
                    else
                        request.Page = 1;
                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;

                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel;
                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    if (_isRecordSelected == false)
                    {
                        var result = await AggregateReportClient.GetAggregateReportList(request, _token);
                        if (_source?.IsCancellationRequested == false)
                        {
                            SearchResults = result;
                            var recordCount = SearchResults.First().RecordCount;
                            if (recordCount != null)
                                Count = SearchResults.FirstOrDefault() != null
                                    ? recordCount.Value
                                    : 0;
                        }
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch cancellation or timeout exception
                    if (e.HResult == -2146233088 || _source?.IsCancellationRequested == true)
                    {
                        await ShowNarrowSearchCriteriaDialog();
                    }
                }
                finally
                {
                    IsLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            else
            {
                //initialize the grid so that it displays 'No records message'
                SearchResults = new List<AggregateReportGetListViewModel>();
                Count = 0;
                IsLoading = false;
            }
        }

        #endregion Load Search Results

        #region Form Submit

        protected async Task HandleValidSearchSubmit(AggregateReportSearchViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                SearchSubmitted = true;
                ShowResults = true;
                ExpandSearchResults = true;
                ExpandSearchCriteria = false;
                ExpandAdvancedSearchCriteria = false;
                ShowCriteria = false;
                SetButtonStates();

                if (Grid != null)
                {
                    await Grid.Reload();
                }
            }
            else
            {
                //no search criteria entered - display the EIDSS dialog component
                SearchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
        }

        #endregion Form Submit

        #region Event Handlers

        protected async Task CancelSearchClicked()
        {
            await CancelSearchAsync();
        }

        protected void OpenEdit(long id)
        {
            _isRecordSelected = true;

            NavManager.NavigateTo($"{NavManager.BaseUri}Human/AggregateDiseasesReport/Details/{id}", true);
        }

        protected void OpenAdd()
        {
            NavManager.NavigateTo($"{NavManager.BaseUri}Human/AggregateDiseasesReport/Details", true);
        }

        protected void SendReportLink(long id)
        {
            _isRecordSelected = true;

            switch (Mode)
            {
                case SearchModeEnum.Import:
                {
                    if (CallbackUrl.EndsWith('/'))
                    {
                        CallbackUrl = CallbackUrl[..^1];
                    }

                    var url = CallbackUrl + $"?Id={id}";

                    if (CallbackKey != null)
                    {
                        url += "&callbackkey=" + CallbackKey.ToString();
                    }
                    NavManager.NavigateTo(url, true);
                    break;
                }
                case SearchModeEnum.Select:
                    DiagService.Close(SearchResults.First(x => x.ReportKey == id));
                    break;
                default:
                {
                    _shouldRender = false;
                    const string path = "Human/AggregateDiseasesReport/Details";
                    var query = $"?id={id}&isReadOnly=true";
                    var uri = $"{NavManager.BaseUri}{path}{query}";

                    NavManager.NavigateTo(uri, true);
                    break;
                }
            }
        }

        #endregion Event Handlers

        #region Load Drop Downs

        protected async Task GetTimeIntervalUnitAsync()
        {
            TimeIntervalUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.StatisticalPeriodType, HACodeList.NoneHACode);
            TimeIntervalCount = TimeIntervalUnits.Count();
        }

        protected async Task GetAdminLevelUnitAsync()
        {
            AdminLevelUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.StatisticalAreaType, HACodeList.NoneHACode);
            AdminLevelCount = AdminLevelUnits.Count();
        }

        protected async Task GetOrganizationsByAdministrativeLevelIdAsync(LocationViewModel model)
        {
            // Get a filtered list of organizations that corresponds to the selected values in “AdminLevel1”, and/or “AdminLevel2”, and /or “AdminLevel3” and/or “AdminLevelX” fields.
            long? administrativeLevelId;

            //Get lowest administrative level.
            if (model.AdminLevel3Value != null)
                administrativeLevelId = IsNullOrEmpty(model.AdminLevel3Value.ToString()) ? null : Convert.ToInt64(model.AdminLevel3Value);
            else if (model.AdminLevel2Value != null)
                administrativeLevelId = IsNullOrEmpty(model.AdminLevel2Value.ToString()) ? null : Convert.ToInt64(model.AdminLevel2Value);
            else if (model.AdminLevel1Value != null)
                administrativeLevelId = IsNullOrEmpty(model.AdminLevel1Value.ToString()) ? null : Convert.ToInt64(model.AdminLevel1Value);
            else
                administrativeLevelId = null;

            var request = new OrganizationGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "AbbreviatedName",
                SortOrder = SortConstants.Ascending,
                AdministrativeLevelID = administrativeLevelId
            };
            var list = await OrganizationClient.GetOrganizationList(request);
            Organizations = list.AsODataEnumerable();
        }

        #endregion Load Drop Downs

        #region Initialize Methods

        private void SetButtonStates()
        {
            if (ExpandSearchResults)
            {
                ShowCancelButton = false;
                ShowCancelSearchResultsButton = true;
                ShowPrintButton = true;
                ShowSearchButton = false;
                ShowClearButton = false;
            }
            else
            {
                ShowPrintButton = false;
                ShowCancelButton = true;
                ShowCancelSearchResultsButton = false;
                ShowSearchButton = true;
                ShowClearButton = true;
            }

            if (!Model.Permissions.Create)
            {
                DisableAddButton = true;
            }

            if (!Model.Permissions.Write)
                DisableEditButton = true;
        }

        private async Task InitializeModelAsync()
        {
            // bottom admin level
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            Model = new AggregateReportSearchViewModel()
            {
                Permissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports),
                SearchCriteria =
                {
                    SortColumn = "ReportID",
                    SortOrder = SortConstants.Descending
                },
                SearchLocationViewModel = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = true,
                    EnableAdminLevel2 = true,
                    EnableAdminLevel3 = bottomAdmin >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    EnableAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    EnableAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    EnableAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = bottomAdmin >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    ShowAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    ShowAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    ShowAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                    ShowSettlement = true,
                    ShowSettlementType = true,
                    ShowStreet = false,
                    ShowBuilding = false,
                    ShowApartment = false,
                    ShowElevation = false,
                    ShowHouse = false,
                    ShowLatitude = false,
                    ShowLongitude = false,
                    ShowMap = false,
                    ShowBuildingHouseApartmentGroup = false,
                    ShowPostalCode = false,
                    ShowCoordinates = false,
                    IsDbRequiredAdminLevel0 = false,
                    IsDbRequiredAdminLevel1 = false,
                    IsDbRequiredAdminLevel2 = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(CountryID)
                }
            };

            await FillConfigurationSettings(null, Model);
        }

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        private bool HasCriteria(AggregateReportSearchViewModel model)
        {
            var properties = Model.SearchCriteria.GetType().GetProperties()
                .Where(p => p.DeclaringType != typeof(BaseGetRequestModel)
                            && !p.Name.Contains("UserSiteID")
                            && !p.Name.Contains("UserEmployeeID")
                            && !p.Name.Contains("UserOrganizationID")
                            && !p.Name.Contains("ApplySiteFiltrationIndicator")
                            && !p.Name.Contains("SelectAllIndicator")
                            && !p.Name.Contains("OrganizationIDDisabledIndicator"))
                .ToArray();

            foreach (var prop in properties)
            {
                if (prop.GetValue(Model.SearchCriteria) == null) continue;
                if (prop.PropertyType == typeof(string))
                {
                    var value = prop.GetValue(Model.SearchCriteria)?.ToString()?.Trim();
                    if (!IsNullOrWhiteSpace(value)) return true;
                    if (!IsNullOrEmpty(value)) return true;
                }
                else
                {
                    return true;
                }
            }

            //Check the location
            return Model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                   Model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                   Model.SearchLocationViewModel.AdminLevel1Value.HasValue;
        }

        private async Task FillConfigurationSettings(long? administrativeUnitType, AggregateReportSearchViewModel model)
        {
            var searchLocationModel = Model.SearchLocationViewModel;

            var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                var aggregateSettingsGetRequestModel = new AggregateSettingsGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfCustomizationPackage = siteDetails.CustomizationPackageID,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = SortConstants.Ascending
                };

                var aggregateSettings = await AggregateSettingsClient.GetAggregateSettingsList(aggregateSettingsGetRequestModel);

                var aggregateSetting = aggregateSettings.FirstOrDefault(a => a.idfsAggrCaseType == Convert.ToInt64(AggregateValue.Veterinary));
                if (aggregateSetting != null)
                {
                    Model.SearchCriteria.AdministrativeUnitTypeID =
                        administrativeUnitType ?? aggregateSetting.idfsStatisticAreaType;

                    Model.SearchCriteria.TimeIntervalTypeID = aggregateSetting.idfsStatisticPeriodType;
                }

                searchLocationModel.AdminLevel0Value = siteDetails.CountryID;

                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
                searchLocationModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;

                searchLocationModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;

                // Location Control
                searchLocationModel.IsHorizontalLayout = true;
                searchLocationModel.EnableAdminLevel1 = true;
                searchLocationModel.ShowAdminLevel0 = false;
                searchLocationModel.ShowAdminLevel1 = true;
                searchLocationModel.ShowAdminLevel2 = true;
                searchLocationModel.ShowAdminLevel3 = true;
                searchLocationModel.ShowAdminLevel4 = false;
                searchLocationModel.ShowAdminLevel5 = false;
                searchLocationModel.ShowAdminLevel6 = false;
                searchLocationModel.ShowSettlement = true;
                searchLocationModel.ShowSettlementType = false;
                searchLocationModel.ShowStreet = false;
                searchLocationModel.ShowBuilding = false;
                searchLocationModel.ShowApartment = false;
                searchLocationModel.ShowElevation = false;
                searchLocationModel.ShowHouse = false;
                searchLocationModel.ShowLatitude = false;
                searchLocationModel.ShowLongitude = false;
                searchLocationModel.ShowMap = false;
                searchLocationModel.ShowBuildingHouseApartmentGroup = false;
                searchLocationModel.ShowPostalCode = false;
                searchLocationModel.ShowCoordinates = false;
                searchLocationModel.IsDbRequiredAdminLevel0 = false;
                searchLocationModel.IsDbRequiredAdminLevel1 = false;
                searchLocationModel.IsDbRequiredAdminLevel2 = false;
                searchLocationModel.IsDbRequiredAdminLevel3 = false;
                searchLocationModel.IsDbRequiredSettlement = false;
                searchLocationModel.IsDbRequiredSettlementType = false;
                searchLocationModel.AdminLevel0Value = siteDetails.CountryID;

                switch (Model.SearchCriteria.AdministrativeUnitTypeID)
                {
                    case (long)AdministrativeUnitTypes.Country:
                        searchLocationModel.EnableAdminLevel1 = false;
                        searchLocationModel.EnableAdminLevel2 = false;
                        searchLocationModel.EnableAdminLevel3 = false;
                        searchLocationModel.EnableSettlement = false;
                        searchLocationModel.AdminLevel1Value = null;
                        searchLocationModel.AdminLevel2Value = null;
                        searchLocationModel.AdminLevel3Value = null;
                        searchLocationModel.AdminLevel1List = null;

                        searchLocationModel.DisableAtElementLevel = "AdminLevel1Value";
                        Model.SearchCriteria.AdministrativeUnitID = searchLocationModel.AdminLevel0Value;
                        Model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    case (long)AdministrativeUnitTypes.Region:
                        searchLocationModel.AdminLevel1Value = searchLocationModel.AdminLevel1Value;
                        searchLocationModel.ShowAdminLevel1 = true;
                        searchLocationModel.ShowAdminLevel2 = true;
                        searchLocationModel.ShowAdminLevel3 = true;

                        searchLocationModel.EnableAdminLevel1 = true;
                        searchLocationModel.EnableAdminLevel2 = false;
                        searchLocationModel.EnableAdminLevel3 = false;
                        searchLocationModel.EnableSettlement = false;
                        searchLocationModel.AdminLevel2Value = null;
                        searchLocationModel.AdminLevel3Value = null;
                        searchLocationModel.AdminLevel2List = null;
                        searchLocationModel.DisableAtElementLevel = "AdminLevel2Value";
                        Model.SearchCriteria.AdministrativeUnitID = searchLocationModel.AdminLevel1Value;
                        Model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    case (long)AdministrativeUnitTypes.Rayon:
                        searchLocationModel.AdminLevel1Value = searchLocationModel.AdminLevel1Value;
                        searchLocationModel.AdminLevel2Value = searchLocationModel.AdminLevel2Value;
                        searchLocationModel.ShowAdminLevel1 = true;
                        searchLocationModel.ShowAdminLevel2 = true;
                        searchLocationModel.ShowAdminLevel3 = true;
                        searchLocationModel.EnableAdminLevel1 = true;
                        searchLocationModel.EnableAdminLevel2 = true;
                        searchLocationModel.EnableAdminLevel3 = false;
                        searchLocationModel.EnableSettlement = false;
                        searchLocationModel.AdminLevel3Value = null;
                        searchLocationModel.AdminLevel3List = null;
                        searchLocationModel.DisableAtElementLevel = "AdminLevel3Value";

                        Model.SearchCriteria.AdministrativeUnitID = searchLocationModel.AdminLevel2Value;
                        Model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    case (long)AdministrativeUnitTypes.Settlement:
                        searchLocationModel.AdminLevel1Value = searchLocationModel.AdminLevel1Value;
                        searchLocationModel.AdminLevel2Value = searchLocationModel.AdminLevel2Value;
                        searchLocationModel.ShowAdminLevel1 = true;
                        searchLocationModel.EnableAdminLevel1 = true;
                        searchLocationModel.ShowAdminLevel2 = true;
                        searchLocationModel.ShowAdminLevel3 = true;

                        searchLocationModel.EnableAdminLevel2 = true;
                        searchLocationModel.EnableAdminLevel3 = true;
                        searchLocationModel.ShowSettlementType = false;
                        Model.SearchCriteria.AdministrativeUnitID = Model.SearchLocationViewModel.AdminLevel3Value != null ? searchLocationModel.AdminLevel3Value : searchLocationModel.AdminLevel2Value;
                        Model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    default:
                        searchLocationModel.AdminLevel1Value = searchLocationModel.AdminLevel1Value;
                        searchLocationModel.AdminLevel2Value = searchLocationModel.AdminLevel2Value;
                        searchLocationModel.ShowAdminLevel1 = true;
                        searchLocationModel.EnableAdminLevel1 = true;
                        searchLocationModel.ShowAdminLevel2 = true;
                        searchLocationModel.EnableAdminLevel2 = true;
                        searchLocationModel.EnableAdminLevel3 = true;

                        searchLocationModel.ShowSettlementType = false;
                        Model.SearchCriteria.AdministrativeUnitID = searchLocationModel.AdminLevel3Value;
                        Model.SearchCriteria.OrganizationIDDisabledIndicator = false;
                        break;
                }

                Model.SearchLocationViewModel = searchLocationModel;
            }
        }

        #endregion Initialize Methods

        #endregion Methods
    }
}