#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Human.SearchActiveSurveillanceSession
{
    public class SearchHumanActiveSurveillanceSessionBase : SearchComponentBase<ActiveSurveillanceSessionViewModel>, IDisposable
    {
        #region Grid Reorder Column Chooser
     
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public GridExtensionBase GridExtension { get; set; }

        #endregion

        #region Dependency Injection

        [Inject]
        private IHumanActiveSurveillanceSessionClient HumanActiveSurveillanceSession { get; set; }
        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }
        [Inject]
        private ILogger<SearchHumanActiveSurveillanceSessionBase> Logger { get; set; }
        [Inject]
        ProtectedSessionStorage ProtectedSessionStore { get; set; }
        [Inject]
        protected ActiveSurveillanceSessionStateContainer StateContainer { get; set; }

        #endregion Dependency Injection

        #region Parameters

        #endregion Parameters

        #region Protected and Public Fields

        protected RadzenDataGrid<ActiveSurveillanceSessionResponseModel> Grid;
        protected RadzenTemplateForm<ActiveSurveillanceSessionViewModel> Form;
        protected int Count;
        protected int DiseaseCount;
        protected bool IsLoading;
        protected bool ShowCancelButton;
        protected bool ShowClearButton;
        protected bool ShowSearchButton;
        protected bool ShowPrintButton;
        protected bool ShowAddButton;
        protected bool ExpandSearchCriteria;
        protected bool ExpandAdvancedSearchCriteria;
        protected bool ExpandSearchResults;
        protected bool ShowCriteria;
        protected bool ShowResults;
        protected ActiveSurveillanceSessionViewModel Model;
        protected IEnumerable<BaseReferenceViewModel> SessionStatuses;
        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases;
        protected LocationView LocationViewComponent;
        
        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private bool _searchSubmitted;
        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _isRecordSelected;

        #endregion Private Fields and Properties

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            LoadingComponentIndicator = true;

            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            //for Grid ColumnReorder
            GridExtension = new GridExtensionBase();
            //var t = new Task(() => GridColumnLoad("ActiveSurveillanceSessionSearch")).Wait(1000);

            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            //wire up dialog events
            DiagService.OnClose += async result => await DialogClose(result);

            //initialize model
            await InitializeModel();

            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RayonId
                : null;

            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.HumanActiveSurveillanceSessionSeachPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<ActiveSurveillanceSessionViewModel>(SearchPersistenceKeys.HumanActiveSurveillanceSessionSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    IsLoading = true;

                    Model = searchModel;
                    Model.SearchResults = searchModel.SearchResults;
                    StateContainer.SetActiveSurveillanceSessionViewModel(Model);
                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;

                    if (Model is {SearchResults: { }})
                    {
                        Count = (int) (Model.SearchResults.Any()
                            ? Model.SearchResults.First()?.RecordCount
                            : 0);

                        if (Grid is not null)
                            if (Model.SearchRequest.PageSize != null)
                                Grid.PageSize = Model.SearchRequest.PageSize != 0
                                    ? (int) Model.SearchRequest.PageSize
                                    : 10;
                    }
                    else
                        Model.SearchResults = new List<ActiveSurveillanceSessionResponseModel>();

                    // set up the accordions
                    ShowResults = true;
                    ShowCriteria = true;
                    ExpandSearchResults = true;
                    ExpandSearchCriteria = false;
                    ExpandAdvancedSearchCriteria = false;

                    IsLoading = false;
                }
            }
            else
            {
                //set grid for not loaded
                IsLoading = false;

                //set up the accordions
                ShowCriteria = true;
                ExpandSearchCriteria = true;
                ShowResults = false;
            }

            SetButtonStates();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                LoadingComponentIndicator = false;

                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            //source?.Cancel();
            _source?.Dispose();
            DiagService.OnClose -= async result => await DialogClose(result);;
        }

        #endregion Lifecycle Methods

        #region Protected Methods

        protected async Task PrintSearchResults()
        {
            if (Form.IsValid)
            {
                try
                {
                    var nGridCount = Grid.Count;

                    ReportViewModel reportModel = new();

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
                        Localizer.GetString(HeadingResourceKeyConstants.HumanActiveSurveillanceSessionPageHeading)); // "Weekly Reporting List"); 
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("PageSize", nGridCount.ToString());
                    //reportModel.AddParameter("Page", "1");

                    reportModel.AddParameter("DiseaseID", Model.SearchRequest.DiseaseID.ToString());
                    reportModel.AddParameter("UserSiteID", _tokenService.GetAuthenticatedUser().SiteId);
                    reportModel.AddParameter("UserEmployeeID", _tokenService.GetAuthenticatedUser().PersonId);
                    reportModel.AddParameter("SessionID", Model.SearchRequest.SessionID);
                    reportModel.AddParameter("LegacySessionID", Model.SearchRequest.LegacySessionID);
                    reportModel.AddParameter("CampaignKey", Model.SearchRequest.CampaignKey.ToString());
                    reportModel.AddParameter("SessionStatusTypeID", Model.SearchRequest.SessionStatusTypeID.ToString());
                    if (Model.SearchRequest.DateEnteredFrom != null)
                        reportModel.AddParameter("DateEnteredFrom", Model.SearchRequest.DateEnteredFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchRequest.DateEnteredTo != null)
                        reportModel.AddParameter("DateEnteredTo", Model.SearchRequest.DateEnteredTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("AdministrativeLevelID", locationId.ToString());
                    reportModel.AddParameter("UserOrganizationID", _tokenService.GetAuthenticatedUser().OfficeId.ToString());
                    reportModel.AddParameter("CampaignID", Model.SearchRequest.CampaignID);
                    
                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel) ? "1" : "0");

                    reportModel.AddParameter("SortColumn", "SessionID");
                    reportModel.AddParameter("SortOrder", SortConstants.Descending);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.HumanActiveSurveillanceSessionPageHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "SearchForHumanActiveSurveillanceSession"}, {"Parameters", reportModel.Parameters}},
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

                //advanced search toggle
                case 1:

                    if (ExpandSearchResults && ExpandAdvancedSearchCriteria == false)
                    {
                        ExpandSearchResults = !ExpandSearchResults;
                    }
                    ExpandAdvancedSearchCriteria = !ExpandAdvancedSearchCriteria;
                    break;

                //search results toggle
                case 2:

                    ExpandSearchResults = !ExpandSearchResults;
                    break;
            }
            SetButtonStates();
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
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
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

        protected async Task DialogClose(dynamic result)
        {
            if (result is DialogReturnResult dialogResult)
            {
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    _source?.Cancel();
                    await ResetSearch();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                {
                    //cancel search but user said no
                    _source?.Cancel();
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
                    _source?.Cancel();
                    _source = new CancellationTokenSource();
                    _token = _source.Token;
                    ShowResults = false;
                    ExpandSearchResults = false;
                    ShowCriteria = true;
                    ExpandSearchCriteria = true;
                    SetButtonStates();
                }
            }

            SetButtonStates();
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            if (_searchSubmitted)
            {
                try
                {
                    IsLoading = true;

                    var request = new ActiveSurveillanceSessionRequestModel
                    {
                        LanguageID = GetCurrentLanguage(),
                        CampaignKey = null,
                        SessionStatusTypeID = null,
                        DateEnteredFrom = null,
                        DateEnteredTo = null,
                        AdministrativeLevelID = null,
                        DiseaseID = null,
                        UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                        UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                        UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                        SessionID = StateContainer.Model.SearchRequest.SessionID
                    };

                    request.SessionStatusTypeID = StateContainer.Model.SearchRequest.SessionStatusTypeID;
                    request.AdministrativeLevelID = Common.GetLocationId(StateContainer.Model.SearchLocationViewModel); //Location Hierarchy
                    request.DiseaseID = StateContainer.Model.SearchRequest.DiseaseID;
                    request.DateEnteredFrom = StateContainer.Model.SearchRequest.DateEnteredFrom;
                    request.DateEnteredTo = StateContainer.Model.SearchRequest.DateEnteredTo;
                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel;

                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy.Split(" ")[0] : "SessionID";
                    if (args.OrderBy != null)
                        request.SortOrder = args.Sorts.FirstOrDefault() != null
                            ? args.OrderBy.Split(" ")[1]
                            : SortConstants.Descending;

                    if (args.Skip is > 0)
                    {
                        request.PageNumber = args.Skip.Value / Grid.PageSize + 1;
                    }
                    else
                    {
                        request.PageNumber = 1;
                    }
                    
                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    Model.SearchRequest.PageSize = request.PageSize;

                    if (_isRecordSelected == false)
                    {
                        var result =
                            await HumanActiveSurveillanceSession.GetActiveSurveillanceSessionListAsync(request, _token);
                        if (_source?.IsCancellationRequested == false)
                        {
                            Model.SearchResults = result;
                            var recordCount = 0;

                            if (Model.SearchResults.Any())
                            {
                                var i = Model.SearchResults.First().RecordCount;
                                if (i != null)
                                    recordCount = (int) i;
                            }

                            Count = Model.SearchResults.FirstOrDefault() != null
                                ? recordCount
                                : 0;
                        }
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch cancellation or timeout exception
                    if (_source?.IsCancellationRequested == true)
                    {
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
                Model.SearchResults = new List<ActiveSurveillanceSessionResponseModel>();
                Count = 0;
                IsLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(ActiveSurveillanceSessionViewModel model)
        {
            if (Form.IsValid)
            {
                if (Form.EditContext.IsModified() || model.SearchRequest.DateEnteredFrom != null)
                {
                    var userPermissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
                    if (!userPermissions.Read)
                        await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                    model.SearchRequest.StoredSearchIndicator = true;
                    StateContainer.SetActiveSurveillanceSessionViewModel(model);
                    await ProtectedSessionStore.SetAsync("ActiveSurveillanceSessionRequestModel", model.SearchRequest);

                    _searchSubmitted = true;
                    ShowResults = true;
                    ExpandSearchResults = true;
                    ExpandSearchCriteria = false;
                    ExpandAdvancedSearchCriteria = false;
                    ShowCriteria = true;

                    SetButtonStates();

                    if (Grid != null)
                    {
                        await Grid.Reload();
                    }
                }
                else
                {
                    //no search criteria entered - display the EIDSS dialog component
                    _searchSubmitted = false;
                    await ShowNoSearchCriteriaDialog();
                }
            }
        }

        protected Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            return Task.CompletedTask;
        }

        protected async Task ResetSearch()
        {
            //initialize new model with defaults
            await InitializeModel();

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

            // Since Date Entered From and Date Entered To are not required fields
            // so Clear button shall allow to clear the default dates.
            Model.SearchRequest.DateEnteredTo = null;
            Model.SearchRequest.DateEnteredFrom = null;
        }

        protected async Task GotoCreate()
        {
            // persist search results before navigation
            if (Model.SearchResults != null)
                await BrowserStorage.SetAsync(
                    SearchPersistenceKeys.HumanActiveSurveillanceSessionSeachPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanActiveSurveillanceSessionSearchModelKey,
                Model);

            var userPermissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession);
            if (userPermissions.Create)
            {
                var uri = $"{NavManager.BaseUri}Human/ActiveSurveillanceSession/Create";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                await InsufficientPermissions();
            }
        }

        protected async Task CancelSearch()
        {
            try
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
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    shouldRender = false;
                    var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, $"An error has occurred: {ex.Message}");
                throw;
            }
        }

        protected async Task OpenEdit(long id)
        {
            _isRecordSelected = true;
            
            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanActiveSurveillanceSessionSeachPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanActiveSurveillanceSessionSearchModelKey, Model);

            NavManager.NavigateTo($"Human/ActiveSurveillanceSession/Create?id={id}", true);
        }

        protected void OpenPerson(long id)
        {
            NavManager.NavigateTo($"Human/Person/Details/{id}", true);
        }

        protected async Task SendReportLink(long id)
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
                    DiagService.Close(Model.SearchResults.First(x => x.SessionKey == id));
                    break;
                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close(Model.SearchResults.First(x => x.SessionKey == id));
                    break;
                default:
                    {
                    // persist search results before navigation
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanActiveSurveillanceSessionSeachPerformedIndicatorKey, true);
                    Model.SearchResults = Model.SearchResults;
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanActiveSurveillanceSessionSearchModelKey, Model);

                    NavManager.NavigateTo($"Human/ActiveSurveillanceSession/Create?id={id}&readonly=true&isReview=true", true);
                    break;
                    }
            }
        }

        protected async Task GetSessionStatuses(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ASSessionStatus, HACodeList.HumanHACode);
                SessionStatuses = list.AsODataEnumerable();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            try
            {
                var request = new FilteredDiseaseRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.HumanHACode,
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                    UsingType = UsingType.StandardCaseType,
                    AdvancedSearchTerm = args.Filter
                };

                var list = await CrossCuttingClient.GetFilteredDiseaseList(request);
                Diseases = list.AsODataEnumerable();
                DiseaseCount = Diseases.Count();
                await ProtectedSessionStore.SetAsync("DiseaseList", Diseases);
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Protected Methods and Delegates

        #region Private Methods

        private void SetButtonStates()
        {
            if (ExpandSearchResults)
            {
                ShowCancelButton = true;
                ShowPrintButton = true;
                ShowSearchButton = false;
                ShowClearButton = false;
            }
            else
            {
                ShowCancelButton = true;
                ShowPrintButton = false;
                ShowSearchButton = true;
                ShowClearButton = true;
            }

            ShowAddButton = Model.ActiveSurveillanceSessionPermissions.Create;
        }

        private Task InitializeModel()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model = new ActiveSurveillanceSessionViewModel
            {
                ActiveSurveillanceSessionPermissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceSession),
                RecordSelectionIndicator = true,
                SearchRequest = new ActiveSurveillanceSessionRequestModel
                {
                    SortColumn = "ReportID",
                    SortOrder = SortConstants.Descending,
                    DateEnteredTo = DateTime.Today,
                    DateEnteredFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault)
                },
                BottomAdminLevel = _tokenService.GetAuthenticatedUser().BottomAdminLevel, //19000002 is level 2, 19000003 is level 3, etc
                //initialize the location control
                SearchLocationViewModel = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    EnableAdminLevel1 = true,
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = true,
                    ShowAdminLevel2 = true,
                    ShowAdminLevel3 = true,
                    ShowAdminLevel4 = false,
                    ShowAdminLevel5 = false,
                    ShowAdminLevel6 = false,
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
                    IsDbRequiredAdminLevel1 = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(CountryID)
                }
            };
            return Task.CompletedTask;

            #endregion Private Methods
        }

        #region Grid Column Order  Chooser
     
        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig =  GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, Grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = GridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            var visible = true;
            try
            {
                visible = GridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = GridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        #endregion
    }
}