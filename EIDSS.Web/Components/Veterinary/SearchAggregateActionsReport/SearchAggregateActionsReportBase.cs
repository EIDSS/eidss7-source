#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Veterinary.ViewModels.AggregateActionsReport;
using EIDSS.Web.Areas.Veterinary.ViewModels.Farm;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
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

namespace EIDSS.Web.Components.Veterinary.SearchAggregateActionsReport
{
    public class SearchAggregateActionsReportBase : SearchComponentBase<SearchFarmPageViewModel>, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IAggregateReportClient AggregateReportClient { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ILogger<SearchAggregateActionsReportBase> Logger { get; set; }
        [Inject] private IAggregateSettingsClient AggregateSettingsClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public bool Refresh { get; set; }
        [Parameter] public bool RefreshResultsIndicator { get; set; }

        [Parameter]
        public long CampaignCategoryId { get; set; }

        #endregion

        #region Properties

        protected SearchAggregateActionsReportPageViewModel Model { get; set; }
        protected RadzenTemplateForm<SearchAggregateActionsReportPageViewModel> Form { get; set; }
        protected RadzenDataGrid<AggregateReportGetListViewModel> Grid { get; set; }
        protected LocationView LocationViewComponent;

        #endregion

        #region Protected and Public Members

        protected IEnumerable<BaseReferenceViewModel> TimeIntervals;
        protected IEnumerable<BaseReferenceViewModel> AdministrativeLevels;

        #endregion

        #region Private Members

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _isRecordSelected;

        #endregion

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            LoadingComponentIndicator = true;

            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            InitializeModel();

            // get the time interval types
            //await GetTimeIntervalsAsync();

            // see if a search was saved
            var indicatorResult =
                await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .VeterinaryAggregateActionsSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult is { Success: true, Value: true };
            if (searchPerformedIndicator)
            {
                var searchModelResult =
                    await BrowserStorage.GetAsync<SearchAggregateActionsReportPageViewModel>(SearchPersistenceKeys
                        .VeterinaryAggregateActionsSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    // Disease report was deleted, so refresh the persisted results.
                    if (RefreshResultsIndicator)
                    {
                        searchSubmitted = true;
                        if (Grid != null)
                            await Grid.Reload();

                        // Update persisted search results after disease report deleted.
                        await BrowserStorage.SetAsync(
                            SearchPersistenceKeys.VeterinaryAggregateActionsSearchPerformedIndicatorKey, true);
                        await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchModelKey,
                            Model);
                    }
                    else
                    {
                        Model.SearchResults = searchModel.SearchResults;
                        count = (int) (Model.SearchResults.Count > 0
                                ? Model.SearchResults.FirstOrDefault()?.RecordCount
                                : 0);
                    }

                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;

                    if (Grid is not null)
                        Grid.PageSize = Model.SearchCriteria.PageSize != 0 ? Model.SearchCriteria.PageSize : 10;

                    // set up the accordions
                    expandSearchCriteria = false;
                    showSearchCriteriaButtons = false;
                    showSearchResults = true;

                    isLoading = false;
                }
            }
            else
            {
                // set grid for not loading
                isLoading = false;

                // set the defaults
                await SetDefaults();

                // set up the accordions
                expandSearchCriteria = true;
                showSearchCriteriaButtons = true;
                showSearchResults = false;
            }

            await SetButtonStates();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (Refresh)
                    searchSubmitted = true;
                await Grid.Reload();

