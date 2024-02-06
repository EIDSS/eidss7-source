using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.Person.ViewModels;
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

namespace EIDSS.Web.Components.Administration.Deduplication.Person
{
    public class SearchPersonDeduplicationBase : PersonDeduplicationBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchPersonDeduplicationBase> Logger { get; set; }

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
        public IList<PersonViewModel> SelectedRecords { get; set; }
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

        protected RadzenDataGrid<PersonViewModel> grid;
        protected RadzenTemplateForm<PersonSearchPageViewModel> form;
        protected PersonSearchPageViewModel model;
        protected IEnumerable<BaseReferenceViewModel> personnelIDTypes;
        protected IEnumerable<BaseReferenceViewModel> genderIDTypes;
        protected bool personalIDDisabled;

        protected RadzenDataGrid<PersonViewModel> gridSelectedRecords;
        protected bool showDeduplicateButton;
        protected bool disableDeduplicateButton;

        #endregion

        #region Private Members

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            // reset the cancellation token
            source = new();
            token = source.Token;

            base.OnInitialized();

            _logger = Logger;

            InitializeModel();

            // see if a search was saved
            ProtectedBrowserStorageResult<bool> indictatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.PersonDeduplicationSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indictatorResult.Success ? indictatorResult.Value : false;
            if (searchPerformedIndicator && ShowSelectedRecordsIndicator)
            {
                ProtectedBrowserStorageResult<PersonSearchPageViewModel> searchModelResult = await BrowserStorage.GetAsync<PersonSearchPageViewModel>(SearchPersistenceKeys.PersonDeduplicationSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    model.SearchCriteria = searchModel.SearchCriteria;
                    model.SearchResults = searchModel.SearchResults;
                    count = model.SearchResults.Count();

                    if (ShowSelectedRecordsIndicator)
                    {
                        IsSelectedRecordsLoading = true;
                        SelectedRecords = searchModel.SelectedRecords;
                        PersonDeduplicationService.SelectedRecords = searchModel.SelectedRecords;
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
                // set grid for not loaded
                isLoading = false;

                // set the defaults
                SetDefaults();

                // set up the accordions
                expandSearchCriteria = true;
                showSearchCriteriaButtons = true;
                showSearchResults = false;

                if (PersonDeduplicationService.SelectedRecords == null)
                {
                    PersonDeduplicationService.SelectedRecords = new List<PersonViewModel>();
                    showDeduplicateButton = false;
                    disableDeduplicateButton = true;
                }
            }

            SetButtonStates();

            await base.OnInitializedAsync();
        }

        // MJK - disable search button not implemented
        //protected override async Task OnAfterRenderAsync(bool firstRender)
        //{
        //    await base.OnAfterRenderAsync(firstRender);

        //    //subscribe to the EditContext field changed event
        //    if (form != null)
        //    {
        //        form.EditContext.OnFieldChanged += EditContext_OnFieldChanged;
        //    }

        //}

        // MJK - disable search button not implemented
        //protected void EditContext_OnFieldChanged(object sender, FieldChangedEventArgs e)
        //{
        //    SetButtonStates();
        //}

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            try
            {
                // MJK - disable search button not implemented
                //if (form != null)
                //{
                //    form.EditContext.OnFieldChanged -= EditContext_OnFieldChanged;
                //}

                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
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
                var result = await DiagService.OpenAsync<EIDSSDialog>(string.Empty, dialogParams, dialogOptions);
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

        protected async Task PersonalIDTypeChangedAsync(object value)
        {
            if (Convert.ToInt64(value) == EIDSSConstants.PersonalIDTypes.Unknown)
            {
                model.SearchCriteria.PersonalID = null;
                personalIDDisabled = true;
            }
            else
            {
                personalIDDisabled = false;
            }
            await InvokeAsync(StateHasChanged);
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

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                isLoading = true;
                showSearchResults = true;

                var request = new HumanPersonSearchRequestModel();
                request.EIDSSPersonID = model.SearchCriteria.EIDSSPersonID;
                request.PersonalIDType = model.SearchCriteria.PersonalIDType;
                request.PersonalID = model.SearchCriteria.PersonalID;
                request.DateOfBirthFrom = model.SearchCriteria.DateOfBirthFrom;
                request.DateOfBirthTo = model.SearchCriteria.DateOfBirthTo;
                request.GenderTypeID = model.SearchCriteria.GenderTypeID;
                request.LastOrSurname = model.SearchCriteria.LastOrSurname;
                request.SecondName = model.SearchCriteria.SecondName;
                request.FirstOrGivenName = model.SearchCriteria.FirstOrGivenName;

                //Get lowest administrative level for location
                if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                    request.idfsLocation = model.SearchLocationViewModel.AdminLevel3Value.Value;
                else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                    request.idfsLocation = model.SearchLocationViewModel.AdminLevel2Value.Value;
                else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                    request.idfsLocation = model.SearchLocationViewModel.AdminLevel1Value.Value;
                else
                    request.idfsLocation = null;

                request.LanguageId = GetCurrentLanguage();

                // sorting
                if (args.Sorts.FirstOrDefault() != null)
                {
                    request.SortColumn = args.Sorts.FirstOrDefault().Property;
                    request.SortOrder = args.Sorts.FirstOrDefault().SortOrder.Value
                        .ToString().Replace("Ascending", "asc").Replace("Descending", "desc");
                }
                else
                {
                    request.SortColumn = "EIDSSPersonID";
                    request.SortOrder = "desc";
                }

                // paging
                if (args.Skip.HasValue && args.Skip.Value > 0 && searchSubmitted == false)
                {
                    request.Page = (args.Skip.Value / grid.PageSize) + 1;
                }
                else
                {
                    request.Page = 1;

                }
                request.PageSize = grid.PageSize != 0 ? grid.PageSize : 10;

                var result = await PersonClient.GetPersonList(request, token);
                if (source?.IsCancellationRequested == false)
                {
                    model.SearchResults = result;
                    count = model.SearchResults.FirstOrDefault() != null ? model.SearchResults.First().TotalRowCount : 0;
                    if (searchSubmitted) { await grid.FirstPage(); }
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

        protected async Task HandleValidSearchSubmit(PersonSearchPageViewModel model)
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

                searchSubmitted = false;
            }
            else
            {
                //no search criteria entered
                searchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
        }

        protected void LocationChanged(LocationViewModel locationViewModel)
        {
            //Get lowest administrative level for location
            if (locationViewModel.AdminLevel3Value.HasValue)
                model.SearchCriteria.idfsLocation = locationViewModel.AdminLevel3Value.Value;
            else if (locationViewModel.AdminLevel2Value.HasValue)
                model.SearchCriteria.idfsLocation = locationViewModel.AdminLevel2Value.Value;
            else if (locationViewModel.AdminLevel1Value.HasValue)
                model.SearchCriteria.idfsLocation = locationViewModel.AdminLevel1Value.Value;
            else
                model.SearchCriteria.idfsLocation = null;
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

        protected async Task SendReportLink(long humanMasterID)
        {
            try
            {
                if (Mode == SearchModeEnum.Import)
                {
                    if (CallbackUrl.EndsWith('/'))
                    {
                        CallbackUrl = CallbackUrl.Substring(0, CallbackUrl.Length - 1);
                    }

                    var url = CallbackUrl + $"?Id={humanMasterID}";

                    if (CallbackKey != null)
                    {
                        url += "&callbackkey=" + CallbackKey.ToString();
                    }
                    NavManager.NavigateTo(url, true);
                }
                else if (Mode == SearchModeEnum.Select)
                {

                    DiagService.Close(model.SearchResults.First(x => x.HumanMasterID == humanMasterID));
                }
                else
                {
                    // persist search results before navigation
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchModelKey, model);

                    shouldRender = false;
                    var uri = $"{NavManager.BaseUri}Human/Person/DetailsReviewPage/?id={humanMasterID}&reviewPageNo=3";
                    NavManager.NavigateTo(uri, true);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task GetPersonalIDTypesAsync(LoadDataArgs args)
        {
            personnelIDTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.PersonalIDType, null);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetGenderTypesAsync(LoadDataArgs args)
        {
            genderIDTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.HumanGender, null);
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

            // MJK - disable search button not implemented
            //if (HasCriteria(model))
            //{ disableSearchButton = false; }
            //else
            //    disableSearchButton = true;

            if (!model.PersonsListPermissions.Create)
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
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            model = new();
            model.SearchCriteria = new();
            model.SearchResults = new();
            count = 0;
            model.PersonsListPermissions = new();
            model.HumanDiseaseReportDataPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            model.PersonsListPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToPersonsList);
            model.SearchCriteria.SortColumn = "EIDSSPersonID";
            model.SearchCriteria.SortOrder = "desc";

            //initialize the location control
            model.SearchLocationViewModel = new()
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
                AdminLevel0Value = Convert.ToInt64(base.CountryID),
            };
        }

        private bool HasCriteria(PersonSearchPageViewModel model)
        {
            PropertyInfo[] properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
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

        protected bool IsRecordSelected(PersonViewModel item)
        {
            try
            {
                if (PersonDeduplicationService.SelectedRecords != null)
                {
                        if (PersonDeduplicationService.SelectedRecords.Any(x => x.HumanMasterID == item.HumanMasterID))
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

        protected async Task RowSelectAsync(PersonViewModel item)
        {
            item.Selected = true;
            var selRecords = model.SearchResults.Where(s => s.Selected == true);
            if (selRecords !=null)
            {
                if (selRecords.Count() > 2)
                {
                    var deSelRecord= model.SearchResults.FirstOrDefault(m => m.HumanMasterID == item.HumanMasterID);
                    if (deSelRecord !=null)
                    { 
                        deSelRecord.Selected = false;
                    }                    
                }
            }


            model.SearchResults.FirstOrDefault(m => m.HumanMasterID == item.HumanMasterID).Selected = item.Selected;
            RecordSelectionChange(item.Selected, item);

        }

        protected void RowDeSelect(PersonViewModel item)
        {
            item.Selected = false;
            RecordSelectionChange(item.Selected, item);
        }

        protected void RecordSelectionChange(bool? value, PersonViewModel item)
        {
            try
            {
                IsSelectedRecordsLoading = true;
                if (SelectedRecords == null)
                    SelectedRecords = new List<PersonViewModel>();

                if (value == false)
                {
                    if (PersonDeduplicationService.SelectedRecords.Where(x => x.HumanMasterID == item.HumanMasterID).FirstOrDefault() != null)
                    {
                        PersonDeduplicationService.SelectedRecords.Remove(item);
                    }
                }
                else
                {
                    if (PersonDeduplicationService.SelectedRecords == null)
                        PersonDeduplicationService.SelectedRecords = new List<PersonViewModel>();

                    if (PersonDeduplicationService.SelectedRecords.Count < 2)
                        PersonDeduplicationService.SelectedRecords.Add(item);
                    else
                    {
                        if (PersonDeduplicationService.SelectedRecords.Where(x => x.HumanMasterID == item.HumanMasterID).FirstOrDefault() != null)
                        {
                            PersonDeduplicationService.SelectedRecords.Remove(item);
                            IsRecordSelected(item);
                        }
                    }
                }

                SelectedRecords = model.SearchResults.Where(x => x.Selected).ToList();
                PersonDeduplicationService.SelectedRecords = PersonDeduplicationService.SelectedRecords
                    .Where(x => SelectedRecords.Select(y => y.HumanMasterID).Contains(x.HumanMasterID)).ToList();
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

        protected async Task OnRemoveAsync(long id)
        {
            try
            {
                IList<PersonViewModel> list = new List<PersonViewModel>();

                foreach (var record in PersonDeduplicationService.SelectedRecords)
                {
                    if (id != record.HumanMasterID && record.Selected == true)
                        list.Add(record);
                    else
                        record.Selected = false;
                }

                PersonDeduplicationService.SelectedRecords = list;
                SelectedRecords = PersonDeduplicationService.SelectedRecords;
                if (SelectedRecords.Count == 2)
                    disableDeduplicateButton = false;
                else
                    disableDeduplicateButton = true;

                await gridSelectedRecords.Reload();

                if (PersonDeduplicationService.SelectedRecords.Count == 0)
                {
                    PersonDeduplicationService.SearchRecords = null;
                    PersonDeduplicationService.SelectedRecords = null;
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
            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonDeduplicationSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonDeduplicationSearchModelKey, model);

            if (SelectedRecords.Count == 2)
            {
                id = SelectedRecords[0].HumanMasterID;
                id2 = SelectedRecords[1].HumanMasterID;
            }

            shouldRender = false;
            var path = "Administration/Deduplication/PersonDeduplication/Details";
            var query = $"?humanMasterID={id}&humanMasterID2={id2}";
            var uri = $"{NavManager.BaseUri}{path}{query}";
            //var uri = $"{NavManager.BaseUri}Administration/Deduplication/PersonDeduplication/Details";
            NavManager.NavigateTo(uri, true);
        }

        #endregion Selected Records
    }
}
