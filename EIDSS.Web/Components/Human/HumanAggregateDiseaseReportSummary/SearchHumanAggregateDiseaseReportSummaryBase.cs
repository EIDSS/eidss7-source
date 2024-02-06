using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
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
using EIDSS.Web.ViewModels;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Web.ViewModels.CrossCutting;

namespace EIDSS.Web.Components.Human.HumanAggregateDiseaseReportSummary
{
    public class SearchHumanAggregateDiseaseReportSummaryBase : HumanAggregateDiseaseReportSummaryBaseComponent, IDisposable
    {
        #region Dependency Injection

        [Inject]
        private IAggregateReportClient AggregateReportClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        private ILogger<SearchHumanAggregateDiseaseReportSummaryBase> Logger { get; set; }

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

        protected RadzenDataGrid<AggregateReportGetListViewModel> Grid;
        protected RadzenTemplateForm<AggregateReportSearchViewModel> Form;
        protected int Count;
        protected int TimeIntervalCount;
        protected int AdminLevelCount;
        protected bool shouldRender = true;
        protected bool IsLoading;

        //protected bool disableAddButton;
        //protected bool disableEditButton;
        protected bool ShowPrintButton;

        protected bool ShowCancelButton;
        protected bool ShowClearButton;
        protected bool ShowSearchButton;
        protected bool ShowSelectButton;
        protected bool ShowSelectAllButton;
        protected bool ExpandSearchCriteria;
        protected bool ExpandAdvancedSearchCriteria;
        protected bool ExpandSearchResults;
        protected bool ShowCriteria;
        protected bool ShowResults;
        protected IEnumerable<AggregateReportGetListViewModel> SearchResults { get; set; }
        protected AggregateReportSearchViewModel Model;
        protected IEnumerable<OrganizationGetListViewModel> Organizations;

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private bool _searchSubmitted;
        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _selectAll;

        #endregion Private Fields and Properties

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            // Wire up laboratory state container service
            AggregateDiseaseReportSummaryService.OnChange += StateHasChanged;

            //initialize model
            await InitializeModelAsync();

            //set grid for not loaded
            IsLoading = false;

            //set up the accordions
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            ShowResults = false;
            SetButtonStates();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (Model.Permissions.Read)
                {
                    AggregateDiseaseReportSummaryService.SelectedReports ??= new List<AggregateReportGetListViewModel>();
                }
                else
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
            //source?.Cancel();
            //source?.Dispose();
        }

        #endregion Lifecycle Methods

        #region Protected Methods and Delegates

