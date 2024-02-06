#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Veterinary.ViewModels.Veterinary.ActiveSurveillanceSession;
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
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.SearchActiveSurveillanceSession
{
    public class SearchActiveSurveillanceSessionBase : SearchComponentBase<SearchActiveSurveillanceSessionPageViewModel>, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IVeterinaryClient VeterinaryClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchActiveSurveillanceSessionBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long? SessionCategoryTypeID { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<VeterinaryActiveSurveillanceSessionViewModel> Grid { get; set; }
        protected RadzenTemplateForm<SearchActiveSurveillanceSessionPageViewModel> Form { get; set; }
        protected SearchActiveSurveillanceSessionPageViewModel Model { get; set; }
        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        protected IEnumerable<BaseReferenceViewModel> SessionStatuses { get; set; }
        protected LocationView LocationViewComponent;

        #endregion

        #region Member Variables

        private bool _isRecordSelected;

        #endregion

        #endregion

        #region Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            LoadingComponentIndicator = true;

            _logger = Logger;

            InitializeModel();

            // see if a search was saved
            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<SearchActiveSurveillanceSessionPageViewModel>(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {

                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchResults = searchModel.SearchResults;
                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                    await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                    count = (int) (Model.SearchResults != null && Model.SearchResults.Count > 0
                            ? Model.SearchResults.FirstOrDefault()?.RecordCount
                            : 0);

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
                SetDefaults();

                // set up the accordions
                expandSearchCriteria = true;
                showSearchCriteriaButtons = true;
                showSearchResults = false;
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
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, $"Error occurred: {ex.Message}");
                throw;
            }
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
        }

        protected void AccordionClick(int index)
        {
            expandSearchCriteria = index switch
            {
                //search criteria toggle
                0 => !expandSearchCriteria,
                _ => expandSearchCriteria
            };
            SetButtonStates();
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            try
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
                    {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    source = new CancellationTokenSource();
                    token = source.Token;
                    expandSearchCriteria = true;
                    SetButtonStates();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, $"Error occurred: {ex.Message}");
                throw;
            }
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;
                    showSearchResults = true;

                    var request = new VeterinaryActiveSurveillanceSessionSearchRequestModel
                    {
                        SessionID = Model.SearchCriteria.SessionID,
                        LegacySessionID = Model.SearchCriteria.LegacySessionID,
                        SessionStatusTypeID = Model.SearchCriteria.SessionStatusTypeID,
                        DiseaseID = Model.SearchCriteria.DiseaseID
                    };

                    //Get lowest administrative level for location
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.AdministrativeLevelID = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.AdministrativeLevelID = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.AdministrativeLevelID = Model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        request.AdministrativeLevelID = null;

                    request.DateEnteredFrom = Model.SearchCriteria.DateEnteredFrom;
                    request.DateEnteredTo = Model.SearchCriteria.DateEnteredTo;

                    if (SessionCategoryTypeID is not null)
                        request.SessionCategoryTypeID = SessionCategoryTypeID;

                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel);
                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    // sorting
                    if (args.Sorts.FirstOrDefault() != null)
                    {
                        request.SortColumn = args.Sorts.FirstOrDefault()?.Property;
                        request.SortOrder = args.Sorts.FirstOrDefault()
                            ?.SortOrder?.ToString().Replace("Ascending", SortConstants.Ascending).Replace("Descending", SortConstants.Descending);
                    }
                    else
                    {
                        request.SortColumn = "SessionID";
                        request.SortOrder = SortConstants.Descending;
                    }

                    // paging
                    if (args.Skip is > 0)
                    {
                        request.Page = args.Skip.Value / Grid.PageSize + 1;
                    }
                    else
                    {
                        request.Page = 1;
                    }

                    // persist sort column and sort order for printing
                    Model.SearchCriteria.SortColumn = request.SortColumn;
                    Model.SearchCriteria.SortOrder = request.SortOrder;
                    
                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    Model.SearchCriteria.Page = request.Page;
                    Model.SearchCriteria.PageSize = request.PageSize;

                    if (_isRecordSelected == false)
                    {
                        var result = await VeterinaryClient.GetActiveSurveillanceSessionListAsync(request, token);
                        if (source.IsCancellationRequested == false)
                        {
                            Model.SearchResults = result;
                            count = Model.SearchResults is {Count: > 0}
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
                //initialize the grid so that it displays 'No records message'
                Model.SearchResults = new List<VeterinaryActiveSurveillanceSessionViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(SearchActiveSurveillanceSessionPageViewModel model)
        {

            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                SetButtonStates();

                if (Grid != null)
                {
                    await Grid.Reload();
                }
            }
            else
            {
                //no search criteria entered
                searchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
        }

        protected async Task CancelSearchClicked()
        {
            if (Mode == SearchModeEnum.SelectNoRedirect)
                DiagService.Close("Cancelled");
            else
                await CancelSearchAsync();
        }

        protected void ResetSearch()
        {
            //initialize new model
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
            SetButtonStates();
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

        protected async Task OpenAddAsync()
        {
            // persist search results before navigation
            if (Model.SearchResults != null)
                await BrowserStorage.SetAsync(
                    SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSearchModelKey,
                Model);

            var userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession);
            if (userPermissions.Create)
            {
                shouldRender = false;
                var uri = $"{NavManager.BaseUri}Veterinary/ActiveSurveillanceSession/Add";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                await InsufficientPermissions();
            }
        }

        protected async Task OpenEditAsync(long sessionId)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSearchModelKey, Model);

            shouldRender = false;
            const string path = "Veterinary/ActiveSurveillanceSession/Details";
            var query = $"?sessionID={sessionId}";
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLinkAsync(long sessionId)
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

                    var url = CallbackUrl + $"?Id={sessionId}";

                    if (CallbackKey != null)
                    {
                        url += "&callbackkey=" + CallbackKey;
                    }
                    NavManager.NavigateTo(url, true);
                    break;
                }
                case SearchModeEnum.Select:
                    DiagService.Close(Model.SearchResults.First(x => x.SessionKey == sessionId));
                    break;
                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close(Model.SearchResults.First(x => x.SessionKey == sessionId));
                    break;
                default:
                {
                    // persist search results before navigation
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSeachPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.VeterinaryActiveSurveillanceSessionSearchModelKey, Model);

                    shouldRender = false;
                    const string path = "Veterinary/ActiveSurveillanceSession/Details";
                    var query = $"?sessionID={sessionId}&isReadOnly=true";
                    var uri = $"{NavManager.BaseUri}{path}{query}";

                    NavManager.NavigateTo(uri, true);
                    break;
                }
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = HACodeList.LiveStockAndAvian,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSessionStatusTypesAsync(LoadDataArgs args)
        {
            SessionStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ASSessionStatus, HACodeList.LiveStockAndAvian);
            if (!IsNullOrEmpty(args.Filter))
            {
                List<BaseReferenceViewModel> toList = SessionStatuses.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                SessionStatuses = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Private Methods

        private void SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.ActiveSurveillanceSessionPermissions.Create)
            {
                disableAddButton = true;
            }
        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model.SearchCriteria.DateEnteredTo = DateTime.Today;
            Model.SearchCriteria.DateEnteredFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);

            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;
        }

        private void InitializeModel()
        {

            Model = new SearchActiveSurveillanceSessionPageViewModel
            {
                ActiveSurveillanceSessionPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceSession),
                BottomAdminLevel = _tokenService.GetAuthenticatedUser().BottomAdminLevel, //19000002 is level 2, 19000003 is level 3, etc
                SearchCriteria =
                {
                    SortColumn = "SessionID",
                    SortOrder = SortConstants.Descending
                }
            };

            Model.SearchLocationViewModel = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                EnableAdminLevel2 = true,
                EnableAdminLevel3 = Model.BottomAdminLevel >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                EnableAdminLevel4 = Model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                EnableAdminLevel5 = Model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                EnableAdminLevel6 = Model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = Model.BottomAdminLevel >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel4 = Model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel5 = Model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
                ShowAdminLevel6 = Model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement,
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
            };
        }

        private bool HasCriteria(SearchActiveSurveillanceSessionPageViewModel model)
        {
            var properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                if (prop.GetValue(model.SearchCriteria) == null) continue;
                if (prop.PropertyType == typeof(string))
                {
                    var value = prop.GetValue(model.SearchCriteria)?.ToString()?.Trim();
                    if (!IsNullOrWhiteSpace(value)) return true;
                    if (!IsNullOrEmpty(value)) return true;
                }
                else
                {
                    return true;
                }
            }

            //Check the location
            return model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                   model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                   model.SearchLocationViewModel.AdminLevel1Value.HasValue;
        }

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

                    // required parameters
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants.VeterinaryActiveSurveillancePageHeading)); 
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("PageSize", nGridCount.ToString());
                    reportModel.AddParameter("SortColumn", Model.SearchCriteria.SortColumn);
                    reportModel.AddParameter("SortOrder", Model.SearchCriteria.SortOrder);

                    // additional parameters 
                    reportModel.AddParameter("SessionID", Model.SearchCriteria.SessionID);
                    reportModel.AddParameter("LegacySessionID", Model.SearchCriteria.LegacySessionID);
                    reportModel.AddParameter("SessionStatusTypeID", Model.SearchCriteria.SessionStatusTypeID.ToString());
                    reportModel.AddParameter("DiseaseID", Model.SearchCriteria.DiseaseID.ToString());
                    Model.SearchCriteria.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel);
                    reportModel.AddParameter("ApplySiteFiltrationIndicator", Model.SearchCriteria.ApplySiteFiltrationIndicator.ToString());

                    reportModel.AddParameter("UserEmployeeID", _tokenService.GetAuthenticatedUser().PersonId);
                    reportModel.AddParameter("CampaignKey", Model.SearchCriteria.CampaignKey.ToString());
                    reportModel.AddParameter("CampaignID", Model.SearchCriteria.CampaignID);
                    reportModel.AddParameter("UserOrganizationID", _tokenService.GetAuthenticatedUser().OfficeId.ToString());
                    reportModel.AddParameter("UserSiteID", _tokenService.GetAuthenticatedUser().SiteId);
                    if (Model.SearchCriteria.DateEnteredFrom != null)
                        reportModel.AddParameter("DateEnteredFrom", Model.SearchCriteria.DateEnteredFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateEnteredTo != null)
                        reportModel.AddParameter("DateEnteredTo", Model.SearchCriteria.DateEnteredTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("AdministrativeLevelID", locationId.ToString());

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.VeterinaryActiveSurveillancePageHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "SearchForVeterinaryActiveSurveillanceSession"}, {"Parameters", reportModel.Parameters}},
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

        #endregion
    }
}