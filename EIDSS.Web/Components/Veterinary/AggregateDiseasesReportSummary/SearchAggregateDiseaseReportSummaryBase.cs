using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
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
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Web.ViewModels.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.AggregateDiseasesReportSummary
{
    public class SearchAggregateDiseaseReportSummaryBase : AggregateDiseaseReportSummaryBaseComponent, IDisposable
    {
        #region Dependency Injection

        [Inject]
        private IAggregateReportClient AggregateDiseaseReportClient { get; set; }

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
        private ILogger<SearchAggregateDiseaseReportSummaryBase> Logger { get; set; }

        #endregion Dependency Injection

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        [Parameter]
        public AggregateDiseaseReportTypes ReportType { get; set; }

        [Parameter]
        public AggregateReportSearchViewModel SearchModel { get; set; }

        #endregion Parameters

        #region Protected and Public Fields

        protected RadzenDataGrid<AggregateReportGetListViewModel> _grid;
        protected RadzenAccordion _radAccordion;
        protected RadzenTemplateForm<AggregateReportSearchViewModel> _form;
        protected int count;
        protected int timeIntervalCount;
        protected int adminLevelCount;
        protected bool shouldRender = true;
        protected bool isLoading;

        protected bool showPrintButton;
        protected bool showCancelButton;
        protected bool showClearButton;
        protected bool showSearchButton;
        protected bool showSelectButton;
        protected bool showSelectAllButton;
        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool expandSearchResults;
        protected bool showCriteria;
        protected bool showResults;

        protected IEnumerable<AggregateReportGetListViewModel> SearchResults { get; set; }
        protected AggregateReportSearchViewModel model;

        protected IEnumerable<OrganizationGetListViewModel> organizations;

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private bool searchSubmitted;
        private CancellationTokenSource source;
        private CancellationToken token;
        private bool _selectAll;

        #endregion Private Fields and Properties

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            // Reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            // Wire up laboratory state container service
            AggregateDiseaseReportSummaryService.OnChange += StateHasChanged;

            //wire up dialog events
            //DiagService.OnClose += async (result) => await DialogClose(result);

            //initialize model
            await InitializeModelAsync();

            //set grid for not loaded
            isLoading = false;

            //set up the accordions
            showCriteria = true;
            expandSearchCriteria = true;
            showResults = false;
            SetButtonStates();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (model.Permissions.Read)
                {
                    if (AggregateDiseaseReportSummaryService.SelectedReports == null)
                        AggregateDiseaseReportSummaryService.SelectedReports = new List<AggregateReportGetListViewModel>();
                }
                else
                {
                    var buttons = new List<DialogButton>();
                    var okButton = new DialogButton()
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                        ButtonType = DialogButtonType.OK
                    };
                    buttons.Add(okButton);
                    var dialogParams = new Dictionary<string, object>
                    {
                        { nameof(EIDSSDialog.DialogButtons), buttons },
                        { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage) }
                    };
                    await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
                }
            }
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();

                //DiagService.OnClose -= async (result) => await DialogClose(result);
            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion Lifecycle Methods

        #region Protected Methods and Delegates

        protected async Task RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            model.SearchLocationViewModel = locationViewModel;
            await GetOrganizationsByAdministrativeLevelIdAsync(locationViewModel);
        }

        protected async Task PrintSearchResults()
        {
            if (_form.IsValid)
            {
                try
                {
                    ReportViewModel reportModel = new();

                    // get lowest administrative level for location
                    long? LocationID = null;
                    if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        LocationID = model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        LocationID = model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        LocationID = model.SearchLocationViewModel.AdminLevel1Value.Value;

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LanguageID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants
                            .VeterinaryAggregateDiseaseReportSummarySearchHeading)); // "Weekly Reporting List");
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "SearchForPersonRecord"}, {"Parameters", reportModel.Parameters}},
                        new DialogOptions
                        {
                            Style = EIDSSConstants.ReportSessionTypeConstants.HumanActiveSurveillanceSession,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1050px"
                        });
                }
                catch (Exception ex)
                {
                    Logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        protected async Task ResetSearchAsync()
        {
            //initialize new model with defaults
            await InitializeModelAsync();

            //set grid for not loaded
            isLoading = false;

            //reset the cancellation token
            //source = new();
            //token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            showCriteria = true;
            expandSearchCriteria = true;
            expandAdvancedSearchCriteria = false;
            expandSearchResults = false;
            showResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearch()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var options = new DialogOptions()
                {
                    Height = "auto"
                };

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    DiagService.Close();

                    await ResetSearchAsync();
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, null);
            }
        }

        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search criteria toggle
                case 0:

                    if (expandSearchResults && expandSearchCriteria == false)
                    {
                        expandSearchResults = !expandSearchResults;
                    }
                    expandSearchCriteria = !expandSearchCriteria;
                    break;

                //search results toggle
                case 1:

                    expandSearchResults = !expandSearchResults;
                    break;

                default:
                    break;
            }
            SetButtonStates();
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var options = new DialogOptions()
                {
                    Height = "auto"
                };

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogName", "NarrowSearch");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString("Search timed out, try narrowing your search criteria."));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);
                if (result is DialogReturnResult dialogResult)
                {
                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
                    {
                        //search timed out, narrow search criteria
                        source?.Cancel();
                        showResults = false;
                        expandSearchResults = false;
                        showCriteria = true;
                        expandSearchCriteria = true;
                        SetButtonStates();
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "An error occurred when on narrow search dialog.");
            }
        }

        protected async Task DialogClose(dynamic result)
        {
            if (result is DialogReturnResult dialogResult)
            {
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    await ResetSearchAsync();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                {
                    //cancel search but user said no
                    source?.Cancel();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoPrint")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoCriteria")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    showResults = false;
                    expandSearchResults = false;
                    showCriteria = true;
                    expandSearchCriteria = true;
                    SetButtonStates();
                }
            }
            else
            {
                source?.Dispose();
            }

            SetButtonStates();
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;

                    var request = new AggregateReportSearchRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        AggregateReportTypeID = Convert.ToInt64(ReportType == AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport ? AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport : AggregateDiseaseReportTypes.VeterinaryAggregateActionReport),
                        TimeIntervalTypeID = model.SearchCriteria.TimeIntervalTypeID,
                        AdministrativeUnitTypeID = model.SearchCriteria.AdministrativeUnitTypeID,
                        ReportID = model.SearchCriteria.ReportID,
                        StartDate = model.SearchCriteria.StartDate,
                        EndDate = model.SearchCriteria.EndDate,
                        OrganizationID = model.SearchCriteria.OrganizationID,
                        ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel),
                        UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                        UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                        UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId)
                    };

                    //paging
                    if (args.Skip is > 0)
                    {
                        request.Page = (args.Skip.Value / _grid.PageSize) + 1;
                    }
                    else
                    {
                        request.Page = 1;
                    }

                    if (_selectAll)
                    {
                        request.PageSize = args.Top ?? 10;
                    }
                    else
                    {
                        request.PageSize = _grid.PageSize != 0 ? _grid.PageSize : 10;
                    }

                    //sorting
                    if (args.Sorts is not null && args.Sorts.Any())
                    {
                        request.SortColumn = args.Sorts.FirstOrDefault()?.Property;
                        request.SortOrder = args.Sorts.FirstOrDefault()
                            ?.SortOrder?.ToString().Replace("Ascending", SortConstants.Ascending).Replace("Descending", SortConstants.Descending);
                    }
                    else
                    {
                        request.SortColumn = "ReportID";
                        request.SortOrder = SortConstants.Descending;
                    }

                    //Get lowest administrative level.
                    if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel3Value;
                    else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel2Value;
                    else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel1Value;
                    else
                        request.AdministrativeUnitID = null;

                    var result = await AggregateDiseaseReportClient.GetAggregateReportList(request, token);
                    if (source?.IsCancellationRequested == false)
                    {
                        if (!_selectAll) SearchResults = result;
                        AggregateDiseaseReportSummaryService.SearchReports = result;
                        count = (SearchResults != null && SearchResults.Any()) ? SearchResults.First().RecordCount.GetValueOrDefault() : 0;
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
                //initialize the grid so that it displays 'No records message'
                SearchResults = new List<AggregateReportGetListViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(AggregateReportSearchViewModel formModel)
        {
            if (_form.IsValid)
            {
                searchSubmitted = true;
                showResults = true;
                expandSearchResults = true;
                expandSearchCriteria = false;
                expandAdvancedSearchCriteria = false;
                showCriteria = false;
                SetButtonStates();

                if (_grid != null)
                {
                    await _grid.Reload();
                }
            }
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                //TODO - display the validation Errors on the dialog?
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task GetOrganizationsByAdministrativeLevelIdAsync(LocationViewModel locationModel)
        {
            if (organizations == null || !organizations.Any())
            {
                // Get a filtered list of organizations that corresponds to the selected values in “AdminLevel1”, and/or “AdminLevel2”, and /or “AdminLevel3” and/or “AdminLevelX” fields.
                long? administrativeLevelId = null;

                //Get lowest administrative level.
                if (locationModel.AdminLevel3Value != null)
                    administrativeLevelId = locationModel.AdminLevel3Value;
                else if (locationModel.AdminLevel2Value != null)
                    administrativeLevelId = locationModel.AdminLevel2Value;
                else if (locationModel.AdminLevel1Value != null)
                    administrativeLevelId = locationModel.AdminLevel1Value;

                var request = new OrganizationGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "AbbreviatedName",
                    SortOrder = "asc",
                    AdministrativeLevelID = administrativeLevelId
                };
                var list = await OrganizationClient.GetOrganizationList(request);
                organizations = list.AsODataEnumerable();
            }
        }

        protected async Task ReloadLocationControl(object value)
        {
            if (value != null)
            {
                await FillConfigurationSettingsAsync((long)value, model);
            }
        }

        protected void OnSelectReports()
        {
            DiagService.Close(new DialogReturnResult() { ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.SelectButton) });
        }

        protected async Task OnSelectAll()
        {
            var loadArgs = new LoadDataArgs()
            {
                Skip = 0,
                Top = count
            };

            _selectAll = true;

            await LoadData(loadArgs).ConfigureAwait(false);

            AggregateDiseaseReportSummaryService.SelectedReports = AggregateDiseaseReportSummaryService.SearchReports;
            DiagService.Close(new DialogReturnResult() { ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.SelectAllButton) });
        }

        #endregion Protected Methods and Delegates

        #region Private Methods

        private void SetButtonStates()
        {
            if (expandSearchResults)
            {
                showCancelButton = true;
                showSelectButton = true;
                showSelectAllButton = true;
                showClearButton = true;
                showSearchButton = true;
            }
            else
            {
                showCancelButton = true;
                showSelectButton = false;
                showSelectAllButton = false;
                showClearButton = true;
                showSearchButton = true;
            }
        }

        private async Task InitializeModelAsync()
        {
            if (SearchModel != null)
            {
                model = SearchModel;
            }
            else
            {
                model = new AggregateReportSearchViewModel();
                if (ReportType == AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport)
                    model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateDiseaseReports);
                else
                    model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateActions);
                model.RecordSelectionIndicator = true;
                model.SearchCriteria = new();
                model.SearchCriteria.SortColumn = "ReportID";
                model.SearchCriteria.SortOrder = "desc";
                model.SearchCriteria.StartDate = null;
                model.SearchCriteria.EndDate = null;
                model.SearchLocationViewModel = new();
                //model.SearchLocationViewModel = new()
                //{
                //    IsHorizontalLayout = true,
                //    EnableAdminLevel0 = false,
                //    EnableAdminLevel1 = true,
                //    ShowAdminLevel0 = true,
                //    ShowAdminLevel1 = true,
                //    ShowAdminLevel2 = true,
                //    ShowAdminLevel3 = true,
                //    ShowAdminLevel4 = false,
                //    ShowAdminLevel5 = false,
                //    ShowAdminLevel6 = false,
                //    ShowSettlement = true,
                //    ShowSettlementType = true,
                //    ShowStreet = false,
                //    ShowBuilding = false,
                //    ShowApartment = false,
                //    ShowElevation = false,
                //    ShowHouse = false,
                //    ShowLatitude = false,
                //    ShowLongitude = false,
                //    ShowMap = false,
                //    ShowBuildingHouseApartmentGroup = false,
                //    ShowPostalCode = false,
                //    ShowCoordinates = false,
                //    IsDbRequiredAdminLevel0 = false,
                //    IsDbRequiredAdminLevel1 = false,
                //    IsDbRequiredSettlement = false,
                //    IsDbRequiredSettlementType = false,
                //    RequiredWhenTrue = false,
                //    AdminLevel0Value = Convert.ToInt64(Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                //};
            }

            await FillConfigurationSettingsAsync(null, model);

            if (AggregateDiseaseReportSummaryService.SearchReports != null)
            {
                isLoading = true;
                SearchResults = AggregateDiseaseReportSummaryService.SearchReports;
                count = SearchResults.FirstOrDefault() != null ? SearchResults.First().RecordCount.Value : 0;
                showCriteria = true;
                expandSearchCriteria = true;
                expandSearchResults = true;
                SetButtonStates();
            }
        }

        private async Task FillConfigurationSettingsAsync(long? AdministrativeUnitType, AggregateReportSearchViewModel model)
        {
            LocationViewModel searchLocationViewModel = new LocationViewModel();

            var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                model.SearchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;
                //model.SearchLocationViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
                //model.SearchLocationViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;

                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
                model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;
                model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;

                // Location Control
                searchLocationViewModel.IsHorizontalLayout = true;
                searchLocationViewModel.EnableAdminLevel0 = false;
                searchLocationViewModel.EnableAdminLevel1 = true;
                searchLocationViewModel.ShowAdminLevel0 = true;
                searchLocationViewModel.ShowAdminLevel1 = true;       //Region
                searchLocationViewModel.ShowAdminLevel2 = true;       //Rayon
                searchLocationViewModel.ShowAdminLevel3 = true;
                searchLocationViewModel.ShowAdminLevel4 = false;
                searchLocationViewModel.ShowAdminLevel5 = false;
                searchLocationViewModel.ShowAdminLevel6 = false;
                searchLocationViewModel.ShowSettlement = true;
                searchLocationViewModel.ShowSettlementType = false;
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
                searchLocationViewModel.IsDbRequiredAdminLevel0 = false;
                searchLocationViewModel.IsDbRequiredAdminLevel1 = false;
                searchLocationViewModel.IsDbRequiredAdminLevel2 = false;
                searchLocationViewModel.IsDbRequiredAdminLevel3 = false;
                searchLocationViewModel.IsDbRequiredSettlement = false;
                searchLocationViewModel.IsDbRequiredSettlementType = false;
                searchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                switch (model.SearchCriteria.AdministrativeUnitTypeID)
                {
                    //case (long)GISAdministrativeLevels.AdminLevel0:
                    case (long)AdministrativeUnitTypes.Country:
                        //searchlocationViewModel.ShowAdminLevel0 = true;
                        //searchlocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.EnableAdminLevel1 = false;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.AdminLevel1Value = null;
                        searchLocationViewModel.AdminLevel2Value = null;
                        searchLocationViewModel.AdminLevel3Value = null;
                        searchLocationViewModel.AdminLevel1List = null;
                        searchLocationViewModel.DisableAtElementLevel = "AdminLevel1Value";
                        model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel0Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    //case (long)GISAdministrativeLevels.AdminLevel1:
                    case (long)AdministrativeUnitTypes.Region:
                        searchLocationViewModel.AdminLevel1Value = model.SearchLocationViewModel.AdminLevel1Value;
                        //searchlocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.AdminLevel2Value = null;
                        searchLocationViewModel.AdminLevel3Value = null;
                        searchLocationViewModel.AdminLevel2List = null;
                        searchLocationViewModel.DisableAtElementLevel = "AdminLevel2Value";
                        model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel1Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    //case (long)GISAdministrativeLevels.AdminLevel2:
                    case (long)AdministrativeUnitTypes.Rayon:
                        searchLocationViewModel.AdminLevel1Value = model.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.SearchLocationViewModel.AdminLevel2Value;
                        //searchlocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        //searchlocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.AdminLevel3Value = null;
                        searchLocationViewModel.AdminLevel3List = null;
                        searchLocationViewModel.DisableAtElementLevel = "AdminLevel3Value";
                        model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel2Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    //case (long)GISAdministrativeUnitTypes.Settlement:
                    case (long)AdministrativeUnitTypes.Settlement:
                        searchLocationViewModel.AdminLevel1Value = model.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.SearchLocationViewModel.AdminLevel2Value;
                        //searchlocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        //searchlocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;

                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;

                        searchLocationViewModel.ShowSettlementType = false;
                        if (model.SearchLocationViewModel.AdminLevel3Value != null)
                        {
                            model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel3Value;
                        }
                        else
                            model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel2Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    default:
                        searchLocationViewModel.AdminLevel1Value = model.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.SearchLocationViewModel.AdminLevel2Value;
                        //searchlocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        //searchlocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;

                        searchLocationViewModel.ShowSettlementType = false;
                        model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel3Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = false;
                        await GetOrganizationsByAdministrativeLevelIdAsync(searchLocationViewModel);
                        break;
                }

                model.SearchLocationViewModel = searchLocationViewModel;
            }
        }

        #endregion Private Methods
    }
}