                await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                LoadingComponentIndicator = false;

                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        ///     Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        protected async Task AccordionClick(int index)
        {
            expandSearchCriteria = index switch
            {
                //search criteria toggle
                0 => !expandSearchCriteria,
                _ => expandSearchCriteria
            };
            await SetButtonStates();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
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
                {"DialogType", EIDSSDialogType.Warning},
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)
                }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams);
            var dialogResult = result as DialogReturnResult;
            if (dialogResult?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                //search timed out, narrow search criteria
                source?.Cancel();
                source = new CancellationTokenSource();
                token = source.Token;
                expandSearchCriteria = true;
                await SetButtonStates();
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadData(LoadDataArgs args)
        {
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;
                    showSearchResults = true;

                    var request = new AggregateReportSearchRequestModel
                    {
                        ReportID = Model.SearchCriteria.ReportID,
                        TimeIntervalTypeID = Model.SearchCriteria.TimeIntervalTypeID,
                        StartDate = Model.SearchCriteria.StartDate,
                        EndDate = Model.SearchCriteria.EndDate,
                        OrganizationID = Model.SearchCriteria.OrganizationID,
                        AdministrativeUnitTypeID = Model.SearchCriteria.AdministrativeUnitTypeID,
                        AggregateReportTypeID = (long)AggregateDiseaseReportTypes.VeterinaryAggregateActionReport
                    };

                    //Get lowest administrative level for location
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.AdministrativeUnitID = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.AdministrativeUnitID = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.AdministrativeUnitID = Model.SearchLocationViewModel.AdminLevel1Value.Value;

                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                           (long)SiteTypes.ThirdLevel;
                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    // sorting
                    if (args.Sorts is not null && args.Sorts.Any())
                    {
                        var sortDescriptor = args.Sorts.First();
                        request.SortColumn = sortDescriptor.Property;
                        request.SortOrder = sortDescriptor.SortOrder.GetValueOrDefault()
                            .ToString().Replace("Ascending", "ASC").Replace("Descending", "DESC");
                    }
                    else
                    {
                        request.SortColumn = "ReportID";
                        request.SortOrder = SortConstants.Descending;
                    }

                    // paging
                    if (args.Skip is > 0)
                    {
                        request.Page = (args.Skip.Value / Grid.PageSize) + 1;
                    }
                    else
                    {
                        request.Page = 1;
                    }

                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    Model.SearchCriteria.Page = request.Page;
                    Model.SearchCriteria.PageSize = request.PageSize;

                    if (_isRecordSelected == false)
                    {
                        var result = await AggregateReportClient.GetAggregateReportList(request, token);
                        if (source.IsCancellationRequested == false)
                        {
                            Model.SearchResults = result;
                            count = Model.SearchResults.FirstOrDefault() != null
                                ? Model.SearchResults.First().RecordCount.GetValueOrDefault()
                                : 0;
                        }
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch timeout exception
                    if (e.Message.Contains("Timeout"))
                    {
                        if (source?.IsCancellationRequested == false) source?.Cancel();
                        await ShowNarrowSearchCriteriaDialog();
                    }
                    else
                    {
                        throw;
                    }
                }
                finally
                {
                    isLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            else
            {
                Model.SearchResults = new List<AggregateReportGetListViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        protected async Task HandleValidSearchSubmit(SearchAggregateActionsReportPageViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                await SetButtonStates();

                if (Grid != null) await Grid.Reload();
            }
            else
            {
                //no search criteria entered
                searchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task CancelSearchClicked()
        {
            await CancelSearchAsync();
        }

        /// <summary>
        /// </summary>
        protected async Task ResetSearch()
        {
            //initialize new model with defaults
            InitializeModel();

            //set grid for not loaded
            isLoading = false;

            //reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            expandSearchCriteria = true;
            showSearchResults = false;
            await SetButtonStates();
        }

        protected async Task OpenEdit(AggregateReportGetListViewModel model)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchPerformedIndicatorKey,
                true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchModelKey, Model);

            shouldRender = false;
            const string path = "Veterinary/AggregateActionsReport/Details";
            var query = $"?id={model.ReportKey}";
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OpenAdd()
        {
            // persist search results before navigation
            if (Model.SearchResults != null)
                await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchPerformedIndicatorKey,
                    true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchModelKey, Model);

            var userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);
            if (userPermissions.Create)
            {
                shouldRender = false;
                const string path = "Veterinary/AggregateActionsReport/Details";
                var uri = $"{NavManager.BaseUri}{path}";

                NavManager.NavigateTo(uri, true);
            }
            else
            {
                await InsufficientPermissions();
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        protected async Task SendReportLink(AggregateReportGetListViewModel model)
        {
            try
            {
                _isRecordSelected = true;

                switch (Mode)
                {
                    case SearchModeEnum.Import:
                        {
                            if (CallbackUrl.EndsWith('/')) CallbackUrl = CallbackUrl[..^1];

                            var url = CallbackUrl + $"?Id={model.ReportID}";

                            if (CallbackKey != null) url += "&callbackkey=" + CallbackKey;
                            NavManager.NavigateTo(url, true);
                            break;
                        }
                    case SearchModeEnum.Select:
                        DiagService.Close(Model.SearchResults.First(x => x.ReportID == model.ReportID));
                        break;
                    default:
                        {
                            // persist search results before navigation
                            await BrowserStorage.SetAsync(
                                SearchPersistenceKeys.VeterinaryAggregateActionsSearchPerformedIndicatorKey, true);
                            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryAggregateActionsSearchModelKey,
                                Model);

                            shouldRender = false;
                            const string path = "Veterinary/AggregateActionsReport/Details";
                            var query = $"?id={model.ReportKey}&isReadOnly=true";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                            break;
                        }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task GetTimeIntervalsAsync(LoadDataArgs args)
        {
            TimeIntervals = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.StatisticalPeriodType, null);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = TimeIntervals.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                TimeIntervals = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetAdministrativeLevelsAsync(LoadDataArgs args)
        {
            AdministrativeLevels = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.StatisticalAreaType, null);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = AdministrativeLevels.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                AdministrativeLevels = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Private Methods

        private async Task SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.Permissions.Create) disableAddButton = true;

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task SetDefaults()
        {
            // aggregate setting defaults
            var request = new AggregateSettingsGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                IdfCustomizationPackage = Convert.ToInt64(GlobalConstants.CustomizationPackageID),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "idfsAggrCaseType",
                SortOrder = SortConstants.Ascending
            };
            AggregateSettingsViewModel defaultSettings = null;
            var aggregateSettings =
                await AggregateSettingsClient.GetAggregateSettingsList(request).ConfigureAwait(false);
            if (aggregateSettings != null && aggregateSettings.Any())
                defaultSettings = aggregateSettings.FirstOrDefault(x =>
                    x.idfsAggrCaseType == Convert.ToInt64(AggregateValue.VeterinaryAction));

            Model.SearchCriteria.TimeIntervalTypeID = defaultSettings?.idfsStatisticPeriodType;
            Model.SearchCriteria.AdministrativeUnitTypeID = defaultSettings?.idfsStatisticAreaType;

            var userPreferences =
                ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RegionId
                : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RayonId
                : null;
        }

        /// <summary>
        /// </summary>
        private void InitializeModel()
        {
            // bottom admin level
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            Model = new SearchAggregateActionsReportPageViewModel
            {
                Permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions),
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
        }

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        private bool HasCriteria(SearchAggregateActionsReportPageViewModel model)
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

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task PrintSearchResults()
        {
            if (Form.IsValid)
                try
                {
                    var nGridCount = Grid.Count;

                    ReportViewModel reportModel = new();

                    var reportTitle = CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human)
                        ? Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateActionReportPageHeading)
                        : Localizer.GetString(HeadingResourceKeyConstants
                            .VeterinaryActiveSurveillanceCampaignPageHeading);

                    // get lowest administrative level for location
                    long? locationId;
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        locationId = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        locationId = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        locationId = Model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        locationId = null;

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateActionReportPageHeading));
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);

                    reportModel.AddParameter("ReportTitle", reportTitle);
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("AggregateReportTypeID", AggregateValue.VeterinaryAction);
                    reportModel.AddParameter("ReportID", Model.SearchCriteria.ReportID);
                    reportModel.AddParameter("sortColumn", "ReportID");
                    reportModel.AddParameter("sortOrder", "DESC");
                    reportModel.AddParameter("pageSize", nGridCount.ToString());
                    reportModel.AddParameter("AdministrativeUnitTypeID", Model.SearchCriteria.AdministrativeUnitTypeID.ToString());
                    reportModel.AddParameter("TimeIntervalTypeID", Model.SearchCriteria.TimeIntervalTypeID.ToString());
                    if (Model.SearchCriteria.StartDate != null)
                        reportModel.AddParameter("StartDate", Model.SearchCriteria.StartDate.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.EndDate != null)
                        reportModel.AddParameter("EndDate", Model.SearchCriteria.EndDate.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("UserOrganizationID", authenticatedUser.Institution);
                    reportModel.AddParameter("SelectAllIndicator", Model.SearchCriteria.SelectAllIndicator.ToString());
                    reportModel.AddParameter("UserSiteID", authenticatedUser.SiteId);
                    reportModel.AddParameter("UserEmployeeID", authenticatedUser.PersonId);
                    reportModel.AddParameter("LegacyReportID", Model.SearchCriteria.LegacyReportID);
                    reportModel.AddParameter("AdministrativeUnitID",
                        locationId != null ? locationId.Value.ToString() : "");

                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel) ? "1" : "0");

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateActionReportPageHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "SearchForVeterinaryAggregateActionReport"}, {"Parameters", reportModel.Parameters}},
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

        #endregion
    }
}