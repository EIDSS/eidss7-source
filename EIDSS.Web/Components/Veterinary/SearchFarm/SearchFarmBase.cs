#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
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

namespace EIDSS.Web.Components.Veterinary.SearchFarm
{
    public class SearchFarmBase : SearchComponentBase<SearchFarmPageViewModel>, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IVeterinaryClient VeterinaryDiseaseReportClient { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private ILogger<SearchFarmBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public bool Refresh { get; set; }
        [Parameter] public long? SessionAdministrativeLevel2Id { get; set; }
        [Parameter] public long? SessionAdministrativeLevel3Id { get; set; }
        [Parameter] public EventCallback SelectFarmEvent { get; set; }
        [Parameter] public bool? DisableAvian { get; set; }
        [Parameter] public bool? DisableLivestock { get; set; }
        [Parameter] public long? MonitoringSessionID { get; set; }
        [Parameter] public long? FarmTypeID { get; set; }

        #endregion

        #region Properties

        protected RadzenCheckBoxList<long> FarmTypeCheckBoxList { get; set; }
        protected LocationView FarmLocationViewComponent;

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<FarmViewModel> Grid;
        protected RadzenTemplateForm<SearchFarmPageViewModel> Form;
        protected SearchFarmPageViewModel Model;
        protected List<BaseReferenceViewModel> FarmTypes;
        public FarmViewModel SelectedFarm { get; set; }

        #endregion

        #region Private Members

