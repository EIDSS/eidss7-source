using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Areas.Human.ViewModels.Human;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
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

namespace EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport
{
    public class HumanDiseaseReportSearchDeduplicationBase : HumanDiseaseReportDeduplicationBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

       

        [Inject]
        private ILogger<HumanDiseaseReportSearchDeduplicationBase> Logger { get; set; }

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
        public IList<HumanDiseaseReportViewModel> SelectedRecords { get; set; }
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

       
        protected IEnumerable<BaseReferenceViewModel> personnelIDTypes;
        protected IEnumerable<BaseReferenceViewModel> genderIDTypes;
        protected bool personalIDDisabled;

        protected RadzenDataGrid<HumanDiseaseReportViewModel> gridSelectedRecords;
        protected bool showDeduplicateButton;
        protected bool disableDeduplicateButton;


        protected RadzenDataGrid<HumanDiseaseReportViewModel> grid;
        protected RadzenTemplateForm<SearchHumanDiseaseReportPageViewModel> form;
        protected SearchHumanDiseaseReportPageViewModel model;
        protected IEnumerable<FilteredDiseaseGetListViewModel> diseases;
        protected IEnumerable<BaseReferenceViewModel> reportStatuses;
        protected IEnumerable<BaseReferenceAdvancedListResponseModel> caseClassifications;
        protected IEnumerable<BaseReferenceViewModel> hospitalizationStatuses;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> sentByFacilities;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> receivedByFacilities;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> dataEntrySites;
        protected IEnumerable<BaseReferenceViewModel> outcomes;
        protected int diseaseCount;

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
            ProtectedBrowserStorageResult<bool> indictatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.HumanDiseaseReportDeduplicationSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indictatorResult.Success ? indictatorResult.Value : false;
            if (searchPerformedIndicator && ShowSelectedRecordsIndicator)
            {
                ProtectedBrowserStorageResult<SearchHumanDiseaseReportPageViewModel> searchModelResult = await BrowserStorage.GetAsync<SearchHumanDiseaseReportPageViewModel>(SearchPersistenceKeys.HumanDiseaseReportDeduplicationSearchModelKey);
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
                        HumanDiseaseReportDeduplicationService.SelectedRecords = searchModel.SelectedRecords;
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

                if (HumanDiseaseReportDeduplicationService.SelectedRecords == null)
                {
                    HumanDiseaseReportDeduplicationService.SelectedRecords = new List<HumanDiseaseReportViewModel>();
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

        //protected async Task PersonalIDTypeChangedAsync(object value)
        //{
        //    if (Convert.ToInt64(value) == EIDSSConstants.PersonalIDTypes.Unknown)
        //    {
        //        model.SearchCriteria.PersonalID = null;
        //        personalIDDisabled = true;
        //    }
        //    else
        //    {
        //        personalIDDisabled = false;
        //    }
        //    await InvokeAsync(StateHasChanged);
        //}

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

                var request = new HumanDiseaseReportSearchRequestModel();
                request.ReportID = model.SearchCriteria.ReportID;
                request.LegacyReportID = model.SearchCriteria.LegacyReportID;
                request.DiseaseID = model.SearchCriteria.DiseaseID;
                request.ReportStatusTypeID = model.SearchCriteria.ReportStatusTypeID;
                request.PatientFirstName = model.SearchCriteria.PatientFirstName;
                request.PatientMiddleName = model.SearchCriteria.PatientMiddleName;
                request.PatientLastName = model.SearchCriteria.PatientLastName;

                //Get lowest administrative level for location
                request.AdministrativeLevelID = Common.GetLocationId(model.SearchLocationViewModel);
                //if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                //    request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel3Value.Value;
                //else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                //    request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel2Value.Value;
                //else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                //    request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel1Value.Value;
                //else
                //    request.AdministrativeLevelID = null;

                //Get lowest administrative level for location of exposure
                if (model.SearchExposureLocationViewModel.AdminLevel3Value.HasValue)
                    request.LocationOfExposureAdministrativeLevelID = model.SearchExposureLocationViewModel.AdminLevel3Value.Value;
                else if (model.SearchExposureLocationViewModel.AdminLevel2Value.HasValue)
                    request.LocationOfExposureAdministrativeLevelID = model.SearchExposureLocationViewModel.AdminLevel2Value.Value;
                else if (model.SearchExposureLocationViewModel.AdminLevel1Value.HasValue)
                    request.LocationOfExposureAdministrativeLevelID = model.SearchExposureLocationViewModel.AdminLevel1Value.Value;
                else
                    request.LocationOfExposureAdministrativeLevelID = null;

                request.DateEnteredFrom = model.SearchCriteria.DateEnteredFrom;
                request.DateEnteredTo = model.SearchCriteria.DateEnteredTo;
                request.ClassificationTypeID = model.SearchCriteria.ClassificationTypeID;
                request.HospitalizationYNID = model.SearchCriteria.HospitalizationYNID;
                request.SentByFacilityID = model.SearchCriteria.SentByFacilityID;
                request.ReceivedByFacilityID = model.SearchCriteria.ReceivedByFacilityID;
                request.DataEntrySiteID = model.SearchCriteria.DataEntrySiteID;
                request.DateOfFinalCaseClassificationFrom = model.SearchCriteria.DateOfFinalCaseClassificationFrom;
                request.DateOfFinalCaseClassificationTo = model.SearchCriteria.DateOfFinalCaseClassificationTo;
                request.DateOfSymptomsOnsetFrom = model.SearchCriteria.DateOfSymptomsOnsetFrom;
                request.DateOfSymptomsOnsetTo = model.SearchCriteria.DateOfSymptomsOnsetTo;
                request.NotificationDateFrom = model.SearchCriteria.NotificationDateFrom;
                request.NotificationDateTo = model.SearchCriteria.NotificationDateTo;
                request.DiagnosisDateFrom = model.SearchCriteria.DiagnosisDateFrom;
                request.DiagnosisDateTo = model.SearchCriteria.DiagnosisDateTo;
                request.LocalOrFieldSampleID = model.SearchCriteria.LocalOrFieldSampleID;
                request.OutcomeID = model.SearchCriteria.OutcomeID;

                if (_tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel))
                    request.ApplySiteFiltrationIndicator = true;
                else
                    request.ApplySiteFiltrationIndicator = false;
                request.LanguageId = GetCurrentLanguage();
                request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                // sorting
                if (args.Sorts.FirstOrDefault() != null)
                {
                    request.SortColumn = args.Sorts.FirstOrDefault().Property;
                    request.SortOrder = args.Sorts.FirstOrDefault().SortOrder.Value
                        .ToString().Replace("Ascending", "asc").Replace("Descending", "desc");
                }
                else
                {
                    request.SortColumn = "ReportID";
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

                var result = await HumanDiseaseReportClient.GetHumanDiseaseReports(request, token);
                if (source?.IsCancellationRequested == false)
                {
                    model.SearchResults = result;
                    count = model.SearchResults.FirstOrDefault() != null ? model.SearchResults.First().RecordCount.Value : 0;
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

        protected async Task HandleValidSearchSubmit(SearchHumanDiseaseReportPageViewModel model)
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
            if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                model.SearchCriteria.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel3Value.Value;
            else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                model.SearchCriteria.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel2Value.Value;
            else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                model.SearchCriteria.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel1Value.Value;
            else
                model.SearchCriteria.AdministrativeLevelID = null;
        }

        protected void ExposureLocationChanged(LocationViewModel locationViewModel)
        {
            //Get lowest administrative level for location of exposure
            if (model.SearchExposureLocationViewModel.AdminLevel3Value.HasValue)
                model.SearchCriteria.LocationOfExposureAdministrativeLevelID = model.SearchExposureLocationViewModel.AdminLevel3Value.Value;
            else if (model.SearchExposureLocationViewModel.AdminLevel2Value.HasValue)
                model.SearchCriteria.LocationOfExposureAdministrativeLevelID = model.SearchExposureLocationViewModel.AdminLevel2Value.Value;
            else if (model.SearchExposureLocationViewModel.AdminLevel1Value.HasValue)
                model.SearchCriteria.LocationOfExposureAdministrativeLevelID = model.SearchExposureLocationViewModel.AdminLevel1Value.Value;
            else
                model.SearchCriteria.LocationOfExposureAdministrativeLevelID = null;
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

        //protected async Task SendReportLink(long humanMasterID)
        //{
        //    try
        //    {
        //        if (Mode == SearchModeEnum.Import)
        //        {
        //            if (CallbackUrl.EndsWith('/'))
        //            {
        //                CallbackUrl = CallbackUrl.Substring(0, CallbackUrl.Length - 1);
        //            }

        //            var url = CallbackUrl + $"?Id={humanMasterID}";

        //            if (CallbackKey != null)
        //            {
        //                url += "&callbackkey=" + CallbackKey.ToString();
        //            }
        //            NavManager.NavigateTo(url, true);
        //        }
        //        else if (Mode == SearchModeEnum.Select)
        //        {

        //            DiagService.Close(model.SearchResults.First(x => x.HumanMasterID == humanMasterID));
        //        }
        //        else
        //        {
        //            // persist search results before navigation
        //            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey, true);
        //            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchModelKey, model);

        //            shouldRender = false;
        //            var uri = $"{NavManager.BaseUri}Human/Person/DetailsReviewPage/?id={humanMasterID}&reviewPageNo=3";
        //            NavManager.NavigateTo(uri, true);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, ex.Message);
        //        throw;
        //    }
        //}

        //protected async Task GetPersonalIDTypesAsync(LoadDataArgs args)
        //{
        //    personnelIDTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.PersonalIDType, null);
        //    await InvokeAsync(StateHasChanged);
        //}

        //protected async Task GetGenderTypesAsync(LoadDataArgs args)
        //{
        //    genderIDTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.HumanGender, null);
        //}

        //#endregion

        //#region Private Methods

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

            //if (!model.PersonsListPermissions.Create)
            //{
            //    disableAddButton = true;
            //}

            StateHasChanged();
        }

        private void SetDefaults()
        {
            
            var systemPreferences = ConfigurationService.SystemPreferences;
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            model.SearchCriteria.DateEnteredTo = DateTime.Today;
            model.SearchCriteria.DateEnteredFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
           // model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
           // model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;
        }

        private void InitializeModel()
        {
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            model = new SearchHumanDiseaseReportPageViewModel();
            model.HumanDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanDiseaseReportData);
            model.SearchCriteria = new();
            model.SearchResults = new();
            model.BottomAdminLevel = _tokenService.GetAuthenticatedUser().BottomAdminLevel; //19000002 is level 2, 19000003 is level 3, etc
            model.SearchCriteria.SortColumn = "ReportID";
            model.SearchCriteria.SortOrder = "desc";


            // initialize the location control
            model.SearchLocationViewModel = new()
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                EnableAdminLevel2 = true,
                EnableAdminLevel3 = model.BottomAdminLevel >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel4 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel5 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel6 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = model.BottomAdminLevel >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel4 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel5 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel6 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
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

            // initialize the exposure location control
            model.SearchExposureLocationViewModel = new()
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                EnableAdminLevel2 = true,
                EnableAdminLevel3 = model.BottomAdminLevel >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel4 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel5 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                EnableAdminLevel6 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = model.BottomAdminLevel >= (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel4 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel5 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
                ShowAdminLevel6 = model.BottomAdminLevel > (long)EIDSSConstants.GISAdministrativeUnitTypes.Settlement ? true : false,
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

        private bool HasCriteria(SearchHumanDiseaseReportPageViewModel model)
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

            // Check the location
            if (model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                return true;

            // Check the location of exposure
            if (model.SearchExposureLocationViewModel.AdminLevel3Value.HasValue ||
                model.SearchExposureLocationViewModel.AdminLevel2Value.HasValue ||
                model.SearchExposureLocationViewModel.AdminLevel1Value.HasValue)
                return true;

            return false;
        }


        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = EIDSSConstants.HACodeList.HumanHACode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = EIDSSConstants.UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            diseaseCount = diseases.Count();
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSentByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = EIDSSConstants.HACodeList.HumanHACode,
                AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                OrganizationTypeID = null
            };
            sentByFacilities = await OrganizationClient.GetOrganizationAdvancedList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetReceivedByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = EIDSSConstants.HACodeList.HumanHACode,
                AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                OrganizationTypeID = null,
            };
            receivedByFacilities = await OrganizationClient.GetOrganizationAdvancedList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetEnteredByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = EIDSSConstants.HACodeList.HumanHACode,
                AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                OrganizationTypeID = null,
            };
            dataEntrySites = await OrganizationClient.GetOrganizationAdvancedList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetHospitalizationYNAsync()
        {
            hospitalizationStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.YesNoValueList, EIDSSConstants.HACodeList.HumanHACode);
        }

        protected async Task GetCaseClassificationsAsync(LoadDataArgs args)
        {
            var request = new BaseReferenceAdvancedListRequestModel()
            {
                advancedSearch = args.Filter,
                intHACode = EIDSSConstants.HACodeList.HumanHACode,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeName = EIDSSConstants.BaseReferenceConstants.CaseClassification,
                SortColumn = "intOrder",
                SortOrder = "asc"
            };
            caseClassifications = await CrossCuttingClient.GetBaseReferenceAdvanceList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetOutcomesAsync()
        {
            outcomes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.Outcome, EIDSSConstants.HACodeList.HumanHACode);
        }

        protected async Task GetReportStatusesAsync()
        {
            reportStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.CaseStatus, EIDSSConstants.HACodeList.HumanHACode);
        }

        //#endregion

        //#region Selected Records

        protected bool IsRecordSelected(HumanDiseaseReportViewModel item)
        {
            try
            {
                if (HumanDiseaseReportDeduplicationService.SelectedRecords != null)
                {
                    if (HumanDiseaseReportDeduplicationService.SelectedRecords.Any(x => x.ReportKey == item.ReportKey))
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

        protected async Task RowSelectAsync(HumanDiseaseReportViewModel item)
        {
            item.Selected = true;
            var selRecords = model.SearchResults.Where(s => s.Selected == true);
            if (selRecords != null)
            {
                if (selRecords.Count() > 2)
                {
                    var deSelRecord = model.SearchResults.FirstOrDefault(m => m.ReportKey == item.ReportKey);
                    if (deSelRecord != null)
                    {
                        deSelRecord.Selected = false;
                    }
                }
            }


            model.SearchResults.FirstOrDefault(m => m.ReportKey == item.ReportKey).Selected = item.Selected;
            RecordSelectionChange(item.Selected, item);

        }

        protected void RowDeSelect(HumanDiseaseReportViewModel item)
        {
            item.Selected = false;
            RecordSelectionChange(item.Selected, item);
        }

        protected void RecordSelectionChange(bool? value, HumanDiseaseReportViewModel item)
        {
            try
            {
                IsSelectedRecordsLoading = true;
                if (SelectedRecords == null)
                    SelectedRecords = new List<HumanDiseaseReportViewModel>();

                if (value == false)
                {
                    if (HumanDiseaseReportDeduplicationService.SelectedRecords.Where(x => x.ReportKey == item.ReportKey).FirstOrDefault() != null)
                    {
                        HumanDiseaseReportDeduplicationService.SelectedRecords.Remove(item);
                    }
                }
                else
                {
                    if (HumanDiseaseReportDeduplicationService.SelectedRecords == null)
                        HumanDiseaseReportDeduplicationService.SelectedRecords = new List<HumanDiseaseReportViewModel>();

                    if (HumanDiseaseReportDeduplicationService.SelectedRecords.Count < 2)
                        HumanDiseaseReportDeduplicationService.SelectedRecords.Add(item);
                    else
                    {
                        if (HumanDiseaseReportDeduplicationService.SelectedRecords.Where(x => x.ReportKey == item.ReportKey).FirstOrDefault() != null)
                        {
                            HumanDiseaseReportDeduplicationService.SelectedRecords.Remove(item);
                            IsRecordSelected(item);
                        }
                    }
                }

                SelectedRecords = HumanDiseaseReportDeduplicationService.SelectedRecords;
                if (SelectedRecords.Count == 2)
                {
                    var PersonID = SelectedRecords.FirstOrDefault().PersonID;
                    var isPersonMatch = SelectedRecords.All(a => a.PersonID == PersonID);
                    if (isPersonMatch)
                    {
                       // var secondItem= SelectedRecords.Skip(1).FirstOrDefault();

                       // var isDateOfOnsetMatch = SelectedRecords.FirstOrDefault().DateOfOnset == secondItem.DateOfOnset;
                        


                        
                        disableDeduplicateButton = false;
                    }
                    else
                        disableDeduplicateButton = true;
                }
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
                IList<HumanDiseaseReportViewModel> list = new List<HumanDiseaseReportViewModel>();

                foreach (var record in HumanDiseaseReportDeduplicationService.SelectedRecords)
                {
                    if (id != record.ReportKey && record.Selected == true)
                        list.Add(record);
                    else
                        record.Selected = false;
                }

                HumanDiseaseReportDeduplicationService.SelectedRecords = list;
                SelectedRecords = HumanDiseaseReportDeduplicationService.SelectedRecords;
                if (SelectedRecords.Count == 2)
                {
                    var PersonID = SelectedRecords.FirstOrDefault().PersonID;
                    var isPersonMatch = SelectedRecords.All(a => a.PersonID == PersonID);
                    if (isPersonMatch)
                    {
                        disableDeduplicateButton = false;
                    }
                    else
                        disableDeduplicateButton = true;
                }
                else
                    disableDeduplicateButton = true;

                await gridSelectedRecords.Reload();

                if (HumanDiseaseReportDeduplicationService.SelectedRecords.Count == 0)
                {
                    HumanDiseaseReportDeduplicationService.SearchRecords = null;
                    HumanDiseaseReportDeduplicationService.SelectedRecords = null;
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
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportDeduplicationSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportDeduplicationSearchModelKey, model);

            if (SelectedRecords.Count == 2)
            {
                id = SelectedRecords[0].ReportKey;
                id2 = SelectedRecords[1].ReportKey;
            }

            shouldRender = false;
            var path = "Administration/HumanDiseaseReportDeduplication/Details";
            var query = $"?humanDiseaseReportID={id}&humanDiseaseReportID2={id2}";
            var uri = $"{NavManager.BaseUri}{path}{query}";
            //var uri = $"{NavManager.BaseUri}Administration/Deduplication/PersonDeduplication/Details";
            NavManager.NavigateTo(uri, true);
        }

        #endregion Selected Records
    }
}
