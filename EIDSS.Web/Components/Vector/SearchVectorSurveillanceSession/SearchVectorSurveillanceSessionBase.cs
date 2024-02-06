#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Vector.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Vector.SearchVectorSurveillanceSession
{
    public class
        SearchVectorSurveillanceSessionBase : SearchComponentBase<SearchVectorSurveillanceSessionPageViewModel>,
            IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IVectorClient VectorSurveillanceSessionClient { get; set; }

        [Inject] private IVectorTypeClient VectorTypeClient { get; set; }

        [Inject] private IVectorSpeciesTypeClient VectorSpeciesTypeClient { get; set; }

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        [Inject] private ILogger<SearchVectorSurveillanceSessionBase> Logger { get; set; }

        #endregion Dependencies

        #region Properties

        public enum SearchMode
        {
            Default,
            Import
        }

        protected RadzenDataGrid<VectorSurveillanceSessionViewModel> Grid { get; set; }
        protected RadzenTemplateForm<SearchVectorSurveillanceSessionPageViewModel> Form { get; set; }
        protected SearchVectorSurveillanceSessionPageViewModel Model { get; set; }
        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        protected IEnumerable<BaseReferenceViewModel> ReportStatuses { get; set; }
        protected IEnumerable<BaseReferenceEditorsViewModel> VectorTypes { get; set; }
        protected IEnumerable<BaseReferenceEditorsViewModel> SpeciesTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> Outcomes { get; set; }
        protected int DiseaseCount { get; set; }
        protected bool DisableSpeciesType { get; set; }
        protected LocationView LocationViewComponent;

        #endregion Properties

        #region Member Variables

        private bool _isRecordSelected;

        #endregion

        #endregion Globals

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            LoadingComponentIndicator = true;

            _logger = Logger;

            //initialize model
            InitializeModel();

            // see if a search was saved
            var indicatorResult =
                await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .VectorSurveillanceSessionSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult is { Success: true, Value: true };
            if (searchPerformedIndicator)
            {
                var searchModelResult =
                    await BrowserStorage.GetAsync<SearchVectorSurveillanceSessionPageViewModel>(SearchPersistenceKeys
                        .VectorSurveillanceSessionSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                    await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                    Model.SearchResults = searchModel.SearchResults;
                    count = count = Model.SearchResults is { Count: > 0 }
                        ? Model.SearchResults.First().RecordCount.GetValueOrDefault()
                        : 0;

                    if (Grid is not null)
                        Grid.PageSize = Model.SearchCriteria.PageSize != 0 ? Model.SearchCriteria.PageSize : 10;

                    searchSubmitted = true;

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

            await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

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
            source?.Cancel();
            source?.Dispose();
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
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)
                }
            };
            var result =
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
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

        protected async Task LoadData(LoadDataArgs args)
        {
            if (searchSubmitted)
            {
                try
                {
                    isLoading = true;
                    showSearchResults = true;

                    var request = new VectorSurveillanceSessionSearchRequestModel
                    {
                        SessionID = Model.SearchCriteria.SessionID,
                        FieldSessionID = Model.SearchCriteria.FieldSessionID,
                        DiseaseID = Model.SearchCriteria.DiseaseID,
                        StatusTypeID = Model.SearchCriteria.StatusTypeID,
                        StartDateFrom = Model.SearchCriteria.StartDateFrom,
                        StartDateTo = Model.SearchCriteria.StartDateTo,
                        EndDateFrom = Model.SearchCriteria.EndDateTo,
                        EndDateTo = Model.SearchCriteria.EndDateTo
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

                    request.VectorTypeID = IsNullOrEmpty(Convert.ToString(Model.SearchCriteria.SelectedVectorTypeID))
                        ? null
                        : Convert.ToString(Model.SearchCriteria.SelectedVectorTypeID);
                    request.SpeciesTypeID = Model.SearchCriteria.SpeciesTypeID;

                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId ==
                                                           (long)SiteTypes.ThirdLevel;

                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    // sorting
                    if (args.Sorts.FirstOrDefault() != null)
                    {
                        request.SortColumn = args.Sorts.FirstOrDefault()?.Property;
                        var sortOrder = args.Sorts.FirstOrDefault()
                            ?.SortOrder;
                        if (sortOrder != null)
                            request.SortOrder = sortOrder.Value.ToString().Replace("Ascending", SortConstants.Ascending)
                                .Replace("Descending", SortConstants.Descending);
                    }
                    else
                    {
                        request.SortColumn = "SessionID";
                        request.SortOrder = SortConstants.Descending;
                    }

                    //paging
                    if (args.Skip is > 0)
                        request.Page = args.Skip.Value / Grid.PageSize + 1;
                    else
                        request.Page = 1;

                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    Model.SearchCriteria.Page = request.Page;
                    Model.SearchCriteria.PageSize = request.PageSize;

                    if (_isRecordSelected == false)
                    {
                        var result =
                            await VectorSurveillanceSessionClient.GetVectorSurveillanceSessionListAsync(request, token);
                        if (source?.IsCancellationRequested == false)
                        {
                            Model.SearchResults = result;
                            count = Model.SearchResults is { Count: > 0 }
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
                }
            }
            else
            {
                //initialize the grid so that it displays 'No records message'
                Model.SearchResults = new List<VectorSurveillanceSessionViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(SearchVectorSurveillanceSessionPageViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToVectorSurveillanceSession);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                expandAdvancedSearchCriteria = false;
                SetButtonStates();

                if (Grid != null) await Grid.Reload();
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
            expandAdvancedSearchCriteria = false;
            showSearchResults = false;
            SetButtonStates();
        }

        protected async Task OpenAdd()
        {
            // persist search results before navigation
            if (Model.SearchResults != null)
                await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey,
                    true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey, Model);

            var userPermissions = GetUserPermissions(PagePermission.AccessToVectorSurveillanceSession);
            if (userPermissions.Create)
            {
                shouldRender = false;
                var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/Add";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                await InsufficientPermissions();
            }
        }

        protected async Task OpenEdit(long sessionKey)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey,
                true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey, Model);

            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/Edit?sessionKey={sessionKey}";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLink(long sessionKey)
        {
            _isRecordSelected = true;

            switch (Mode)
            {
                case SearchModeEnum.Import:
                    {
                        if (CallbackUrl.EndsWith('/')) CallbackUrl = CallbackUrl[..^1];

                        var url = CallbackUrl + $"?Id={sessionKey}";

                        if (CallbackKey != null) url += "&callbackkey=" + CallbackKey;
                        NavManager.NavigateTo(url, true);
                        break;
                    }
                case SearchModeEnum.Select:
                    DiagService.Close(Model.SearchResults.First(x => x.SessionKey == sessionKey));
                    break;

                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close(Model.SearchResults.First(x => x.SessionKey == sessionKey));
                    break;

                case SearchModeEnum.Default:
                case SearchModeEnum.SelectEvent:
                default:
                    {
                        // persist search results before navigation
                        await BrowserStorage.SetAsync(
                            SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey, true);
                        await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey, Model);

                        shouldRender = false;
                        const string path = "Vector/VectorSurveillanceSession/Edit";
                        var query = $"?sessionKey={sessionKey}&isReadOnly=true";
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
                AccessoryCode = HACodeList.VectorHACode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType,
                AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter.ToLowerInvariant()
            };
            Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            DiseaseCount = Diseases.Count();
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSpeciesTypesAsync(LoadDataArgs args)
        {
            try
            {
                if (!DisableSpeciesType)
                {
                    var request = new VectorSpeciesTypesGetRequestModel
                    {
                        IdfsVectorType = Convert.ToInt64(args.Filter),
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = "intOrder",
                        SortOrder = SortConstants.Ascending
                    };
                    SpeciesTypes = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(request);
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
        }

        protected async Task GetVectorTypesAsync(LoadDataArgs args)
        {
            try
            {
                var request = new VectorTypesGetRequestModel
                {
                    AdvancedSearch = args.Filter,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    LanguageId = GetCurrentLanguage(),
                    SortColumn = "intOrder",
                    SortOrder = SortConstants.Ascending
                };
                VectorTypes = await VectorTypeClient.GetVectorTypeList(request);

                if (args.Filter != null) VectorTypes = VectorTypes.Where(x => x.StrName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
        }

        protected async Task OnVectorTypeChange(object selectedVectorType)
        {
            try
            {
                if (selectedVectorType != null)
                {
                    DisableSpeciesType = false;
                    var request = new VectorSpeciesTypesGetRequestModel
                    {
                        IdfsVectorType = Convert.ToInt64(selectedVectorType),
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = "intOrder",
                        SortOrder = SortConstants.Ascending
                    };
                    SpeciesTypes = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(request);
                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    Model.SearchCriteria.SpeciesTypeID = null;
                    DisableSpeciesType = true;
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
        }

        protected async Task GetReportStatusesAsync(LoadDataArgs args)
        {
            ReportStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.VectorSurveillanceSessionStatus, HACodeList.VectorHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = ReportStatuses.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                ReportStatuses = toList;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Methods

        #region Private Methods

        private void SetButtonStates()
        {
            DisableSpeciesType = true;

            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.VectorSurveillanceSessionPermissions.Create) disableAddButton = true;
        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            var userPreferences =
                ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model.SearchCriteria.StartDateTo = DateTime.Today;
            Model.SearchCriteria.StartDateFrom =
                DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RegionId
                : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RayonId
                : null;
        }

        private void InitializeModel()
        {
            Model = new SearchVectorSurveillanceSessionPageViewModel
            {
                VectorSurveillanceSessionPermissions =
                    GetUserPermissions(PagePermission.AccessToVectorSurveillanceSession),
                BottomAdminLevel =
                    _tokenService.GetAuthenticatedUser()
                        .BottomAdminLevel, //19000002 is level 2, 19000003 is level 3, etc
                SearchCriteria =
                {
                    SortColumn = "SessionID",
                    SortOrder = SortConstants.Descending
                },
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
                    IsDbRequiredAdminLevel0 = false,
                    IsDbRequiredAdminLevel1 = false,
                    IsDbRequiredAdminLevel2 = false,
                    IsDbRequiredSettlement = false,
                    IsDbRequiredSettlementType = false,
                    AdminLevel0Value = Convert.ToInt64(CountryID)
                }
            };
        }

        private static bool HasCriteria(SearchVectorSurveillanceSessionPageViewModel model)
        {
            var properties = model.SearchCriteria.GetType().GetProperties()
                .Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
                if (prop.GetValue(model.SearchCriteria) != null)
                {
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
                try
                {
                    var nGridCount = Grid.Count;

                    ReportViewModel reportModel = new();

                    // get lowest administrative level for location
                    long? locationId = null;
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        locationId = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        locationId = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        locationId = Model.SearchLocationViewModel.AdminLevel1Value.Value;

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants
                            .VectorSurveillanceSessionsListPageHeading)); // "Weekly Reporting List");
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("PageSize", nGridCount.ToString());
                    reportModel.AddParameter("SessionID", Model.SearchCriteria.SessionID);
                    reportModel.AddParameter("FieldSessionID", Model.SearchCriteria.FieldSessionID);
                    reportModel.AddParameter("DiseaseID", Model.SearchCriteria.DiseaseID.ToString());
                    reportModel.AddParameter("StatusTypeID", Model.SearchCriteria.StatusTypeID.ToString());
                    if (Model.SearchCriteria.StartDateFrom != null)
                        reportModel.AddParameter("StartDateFrom", Model.SearchCriteria.StartDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.StartDateTo != null)
                        reportModel.AddParameter("StartDateTo", Model.SearchCriteria.StartDateTo.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.EndDateFrom != null)
                        reportModel.AddParameter("EndDateFrom", Model.SearchCriteria.EndDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.EndDateTo != null)
                        reportModel.AddParameter("EndDateTo", Model.SearchCriteria.EndDateTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("VectorTypeID",
                        IsNullOrEmpty(Convert.ToString(Model.SearchCriteria.SelectedVectorTypeID))
                            ? null
                            : Convert.ToString(Model.SearchCriteria.SelectedVectorTypeID));
                    reportModel.AddParameter("SpeciesTypeID", Model.SearchCriteria.SpeciesTypeID.ToString());
                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId == (long)SiteTypes.ThirdLevel ? "1" : "0");
                    reportModel.AddParameter("UserEmployeeID", _tokenService.GetAuthenticatedUser().PersonId);
                    reportModel.AddParameter("UserOrganizationID",
                        _tokenService.GetAuthenticatedUser().OfficeId.ToString());
                    reportModel.AddParameter("UserSiteID", _tokenService.GetAuthenticatedUser().SiteId);

                    reportModel.AddParameter("AdministrativeLevelID", locationId.ToString());

                    //sorting
                    reportModel.AddParameter("SortColumn", "SessionID");
                    reportModel.AddParameter("SortOrder", Model.SearchCriteria.SortOrder);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.VectorSurveillanceSessionsListPageHeading),
                        new Dictionary<string, object>
                        {
                            {"ReportName", "SearchForVectorSurveillanceSession"}, {"Parameters", reportModel.Parameters}
                        },
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.VectorSurveillanceSession,
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

        #endregion Private Methods
    }
}