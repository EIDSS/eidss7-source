using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Vector.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Components.Vector.SearchVectorSurveillanceSession;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using EIDSS.Web.ViewModels;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using Microsoft.JSInterop;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using System.Diagnostics;

namespace EIDSS.Web.Components.GridTesting
{
    public class GridTestBase : SearchComponentBase<SearchVectorSurveillanceSessionPageViewModel>, IDisposable
    {

        #region Grid Column
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public CrossCutting.GridExtensionBase gridExtension { get; set; }
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        #endregion
        #region Globals

        #region Dependencies


        [Inject]
        private IVectorClient VectorSurveillanceSessionClient { get; set; }

        [Inject]
        private IVectorTypeClient VectorTypeClient { get; set; }
        [Inject]
        private IJSRuntime JsRuntime { get; set; }
        [Inject]
        private IVectorSpeciesTypeClient VectorSpeciesTypeClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }
        

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private IDiseaseClient DiseaseClient { get; set; }

        [Inject]
        private ILogger<SearchVectorSurveillanceSessionBase> Logger { get; set; }

        #endregion

        #region Parameters

        #endregion Parameters

        #region Protected and Public Members
        #region Column Orders
        public int Col1 { get; set; }
        #endregion
        public enum SearchMode
        {
            Default,
            Import
        }
        protected RadzenDataGrid<VectorSurveillanceSessionViewModel> grid;
        protected RadzenTemplateForm<SearchVectorSurveillanceSessionPageViewModel> form;
        protected SearchVectorSurveillanceSessionPageViewModel model;
        protected IEnumerable<FilteredDiseaseGetListViewModel> diseases;
        protected IEnumerable<BaseReferenceViewModel> reportStatuses;
        protected IEnumerable<BaseReferenceEditorsViewModel> vectorTypes;
        protected IEnumerable<BaseReferenceEditorsViewModel> speciesTypes;
        protected IEnumerable<OrganizationGetListViewModel> sentByFacilities;
        protected IEnumerable<OrganizationGetListViewModel> receivedByFacilities;
        protected IEnumerable<OrganizationGetListViewModel> dataEntrySites;
        protected IEnumerable<BaseReferenceViewModel> outcomes;
        protected int diseaseCount;
        protected bool disableSpeciesType;
        protected int col3;
        #endregion

        #region Private Members
        private CancellationToken _token;
        #endregion

        #endregion

        #region Methods