        private bool _resetSearch;
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
            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.FarmSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult is { Success: true, Value: true };
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<SearchFarmPageViewModel>(SearchPersistenceKeys.FarmSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchResults = searchModel.SearchResults;

                    if (Model.SearchResults is not null && Model.SearchResults.Any())
                        count = Model.SearchResults.FirstOrDefault() != null
                                ? Model.SearchResults.First().RecordCount.GetValueOrDefault()
                        : 0;

                    if (Grid is not null)
                        Grid.PageSize = Model.SearchCriteria.PageSize != 0 ? Model.SearchCriteria.PageSize : 10;

                    if (Refresh || count > 0)
                        searchSubmitted = true;

                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                    await FarmLocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                    // set up the accordions
                    expandSearchCriteria = false;
                    showSearchCriteriaButtons = false;
                    showSearchResults = true;

                    isLoading = false;
                }
            }
            else if (MonitoringSessionID is not null)
            {
                isLoading = true;
                expandSearchCriteria = false;
                showSearchCriteriaButtons = false;
                searchSubmitted = true;

                await LoadData(new LoadDataArgs());
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

            await SetButtonStates();

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
                await GetFarmTypesAsync();

                await LoadFarmTypeCheckBoxList();

                await FarmLocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                LoadingComponentIndicator = false;

                await InvokeAsync(StateHasChanged);

                if (!IsNullOrEmpty(CancelUrl) && CancelUrl.Contains("/Outbreak/OutbreakCases?queryData="))
                {
                    if (!VerifyOutbreakCasePermissions())
                    {
                        await InsufficientPermissionsRedirectAsync("{NavManager.BaseUri}" + CancelUrl.Remove(0, 1));
                    }
                }
            }
            else if (_resetSearch)
            {
                await LoadFarmTypeCheckBoxList();

                _resetSearch = false;
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task LoadFarmTypeCheckBoxList()
        {
            if (FarmTypes is null)
                await GetFarmTypesAsync();

            // Laboratory or Outbreak modules - disable farm type for an outbreak session that does not have
            // avian or livestock to prevent selection of a farm, or a veterinary active surveillance session
            // being registered from the laboratory module.
            if (DisableAvian is not null && DisableLivestock is not null)
            {
                RadzenCheckBoxListItem<long> item = new();
                item.Text = FarmTypes[0].Name;
                item.Disabled = (bool)DisableAvian;
                item.Value = FarmTypes[0].IdfsBaseReference;

                FarmTypeCheckBoxList.AddItem(item);

                item = new RadzenCheckBoxListItem<long>();
                item.Text = FarmTypes[1].Name;
                item.Disabled = (bool)DisableLivestock;
                item.Value = FarmTypes[1].IdfsBaseReference;
                FarmTypeCheckBoxList.AddItem(item);

                await InvokeAsync(StateHasChanged);
            }
            else
            {
                RadzenCheckBoxListItem<long> item = new();
                item.Text = FarmTypes[0].Name;
                item.Disabled = false;
                item.Value = FarmTypes[0].IdfsBaseReference;

                FarmTypeCheckBoxList.AddItem(item);

                item = new RadzenCheckBoxListItem<long>();
                item.Text = FarmTypes[1].Name;
                item.Disabled = false;
                item.Value = FarmTypes[1].IdfsBaseReference;
                FarmTypeCheckBoxList.AddItem(item);

                await InvokeAsync(StateHasChanged);
            }

            // Set when a veterinary active surveillance session sample is being registered in the laboratory module.
            // The category of sample will be set to either Avian or Livestock, so narrow the search to that type of
            // farm - (LUC10 - enter a new sample).
            if (FarmTypeID is not null)
            {
                Model.SearchCriteria.SelectedFarmTypes = Enumerable.Empty<long>();
                Model.SearchCriteria.SelectedFarmTypes = Model.SearchCriteria.SelectedFarmTypes.Concat(new[] { (long)FarmTypeID });

                await InvokeAsync(StateHasChanged);
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
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
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
        /// 
        /// </summary>
        /// <returns></returns>
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

                var dialogParams = new Dictionary<string, object>
                {
                    { "DialogType", EIDSSDialogType.Warning },
                    { "DialogName", "NarrowSearch" },
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage) }
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
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        /// <summary>
        /// 
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

                    var request = new FarmMasterSearchRequestModel
                    {
                        EIDSSFarmID = Model.SearchCriteria.EIDSSFarmID,
                        LegacyFarmID = Model.SearchCriteria.LegacyFarmID
                    };
                    if (Model.SearchCriteria.SelectedFarmTypes != null && Model.SearchCriteria.SelectedFarmTypes.Any())
                    {
                        request.FarmTypeID = Model.SearchCriteria.SelectedFarmTypes.Count() == 2 ? HACodeBaseReferenceIds.All : Model.SearchCriteria.SelectedFarmTypes.First();
                    }

                    request.FarmOwnerLastName = Model.SearchCriteria.FarmOwnerLastName;
                    request.FarmOwnerFirstName = Model.SearchCriteria.FarmOwnerFirstName;
                    request.EIDSSFarmOwnerID = Model.SearchCriteria.EIDSSFarmOwnerID;
                    request.EIDSSPersonID = Model.SearchCriteria.EIDSSPersonID;
                    request.FarmName = Model.SearchCriteria.FarmName;

                    //Get lowest administrative level for location
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.IdfsLocation = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.IdfsLocation = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.IdfsLocation = Model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        request.IdfsLocation = null;

                    request.MonitoringSessionID = MonitoringSessionID;
                    request.LanguageId = GetCurrentLanguage();

                    // sorting
                    if (args.Sorts?.FirstOrDefault() != null)
                    {
                        request.SortColumn = args.Sorts.FirstOrDefault()?.Property;
                        request.SortOrder = args.Sorts.FirstOrDefault()
                            ?.SortOrder?.ToString().Replace("Ascending", SortConstants.Ascending).Replace("Descending", SortConstants.Descending);
                    }
                    else
                    {
                        request.SortColumn = "EIDSSFarmID";
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

                    if ((!IsNullOrEmpty(request.EIDSSFarmID) || !IsNullOrEmpty(request.LegacyFarmID)) &&
                        IsNullOrEmpty(request.EIDSSFarmOwnerID) &&
                        IsNullOrEmpty(request.EIDSSPersonID) &&
                        IsNullOrEmpty(request.FarmName) &&
                        IsNullOrEmpty(request.FarmOwnerFirstName) &&
                        IsNullOrEmpty(request.FarmOwnerLastName) &&
                        request.FarmTypeID is null &&
                        request.IdfsLocation is null &&
                        request.MonitoringSessionID is null &&
                        request.SettlementTypeID is null)
                        request.RecordIdentifierSearchIndicator = true;
                    else
                        request.RecordIdentifierSearchIndicator = false;

                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    Model.SearchCriteria.Page = request.Page;
                    Model.SearchCriteria.PageSize = request.PageSize;

                    if (_isRecordSelected == false)
                    {
                        var result = await VeterinaryDiseaseReportClient.GetFarmMasterListAsync(request, token);
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
                Model.SearchResults = new List<FarmViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        protected async Task HandleValidSearchSubmit(SearchFarmPageViewModel model)
        {
            if (Form.IsValid && HasCriteria(model) || MonitoringSessionID is not null)
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToFarmsData);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                await SetButtonStates();

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

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task CancelSearchClicked()
        {
            if (Mode == SearchModeEnum.SelectNoRedirect)
                DiagService.Close("Cancelled");
            else
                await CancelSearchAsync();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task ResetSearch()
        {
            _resetSearch = true;

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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="farmMasterId"></param>
        /// <returns></returns>
        protected async Task OpenEdit(long? farmMasterId)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmSearchModelKey, Model);

            shouldRender = false;
            const string path = "Veterinary/Farm/Details";
            var query = $"?id={farmMasterId}&isEdit=true";
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task OpenAdd()
        {
            if (Mode == SearchModeEnum.SelectNoRedirect)
            {
                DiagService.Close("Add");
            }
            else
            {
                // persist search results before navigation
                if (Model.SearchResults != null)
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmSearchPerformedIndicatorKey, true);
                await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmSearchModelKey, Model);

                var userPermissions = GetUserPermissions(PagePermission.AccessToFarmsData);
                if (userPermissions.Create)
                {
                    shouldRender = false;
                    const string path = "Veterinary/Farm/Details";
                    var uri = $"{NavManager.BaseUri}{path}";

                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    await InsufficientPermissions();
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="farmRecord"></param>
        /// <returns></returns>
        protected async Task SendReportLink(FarmViewModel farmRecord)
        {
            try
            {
                _isRecordSelected = true;

                var selectFarmRecordIndicator = true;
                if (SessionAdministrativeLevel2Id is not null)
                {
                    if (SessionAdministrativeLevel2Id != farmRecord.RegionID)
                    {
                        var result = await ShowWarningDialog(MessageResourceKeyConstants.CreateVeterinaryCaseTheFarmAddressDoesNotMatchTheSessionLocationDoYouWantToContinueMessage,
                        null);

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                                selectFarmRecordIndicator = false;

                            DiagService.Close(result);
                        }
                    }
                    else if (SessionAdministrativeLevel3Id is not null && SessionAdministrativeLevel3Id != farmRecord.RayonID)
                    {
                        var result = await ShowWarningDialog(MessageResourceKeyConstants.CreateVeterinaryCaseTheFarmAddressDoesNotMatchTheSessionLocationDoYouWantToContinueMessage,
                            null);

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                                selectFarmRecordIndicator = false;

                            DiagService.Close(result);
                        }
                    }
                }

                if (selectFarmRecordIndicator)
                {
                    switch (Mode)
                    {
                        case SearchModeEnum.Import:
                            {
                                if (CallbackUrl.EndsWith('/'))
                                {
                                    CallbackUrl = CallbackUrl[0..^1];
                                }

                                var url = CallbackUrl + $"?Id={farmRecord.FarmMasterID}";

                                if (CallbackKey != null)
                                {
                                    url += "&callbackkey=" + CallbackKey.ToString();
                                }
                                NavManager.NavigateTo(url, true);
                                break;
                            }
                        case SearchModeEnum.Select:
                            DiagService.Close(Model.SearchResults.First(x => x.FarmMasterID == farmRecord.FarmMasterID));
                            break;

                        case SearchModeEnum.SelectNoRedirect:
                            DiagService.Close(Model.SearchResults.First(x => x.FarmMasterID == farmRecord.FarmMasterID));
                            break;

                        case SearchModeEnum.SelectEvent:
                            SelectedFarm = Model.SearchResults.First(x => x.FarmMasterID == farmRecord.FarmMasterID);
                            await SelectFarmEvent.InvokeAsync();
                            break;

                        default:
                            {
                                // persist search results before navigation
                                await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmSearchPerformedIndicatorKey, true);
                                await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmSearchModelKey, Model);

                                shouldRender = false;
                                var path = "Veterinary/Farm/Details";
                                var query = $"?id={farmRecord.FarmMasterID}&isReadOnly=true";
                                var uri = $"{NavManager.BaseUri}{path}{query}";

                                NavManager.NavigateTo(uri, true);
                                break;
                            }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task GetFarmTypesAsync()
        {
            var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.AccessoryList, HACodeList.LiveStockAndAvian);
            FarmTypes = results.Where(t => t.IdfsBaseReference is HACodeBaseReferenceIds.Livestock or HACodeBaseReferenceIds.Avian).ToList();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private bool VerifyOutbreakCasePermissions()
        {
            var userPermissions = GetUserPermissions(PagePermission.AccessToOutbreakVeterinaryCaseData);

            return userPermissions.Create;
        }

        #endregion

        #region Private Methods

        private async Task SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.FarmSearchPermissions.Create)
            {
                disableAddButton = true;
            }

            await InvokeAsync(StateHasChanged);
        }

        private void SetDefaults()
        {
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;
        }

        /// <summary>
        /// 
        /// </summary>
        private void InitializeModel()
        {
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            Model = new SearchFarmPageViewModel
            {
                FarmSearchPermissions = GetUserPermissions(PagePermission.AccessToFarmsData),
                SearchCriteria =
                {
                    SortColumn = "EIDSSFarmID",
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

        private static bool HasCriteria(SearchFarmPageViewModel model)
        {
            var properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                if (prop.Name == "SelectedFarmTypes" && model.SearchCriteria.SelectedFarmTypes?.Count() > 0)
                {
                    return true;
                }

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

        // SearchFarmPageViewModel
        protected async Task PrintResults()
        {
            if (Form.IsValid)
            {
                var nGridCount = Grid.Count;
                try
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.FarmPageHeading));
                    reportModel.AddParameter("EIDSSFarmID", Model.SearchCriteria.EIDSSFarmID);
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId); // For Organization // model.SearchCriteria.EIDSSPersonID);
                    reportModel.AddParameter("pageSize", nGridCount.ToString());

                    //Get lowest administrative level for location
                    if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        reportModel.AddParameter("idfsLocation", Model.SearchLocationViewModel.AdminLevel3Value.Value.ToString());
                    else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        reportModel.AddParameter("idfsLocation", Model.SearchLocationViewModel.AdminLevel2Value.Value.ToString());
                    else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        reportModel.AddParameter("idfsLocation", Model.SearchLocationViewModel.AdminLevel1Value.Value.ToString());
                    else if (Model.SearchLocationViewModel.AdminLevel0Value.HasValue)
                        reportModel.AddParameter("idfsLocation", Model.SearchLocationViewModel.AdminLevel0Value.Value.ToString());

                    //reportModel.AddParameter("idfsLocation", model.SearchCriteria.IdfsLocation.ToString());
                    reportModel.AddParameter("LegacyFarmID", Model.SearchCriteria.LegacyFarmID);
                    if (Model.SearchCriteria.SelectedFarmTypes != null && Model.SearchCriteria.SelectedFarmTypes.Any())
                    {
                        if (Model.SearchCriteria.SelectedFarmTypes.Count() == 2)
                        {
                            //select both avian and livestock
                            reportModel.AddParameter("FarmTypeID", HACodeBaseReferenceIds.All.ToString());
                        }
                        else
                        {
                            reportModel.AddParameter("FarmTypeID", Model.SearchCriteria.SelectedFarmTypes.First().ToString());
                        }
                    }
                    reportModel.AddParameter("FarmOwnerID", Model.SearchCriteria.FarmOwnerID.ToString());
                    reportModel.AddParameter("FarmOwnerLastName", Model.SearchCriteria.FarmOwnerLastName);
                    reportModel.AddParameter("FarmOwnerFirstName", Model.SearchCriteria.FarmOwnerFirstName);
                    reportModel.AddParameter("FarmName", Model.SearchCriteria.FarmName);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.FarmPageHeading),
                        new Dictionary<string, object> { { "ReportName", "SearchForFarm" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px"
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