        protected async Task RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            Model.SearchLocationViewModel = locationViewModel;
            await GetOrganizationsByAdministrativeLevelIdAsync(locationViewModel);
        }

        protected async Task PrintSearchResults()
        {
            if (Form.IsValid)
            {
                try
                {
                    ReportViewModel reportModel = new();

                    // get lowest administrative level for location
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                    {
                    }
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                    {
                    }
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                    {
                    }

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

        protected async Task ResetSearch()
        {
            //initialize new model with defaults
            await InitializeModelAsync();

            //set grid for not loaded
            IsLoading = false;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            //set up the accordions and buttons
            _searchSubmitted = false;
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            ExpandAdvancedSearchCriteria = false;
            ExpandSearchResults = false;
            ShowResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearch()
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

            var options = new DialogOptions
            {
                Height = "auto;"
            };

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                DiagService.Close(new DialogReturnResult { ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.YesButton) });
            }
            else
            {
                //cancel search but user said no so leave everything alone and cancel thread
                _source?.Cancel();
            }
        }

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

        protected async Task LoadData(LoadDataArgs args)
        {
            if (_searchSubmitted)
            {
                try
                {
                    IsLoading = true;

                    var request = new AggregateReportSearchRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        AggregateReportTypeID = Convert.ToInt64(AggregateDiseaseReportTypes.HumanAggregateDiseaseReport)
                    };

                    //paging
                    if (args.Skip is > 0)
                    {
                        request.Page = args.Skip.Value / Grid.PageSize + 1;
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
                        request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    }

                    //sorting
                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "ReportID";
                    request.SortOrder = args.Sorts != null && args.Sorts.Any() ? args.Sorts.FirstOrDefault()?.SortOrder?.ToString().Replace("Ascending", SortConstants.Ascending).Replace("Descending", SortConstants.Descending) : SortConstants.Descending;

                    request.TimeIntervalTypeID = Model.SearchCriteria.TimeIntervalTypeID;
                    request.AdministrativeUnitTypeID = Model.SearchCriteria.AdministrativeUnitTypeID;

                    //Get lowest administrative level.
                    if (Model.SearchLocationViewModel.AdminLevel3Value != null)
                        request.AdministrativeUnitID = string.IsNullOrEmpty(Model.SearchLocationViewModel.AdminLevel3Value.ToString()) ? null : Convert.ToInt64(Model.SearchLocationViewModel.AdminLevel3Value);
                    else if (Model.SearchLocationViewModel.AdminLevel2Value != null)
                        request.AdministrativeUnitID = string.IsNullOrEmpty(Model.SearchLocationViewModel.AdminLevel2Value.ToString()) ? null : Convert.ToInt64(Model.SearchLocationViewModel.AdminLevel2Value);
                    else if (Model.SearchLocationViewModel.AdminLevel1Value != null)
                        request.AdministrativeUnitID = string.IsNullOrEmpty(Model.SearchLocationViewModel.AdminLevel1Value.ToString()) ? null : Convert.ToInt64(Model.SearchLocationViewModel.AdminLevel1Value);
                    else
                        request.AdministrativeUnitID = null;

                    request.ReportID = Model.SearchCriteria.ReportID;
                    request.StartDate = Model.SearchCriteria.StartDate;
                    request.EndDate = Model.SearchCriteria.EndDate;
                    request.OrganizationID = Model.SearchCriteria.OrganizationID;

                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                           (long)SiteTypes.ThirdLevel;
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    var result = await AggregateReportClient.GetAggregateReportList(request, _token);

                    if (_source?.IsCancellationRequested == false)
                    {
                        if (!_selectAll) SearchResults = result;
                        AggregateDiseaseReportSummaryService.SearchReports = result;
                        Count = SearchResults != null && SearchResults.Any() ? SearchResults.First().RecordCount.GetValueOrDefault() : 0;
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch cancellation or timeout exception
                    if (e.Message.Contains("Timeout"))
                    {
                        if (_source?.IsCancellationRequested == false) _source?.Cancel();
                        await ShowNarrowSearchCriteriaDialog();
                    }
                    else
                    {
                        throw;
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

        protected async Task HandleValidSearchSubmit(AggregateReportSearchViewModel model)
        {
            if (Form.IsValid)
            {
                _searchSubmitted = true;
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
                _searchSubmitted = false;
            }
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            //TODO - display the validation Errors on the dialog?
            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage)
                }
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

        protected async Task GetOrganizationsByAdministrativeLevelIdAsync(LocationViewModel model)
        {
            // Get a filtered list of organizations that corresponds to the selected values in “AdminLevel1”, and/or “AdminLevel2”, and /or “AdminLevel3” and/or “AdminLevelX” fields.
            long? administrativeLevelId = null;

            //Get lowest administrative level.
            if (model.AdminLevel3Value != null)
                administrativeLevelId = string.IsNullOrEmpty(model.AdminLevel3Value.ToString()) ? null : Convert.ToInt64(model.AdminLevel3Value);
            else if (model.AdminLevel2Value != null)
                administrativeLevelId = string.IsNullOrEmpty(model.AdminLevel2Value.ToString()) ? null : Convert.ToInt64(model.AdminLevel2Value);
            else if (model.AdminLevel1Value != null)
                administrativeLevelId = string.IsNullOrEmpty(model.AdminLevel1Value.ToString()) ? null : Convert.ToInt64(model.AdminLevel1Value);

            var request = new OrganizationGetRequestModel()
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

        protected async Task ReloadLocationControl(object value)
        {
            if (value != null)
            {
                await FillConfigurationSettings(long.Parse(value.ToString() ?? string.Empty), Model);
            }
        }

        protected void OnSelectReports()
        {
            DiagService.Close(new DialogReturnResult { ButtonResultText = Localizer.GetString(ButtonResourceKeyConstants.SelectButton) });
        }

        protected async Task OnSelectAll()
        {
            var loadArgs = new LoadDataArgs
            {
                Skip = 0,
                Top = Count
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
            if (ExpandSearchResults)
            {
                ShowCancelButton = true;
                ShowSelectButton = true;
                ShowSelectAllButton = true;
                ShowClearButton = true;
                ShowSearchButton = true;
            }
            else
            {
                ShowCancelButton = true;
                ShowSelectButton = false;
                ShowSelectAllButton = false;
                ShowClearButton = true;
                ShowSearchButton = true;
            }
        }

        private async Task InitializeModelAsync()
        {
            if (SearchModel != null)
            {
                Model = SearchModel;
            }
            else
            {
                Model = new AggregateReportSearchViewModel
                {
                    Permissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports),
                    RecordSelectionIndicator = true,
                    SearchCriteria = new AggregateReportSearchRequestModel
                    {
                        SortColumn = "ReportID",
                        SortOrder = SortConstants.Descending,
                        StartDate = null,
                        EndDate = null
                    },
                    SearchLocationViewModel = new LocationViewModel()
                };
            }

            await FillConfigurationSettings(null, Model);

            if (AggregateDiseaseReportSummaryService.SearchReports != null)
            {
                IsLoading = true;
                SearchResults = AggregateDiseaseReportSummaryService.SearchReports;
                var recordCount = SearchResults.First().RecordCount;
                if (recordCount != null)
                    Count = SearchResults.FirstOrDefault() != null ? recordCount.Value : 0;
                ShowCriteria = true;
                ExpandSearchCriteria = true;
                ExpandSearchResults = true;
                SetButtonStates();
            }
        }

        private async Task FillConfigurationSettings(long? administrativeUnitType, AggregateReportSearchViewModel model)
        {
            var searchLocationViewModel = new LocationViewModel();

            var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                model.SearchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
                model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;

                model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;

                //Set Other Admin Level Values - if needed

                //var orgControl = "OrganizationSelect";

                // Location Control
                searchLocationViewModel.IsHorizontalLayout = true;
                searchLocationViewModel.EnableAdminLevel0 = false;
                searchLocationViewModel.EnableAdminLevel1 = true;
                searchLocationViewModel.ShowAdminLevel0 = true;
                searchLocationViewModel.ShowAdminLevel1 = true;       
                searchLocationViewModel.ShowAdminLevel2 = true;       
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
                        searchLocationViewModel.ShowAdminLevel1 = true;
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
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;
                        searchLocationViewModel.ShowSettlementType = false;
                        model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel3Value ??
                                                                    model.SearchLocationViewModel.AdminLevel2Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = true;
                        break;

                    default:
                        searchLocationViewModel.AdminLevel1Value = model.SearchLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.SearchLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;
                        searchLocationViewModel.ShowSettlementType = false;
                        model.SearchCriteria.AdministrativeUnitID = model.SearchLocationViewModel.AdminLevel3Value;
                        model.SearchCriteria.OrganizationIDDisabledIndicator = false;
                        break;
                }

                model.SearchLocationViewModel = searchLocationViewModel;
            }
        }

        #endregion Private Methods
    }
}