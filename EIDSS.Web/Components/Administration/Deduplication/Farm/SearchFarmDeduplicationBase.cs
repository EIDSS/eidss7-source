using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Veterinary.ViewModels.Farm;
using EIDSS.Web.Components.Administration.Deduplication.Person;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.Farm
{
    public class SearchFarmDeduplicationBase : FarmDeduplicationBaseComponent, IDisposable
    {
        #region Dependencies

        [Inject]
        private IVeterinaryClient VeterinaryClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchFarmDeduplicationBase> Logger { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }

        #endregion

        #region Parameters
        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        [Parameter]
        public bool ShowSelectedRecordsIndicator { get; set; }

        #endregion

        #region Properties
        public bool IsSelectedRecordsLoading { get; set; }
        public IList<FarmViewModel> SelectedRecords { get; set; }
        #endregion

        #region Protected and Public Members
        protected int count;
        protected bool shouldRender = true;
        protected bool isLoading;
        protected bool disableAddButton;
        protected bool disableSearchButton;
        protected bool hasCriteria;
        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool showSearchResults;
        protected bool showSearchCriteriaButtons;
        protected bool searchSubmitted;

        protected CancellationTokenSource source;
        protected CancellationToken token;

        protected RadzenDataGrid<FarmViewModel> grid;
        protected RadzenTemplateForm<SearchFarmPageViewModel> form;
        protected SearchFarmPageViewModel model;
        protected IEnumerable<BaseReferenceViewModel> farmTypes;

        protected RadzenDataGrid<FarmViewModel> gridSelectedRecords;
        protected bool showDeduplicateButton;
        protected bool disableDeduplicateButton;

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            // reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            _logger = Logger;

            InitializeModel();

            // get the farm types
            await GetFarmTypesAsync();

            // see if a search was saved
            ProtectedBrowserStorageResult<bool> indictatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.FarmDeduplicationSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indictatorResult.Success ? indictatorResult.Value : false;
            if (searchPerformedIndicator && ShowSelectedRecordsIndicator)
            {
                ProtectedBrowserStorageResult<SearchFarmPageViewModel> searchModelResult = await BrowserStorage.GetAsync<SearchFarmPageViewModel>(SearchPersistenceKeys.FarmDeduplicationSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    model.SearchCriteria = searchModel.SearchCriteria;
                    model.SearchResults = searchModel.SearchResults;
                    model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                    count = model.SearchResults.Count;

                    if (ShowSelectedRecordsIndicator)
                    {
                        IsSelectedRecordsLoading = true;
                        SelectedRecords = searchModel.SelectedRecords;
                        FarmDeduplicationService.SelectedRecords = searchModel.SelectedRecords;
                        showDeduplicateButton = true;
                        disableDeduplicateButton = false;
                        IsSelectedRecordsLoading = false;
                    }

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
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search criteria toggle
                case 0:
                    expandSearchCriteria = !expandSearchCriteria;
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

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogType", EIDSSDialogType.Warning);
                dialogParams.Add("DialogName", "NarrowSearch");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage));
                DialogOptions dialogOptions = new DialogOptions()
                {
                    ShowTitle = true,
                    ShowClose = false
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(String.Empty, dialogParams);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    source = new();
                    token = source.Token;
                    expandSearchCriteria = true;
                    SetButtonStates();
                }
            }
            catch (Exception)
            {
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

                    var request = new FarmMasterSearchRequestModel();
                    request.EIDSSFarmID = model.SearchCriteria.EIDSSFarmID;
                    request.LegacyFarmID = model.SearchCriteria.LegacyFarmID;
                    if (model.SearchCriteria.SelectedFarmTypes != null && model.SearchCriteria.SelectedFarmTypes.Count() > 0)
                    {
                        if (model.SearchCriteria.SelectedFarmTypes.Count() == 2)
                        {
                            //select both avian and livestock
                            request.FarmTypeID = EIDSSConstants.HACodeBaseReferenceIds.All;
                        }
                        else
                        {
                            request.FarmTypeID = model.SearchCriteria.SelectedFarmTypes.First();
                        }
                    }
                    request.FarmOwnerLastName = model.SearchCriteria.FarmOwnerLastName;
                    request.FarmOwnerFirstName = model.SearchCriteria.FarmOwnerFirstName;
                    request.FarmOwnerID = model.SearchCriteria.FarmOwnerID;
                    request.FarmName = model.SearchCriteria.FarmName;

                    //Get lowest administrative level for location
                    if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.IdfsLocation = model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.IdfsLocation = model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.IdfsLocation = model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        request.IdfsLocation = null;

                    request.LanguageId = GetCurrentLanguage();

                    //sorting
                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "EIDSSSFarmID";
                    request.SortOrder = args.Sorts.FirstOrDefault() != null ? "desc" : "desc";
                    //paging
                    if (args.Skip.HasValue && args.Skip.Value > 0)
                    {
                        request.Page = (args.Skip.Value / grid.PageSize) + 1;
                    }
                    else
                    {
                        request.Page = 1;
                    }
                    request.PageSize = grid.PageSize != 0 ? grid.PageSize : 10;

                    var result = await VeterinaryClient.GetFarmMasterListAsync(request, token);
                    if (source.IsCancellationRequested == false)
                    {
                        model.SearchResults = result;
                        count = model.SearchResults.FirstOrDefault() != null ? model.SearchResults.First().RecordCount.GetValueOrDefault() : 0;
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
                    StateHasChanged();
                }
            }
            else
            {
                model.SearchResults = new List<FarmViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(SearchFarmPageViewModel model)
        {

            if (form.IsValid && HasCriteria(model))
            {
                searchSubmitted = true;
                expandSearchCriteria = false;
                SetButtonStates();

                if (grid != null)
                {
                    await grid.Reload();
                }
            }
            else
            {
                //no search criteria entered
                searchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
        }

        protected async Task ShowNoSearchCriteriaDialog()
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

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogType", EIDSSDialogType.Warning);
                dialogParams.Add("DialogName", "NoCriteria");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.EnterAtLeastOneParameterMessage));
                DialogOptions dialogOptions = new DialogOptions()
                {
                    ShowTitle = true,
                    ShowClose = false
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(string.Empty, dialogParams, dialogOptions);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //do nothing, just informing the user.
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected void LocationChanged(LocationViewModel locationViewModel)
        {
            //Get lowest administrative level for location
            if (locationViewModel.AdminLevel3Value.HasValue)
                model.SearchCriteria.IdfsLocation = locationViewModel.AdminLevel3Value.Value;
            else if (locationViewModel.AdminLevel2Value.HasValue)
                model.SearchCriteria.IdfsLocation = locationViewModel.AdminLevel2Value.Value;
            else if (locationViewModel.AdminLevel1Value.HasValue)
                model.SearchCriteria.IdfsLocation = locationViewModel.AdminLevel1Value.Value;
            else
                model.SearchCriteria.IdfsLocation = null;
        }

        protected void ResetSearch()
        {
            //initialize new model with defaults
            InitializeModel();

            //set grid for not loaded
            isLoading = false;

            // set the defaults
            SetDefaults();

            //reset the cancellation token
            source = new();
            token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            expandSearchCriteria = true;
            showSearchResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearchClicked()
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

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogType", EIDSSDialogType.Warning);
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                DialogOptions dialogOptions = new DialogOptions()
                {
                    ShowTitle = true,
                    ShowClose = false
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(String.Empty, dialogParams, dialogOptions);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
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
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task GetFarmTypesAsync()
        {
            var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.AccessoryList, EIDSSConstants.HACodeList.LiveStockAndAvian);
            farmTypes = results.Where(t => t.IdfsBaseReference == EIDSSConstants.HACodeBaseReferenceIds.Livestock || t.IdfsBaseReference == EIDSSConstants.HACodeBaseReferenceIds.Avian).ToList();
        }

        #endregion

        #region Private Methods

        private void SetButtonStates()
        {
            if (expandSearchCriteria)
            {
                showSearchCriteriaButtons = true;
            }
            else
            {
                showSearchCriteriaButtons = false;
            }

            if (!model.FarmSearchPermissions.Create)
            {
                disableAddButton = true;
            }

            StateHasChanged();
        }

        private void SetDefaults()
        {
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;
        }

        private void InitializeModel()
        {
            // bottom admin level
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            model = new SearchFarmPageViewModel();
            model.FarmSearchPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToFarmsData);
            model.SearchCriteria.SortColumn = "EIDSSFarmID";
            model.SearchCriteria.SortOrder = "desc";
            model.SearchLocationViewModel = new()
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                EnableAdminLevel2 = true,
                EnableAdminLevel3 = bottomAdmin >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = bottomAdmin >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel4 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel5 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel6 = bottomAdmin > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
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
                AdminLevel0Value = Convert.ToInt64(base.CountryID)
            };
        }
        private bool HasCriteria(SearchFarmPageViewModel model)
        {
            PropertyInfo[] properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                if (prop.Name == "SelectedFarmTypes" && model.SearchCriteria.SelectedFarmTypes?.Count() > 0)
                {
                    return true;
                }
                if (prop.GetValue(model.SearchCriteria) != null)
                {
                    if (prop.PropertyType == typeof(System.String))
                    {
                        var value = prop.GetValue(model.SearchCriteria).ToString().Trim();
                        if (!string.IsNullOrWhiteSpace(value)) return true;
                        if (!string.IsNullOrEmpty(value)) return true;
                    }
                    else
                    {
                        return true;
                    }
                }
            }

            //Check the location
            if (model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                return true;

            return false;
        }

        #endregion

        #region Selected Records

        protected bool IsRecordSelected(FarmViewModel item)
        {
            try
            {
                if (FarmDeduplicationService.SelectedRecords != null)
                {
                    if (FarmDeduplicationService.SelectedRecords.Any(x => x.FarmMasterID == item.FarmMasterID))
                        return true;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        protected void RowSelectAsync(FarmViewModel item)
        {
            item.Selected = true;
            var selRecords = model.SearchResults.Where(s => s.Selected == true);
            if (selRecords != null)
            {
                if (selRecords.Count() > 2)
                {
                    var deSelRecord = model.SearchResults.FirstOrDefault(m => m.FarmMasterID == item.FarmMasterID);
                    if (deSelRecord != null)
                    {
                        deSelRecord.Selected = false;
                    }
                }
            }

            model.SearchResults.FirstOrDefault(m => m.FarmMasterID == item.FarmMasterID).Selected = item.Selected;
            RecordSelectionChangeAsync(item.Selected, item);
        }

        protected void RowDeSelectAsync(FarmViewModel item)
        {
            item.Selected = false;
            RecordSelectionChangeAsync(item.Selected, item);
        }

        protected void RecordSelectionChangeAsync(bool? value, FarmViewModel item)
        {
            try
            {
                IsSelectedRecordsLoading = true;

                if (SelectedRecords == null)
                    SelectedRecords = new List<FarmViewModel>();

                if (value == false)
                {
                    if (FarmDeduplicationService.SelectedRecords.Where(x => x.FarmMasterID == item.FarmMasterID).FirstOrDefault() != null)
                    {
                        FarmDeduplicationService.SelectedRecords.Remove(item);
                    }
                }
                else
                {
                    if (FarmDeduplicationService.SelectedRecords == null)
                        FarmDeduplicationService.SelectedRecords = new List<FarmViewModel>();

                    if (FarmDeduplicationService.SelectedRecords.Count < 2)
                        FarmDeduplicationService.SelectedRecords.Add(item);
                    else
                    {
                        if (FarmDeduplicationService.SelectedRecords.Where(x => x.FarmMasterID == item.FarmMasterID).FirstOrDefault() != null)
                        {
                            FarmDeduplicationService.SelectedRecords.Remove(item);
                            IsRecordSelected(item);
                        }
                    }
                }

                SelectedRecords = FarmDeduplicationService.SelectedRecords;
                if (SelectedRecords.Count == 2)
                    disableDeduplicateButton = false;
                else
                    disableDeduplicateButton = true;

                showDeduplicateButton = true;

                IsSelectedRecordsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
        protected async Task OnRemoveAsync(long? id)
        {
            try
            {
                IList<FarmViewModel> list = new List<FarmViewModel>();

                foreach (var record in FarmDeduplicationService.SelectedRecords)
                {
                    if (id != record.FarmMasterID && record.Selected == true)
                        list.Add(record);
                    else
                        record.Selected = false;
                }

                FarmDeduplicationService.SelectedRecords = list;
                SelectedRecords = FarmDeduplicationService.SelectedRecords;

                if (SelectedRecords.Count == 2)
                    disableDeduplicateButton = false;
                else
                    disableDeduplicateButton = true;

                await gridSelectedRecords.Reload();

                if (FarmDeduplicationService.SelectedRecords.Count == 0)
                {
                    FarmDeduplicationService.SearchRecords = null;
                    FarmDeduplicationService.SelectedRecords = null;
                    showDeduplicateButton = false;
                    disableDeduplicateButton = true;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task DeduplicateClickedAsync()
        {
            long id = 0;
            long id2 = 0;

            // persist search results before navigation
            model.SelectedRecords = SelectedRecords;
            await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmDeduplicationSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.FarmDeduplicationSearchModelKey, model);

            if (SelectedRecords.Count == 2)
            {
                id = (long)SelectedRecords[0].FarmMasterID;
                id2 = (long)SelectedRecords[1].FarmMasterID;
            }

            shouldRender = false;
            var path = "Administration/Deduplication/FarmDeduplication/Details";
            var query = $"?FarmMasterID={id}&FarmMasterID2={id2}";
            var uri = $"{NavManager.BaseUri}{path}{query}";
            NavManager.NavigateTo(uri, true);
        }

        #endregion Selected Records
    }
}