        protected override void OnInitialized()
        {

            gridExtension = new GridExtensionBase();
           GridColumnLoad("searchResults");
            
            base.OnInitialized();
        }
        protected override async Task OnInitializedAsync()
        {


            GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);
            InitializeModel();
            ProtectedBrowserStorageResult<bool> indictatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indictatorResult.Success ? indictatorResult.Value : false;
            if (searchPerformedIndicator)
            {
                ProtectedBrowserStorageResult<SearchVectorSurveillanceSessionPageViewModel> searchModelResult = await BrowserStorage.GetAsync<SearchVectorSurveillanceSessionPageViewModel>(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;
                    model.SearchCriteria = searchModel.SearchCriteria;
                    model.SearchResults = searchModel.SearchResults;
                    model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                    count = model.SearchResults.Count();
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

        #region Grid Column Chooser Column Reorder
        /*
        
        Get Proper Reference To Grid 
        1.  Add Usings 
            using EIDSS.Domain.RequestModels.Configuration;
            using EIDSS.Domain.ResponseModels.Configuration;
            using EIDSS.Web.ViewModels;
            using EIDSS.Web.Components.CrossCutting;
            using EIDSS.ClientLibrary.ApiClients.Configuration;
            using System.Linq.Dynamic.Core;
           using EIDSS.Web.Services;
        using EIDSS.ClientLibrary;
          2.Inject  And create properties
          [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }
   
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
         [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        
        3. Set Properties on Grid:
            AllowColumnPicking="true" 
            AllowColumnReorder="true" 
            HeaderCellRender=@((args) => HeaderCellRender(args.Column.Property))
       
        4. For Each Column that is to be included in the ReOrdering, add to each column
            Reorderable="true" OrderIndex="@FindColumnOrder("PropertyName")" Visible="@GetColumnVisibility("PropertyName")" 
            If you do not want columns in the Pickable list set Pickable=false to each desired column
        5.  Add To OnInitializedAsync
        GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);
        6.Add Method or apply code to exsiting method
        protected override void OnInitialized()
        {
        gridExtension = new GridExtensionBase();
        Task.Run(async () => await GridColumnLoad(ActiveSurveillanceCampaign)).Wait(500);
        base.OnInitialized();
        }
        ADD TO UI
        
        7.Add 
        @using EIDSS.Web.Components.CrossCutting
        <GridExtension OnColumnSave="GridClickHandler"></GridExtension> to UI
        8.ADD @code{

        void GridClickHandler()
        {
        GridColumnSave(Column PropertyName);
        }

        } 
        9.private async Task StateContainerChangeAsync(string property)
        {

        await InvokeAsync(StateHasChanged);
        }
        10.
        public void HeaderCellRender(string propertyName)
        {
        GridContainerServices.VisibleColumnList.Add(propertyName);
        }
        */
        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig =  gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
                index = gridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }
        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = gridExtension.GetColumnVisibility(columnName);
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
                GridContainerServices.VisibleColumnList = gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
        private async Task StateContainerChangeAsync(string property)
        {

            await InvokeAsync(StateHasChanged);
        }
        #endregion



        public override async Task SetParametersAsync(ParameterView parameters)
        {
            await base.SetParametersAsync(parameters);
        }

        
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {



        }

        ///GRID TESTING FOR ROW REORDER ADDITIONAL CLASS AT END
        ///
        protected async Task GetReportStatusesAsync()
        {
            reportStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.VectorSurveillanceSessionStatus, EIDSSConstants.HACodeList.VectorHACode);
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
                dialogParams.Add("DialogName", "NarrowSearch");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
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

                    var request = new VectorSurveillanceSessionSearchRequestModel();
                    request.SessionID = model.SearchCriteria.SessionID;
                    request.FieldSessionID = model.SearchCriteria.FieldSessionID;
                    request.DiseaseID = model.SearchCriteria.DiseaseID;
                    request.StatusTypeID = model.SearchCriteria.StatusTypeID;
                    request.StartDateFrom = model.SearchCriteria.StartDateFrom;
                    request.StartDateTo = model.SearchCriteria.StartDateTo;
                    request.EndDateFrom = model.SearchCriteria.EndDateTo;
                    request.EndDateTo = model.SearchCriteria.EndDateTo;

                    //Get lowest administrative level for location
                    if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        request.AdministrativeLevelID = null;

                    request.VectorTypeID = string.IsNullOrEmpty(Convert.ToString(model.SearchCriteria.SelectedVectorTypeID)) ? null : Convert.ToString(model.SearchCriteria.SelectedVectorTypeID);
                    request.SpeciesTypeID = model.SearchCriteria.SpeciesTypeID;

                    if (_tokenService.GetAuthenticatedUser().SiteTypeId == ((long)SiteTypes.ThirdLevel))
                        request.ApplySiteFiltrationIndicator = true;
                    else
                        request.ApplySiteFiltrationIndicator = false;

                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    //sorting
                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "SessionID";
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

                    var result = await VectorSurveillanceSessionClient.GetVectorSurveillanceSessionListAsync(request, token);
                    if (source?.IsCancellationRequested == false)
                    {
                        model.SearchResults = result;
                        count = model.SearchResults.FirstOrDefault() != null ? model.SearchResults.First().RecordCount.Value : 0;
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
                model.SearchResults = new List<VectorSurveillanceSessionViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(SearchVectorSurveillanceSessionPageViewModel model)
        {
            if (form.IsValid && HasCriteria(model))
            {
                searchSubmitted = true;
                expandSearchCriteria = false;
                expandAdvancedSearchCriteria = false;
                SetButtonStates();

                if (grid != null)
                {
                    await grid.Reload();
                }
            }
            else
            {
                //no search criteria entered - display the EIDSS dialog component
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
            source = new();
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
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey, model);

            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/Add";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task OpenEdit(long sessionKey)
        {
            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey, model);

            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/Edit?sessionKey={sessionKey}";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLink(long sessionKey)
        {
            if (Mode == SearchModeEnum.Import)
            {
                if (CallbackUrl.EndsWith('/'))
                {
                    CallbackUrl = CallbackUrl.Substring(0, CallbackUrl.Length - 1);
                }

                var url = CallbackUrl + $"?Id={sessionKey}";

                if (CallbackKey != null)
                {
                    url += "&callbackkey=" + CallbackKey.ToString();
                }
                NavManager.NavigateTo(url, true);
            }
            else if (Mode == SearchModeEnum.Select)
            {
                DiagService.Close(model.SearchResults.First(x => x.SessionKey == sessionKey));
            }
            else
            {
                // persist search results before navigation
                await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchPerformedIndicatorKey, true);
                await BrowserStorage.SetAsync(SearchPersistenceKeys.VectorSurveillanceSessionSearchModelKey, model);

                shouldRender = false;
                var path = "Vector/VectorSurveillanceSession/SavedVectorSurveillanceSession";
                var query = $"?vectorSurveillanceSession={sessionKey}";
                var uri = $"{NavManager.BaseUri}{path}{query}";

                NavManager.NavigateTo(uri, true);
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = EIDSSConstants.HACodeList.VectorHACode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = EIDSSConstants.UsingType.StandardCaseType,
                AdvancedSearchTerm = string.IsNullOrEmpty(args.Filter) ? null : args.Filter.ToLowerInvariant()
            };
            diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            diseaseCount = diseases.Count();
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSpeciesTypesAsync(LoadDataArgs args)
        {
            try
            {
                if (!disableSpeciesType)
                {
                    var request = new VectorSpeciesTypesGetRequestModel()
                    {
                        IdfsVectorType = Convert.ToInt64(args.Filter),
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = "intOrder",
                        SortOrder = "asc"
                    };
                    speciesTypes = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(request);
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
                int page = 1;
                if (args.Skip.HasValue && args.Skip.Value > 0)
                {
                    page = (args.Skip.Value / 10) + 1;
                }
                else
                {
                    page = 1;
                }

                var request = new VectorTypesGetRequestModel()
                {
                    AdvancedSearch = args.Filter,
                    Page = 1,
                    PageSize = 99999,
                    LanguageId = GetCurrentLanguage(),
                    SortColumn = "intOrder",
                    SortOrder = "asc"
                };
                vectorTypes = await VectorTypeClient.GetVectorTypeList(request);
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
                    disableSpeciesType = false;
                    var request = new VectorSpeciesTypesGetRequestModel()
                    {
                        IdfsVectorType = Convert.ToInt64(selectedVectorType),
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = "intOrder",
                        SortOrder = "asc"
                    };
                    speciesTypes = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(request);
                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    model.SearchCriteria.SpeciesTypeID = null;
                    disableSpeciesType = true;
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
        }

        #endregion

        #region Private Methods

        private void SetButtonStates()
        {
            disableSpeciesType = true;

            if (expandSearchCriteria)
            {
                showSearchCriteriaButtons = true;
            }
            else
            {
                showSearchCriteriaButtons = false;
            }

            if (!model.VectorSurveillanceSessionPermissions.Create)
            {
                disableAddButton = true;
            }
        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            model.SearchCriteria.StartDateTo = DateTime.Today;
            model.SearchCriteria.StartDateFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
            model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;

        }

        private void InitializeModel()
        {

            model = new SearchVectorSurveillanceSessionPageViewModel();
            model.VectorSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVectorSurveillanceSession);
            model.BottomAdminLevel = _tokenService.GetAuthenticatedUser().BottomAdminLevel; //19000002 is level 2, 19000003 is level 3, etc
            model.SearchCriteria.SortColumn = "SessionID";
            model.SearchCriteria.SortOrder = "desc";

            //initialize the location control
            model.SearchLocationViewModel = new()
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = false,
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
                AdminLevel0Value = Convert.ToInt64(base.CountryID)
            };

        }

        private bool HasCriteria(SearchVectorSurveillanceSessionPageViewModel model)
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

        protected async Task PrintSearchResults()
        {
            if (form.IsValid)
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
                    else
                        LocationID = null;

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LanguageID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle",
                        Localizer.GetString(HeadingResourceKeyConstants
                            .VeterinaryAggregateDiseaseReportSummarySearchHeading)); // "Weekly Reporting List"); 
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);

                    // optional parameters
                    //reportModel.AddParameter("ReportKey", model.SearchCriteria.PersonalIDType.ToString());
                    //reportModel.AddParameter("ReportID", model.SearchCriteria.PersonalID);
                    //reportModel.AddParameter("LegacyReportID", model.SearchCriteria.FirstOrGivenName);
                    //reportModel.AddParameter("@SessionKey", model.SearchCriteria.SecondName);
                    //reportModel.AddParameter("LastOrSurname", model.SearchCriteria.LastOrSurname);
                    //reportModel.AddParameter("DateOfBirthFrom", model.SearchCriteria.DateOfBirthFrom.ToString());
                    //reportModel.AddParameter("DateOfBirthTo", model.SearchCriteria.DateOfBirthTo.ToString());
                    //reportModel.AddParameter("GenderTypeID", model.SearchCriteria.GenderTypeID.ToString());
                    //reportModel.AddParameter("EIDSSPersonID", model.SearchCriteria.EIDSSPersonID);
                    //reportModel.AddParameter("idfsLocation", LocationID.ToString());

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
                            Width = "1050px",
                            //Height = "600px"
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
