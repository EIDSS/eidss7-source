#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Outbreak.ViewModels.Case;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case.Veterinary.SearchCase
{
    public class SearchVeterinaryCaseBase : SearchComponentBase<SearchVeterinaryCasePageViewModel>, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IOutbreakClient OutbreakClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ILogger<SearchVeterinaryCaseBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public VeterinaryReportTypeEnum ReportType { get; set; }
        [Parameter] public bool RefreshResultsIndicator { get; set; }

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<VeterinaryCaseGetListViewModel> Grid;
        protected RadzenTemplateForm<SearchVeterinaryCasePageViewModel> Form;
        protected SearchVeterinaryCasePageViewModel Model;
        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases;
        protected IEnumerable<BaseReferenceViewModel> ReportStatuses;
        protected IEnumerable<BaseReferenceViewModel> ReportTypes;
        protected IEnumerable<BaseReferenceAdvancedListResponseModel> CaseClassifications;
        protected IEnumerable<BaseReferenceViewModel> SpeciesTypes;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> DataEntrySites;

        #endregion

        #region Private Members

        private int? _haCode;

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            InitializeModel();
            
            // see if a search was saved
            var indicatorResult = await BrowserStorage.GetAsync<bool>(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchPerformedIndicatorKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult.Success && indicatorResult.Value;
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<SearchVeterinaryCasePageViewModel>(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchModelKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;

                    // see if there is a session refresh indicator
                    var refreshResult = await SessionState.GetAsync<bool>("EIDSS",StateKeys.RefreshIndicator);
                    var refreshIndicator = refreshResult.Success && refreshResult.Value;

                    // Disease report was deleted, so refresh the persisted results.
                    if (RefreshResultsIndicator 
                        || refreshIndicator)
                    {
                        searchSubmitted = true;
                        if (Grid != null)
                            await Grid.Reload();

                        // Update persisted search results after disease report deleted.
                        await BrowserStorage.SetAsync(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchPerformedIndicatorKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchPerformedIndicatorKey, true);
                        await BrowserStorage.SetAsync(
                            ReportType == VeterinaryReportTypeEnum.Avian
                                ? SearchPersistenceKeys.AvianVeterinaryCaseSearchModelKey
                                : SearchPersistenceKeys.LivestockVeterinaryCaseSearchModelKey, Model);
                    }
                    else
                    {
                        Model.SearchResults = searchModel.SearchResults;
                        count = Model.SearchResults.Count;
                    }

                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;

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

            // set the refresh indicator to false if set 
            await SessionState.SetAsync("EIDSS",StateKeys.RefreshIndicator, false);

            SetButtonStates();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (Mode == SearchModeEnum.Import)
                {
                    _haCode = HACodeList.AllHACode;
                    Model.SearchCriteria.SpeciesTypeID = null;
                }

                Model.SearchCriteria.DiseaseID = DiseaseId;
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
                Logger.LogError(ex, ex.Message);
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

                //advanced search toggle
                case 1:
                    expandAdvancedSearchCriteria = !expandAdvancedSearchCriteria;
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

                var dialogParams = new Dictionary<string, object>
                {
                    { "DialogName", "NarrowSearch" },
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage) }
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
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
                Logger.LogError(ex, ex.Message);
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

                    var request = new VeterinaryCaseSearchRequestModel
                    {
                        CaseID = Model.SearchCriteria.CaseID,
                        LegacyCaseID = Model.SearchCriteria.LegacyCaseID,
                        SpeciesTypeID = Model.SearchCriteria.SpeciesTypeID,
                        DiseaseID = Model.SearchCriteria.DiseaseID,
                        ReportStatusTypeID = Model.SearchCriteria.ReportStatusTypeID,
                        ReportTypeID = Model.SearchCriteria.ReportTypeID
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
                    request.ClassificationTypeID = Model.SearchCriteria.ClassificationTypeID;
                    request.DiagnosisDateFrom = Model.SearchCriteria.DiagnosisDateFrom;
                    request.DiagnosisDateTo = Model.SearchCriteria.DiagnosisDateTo;
                    request.InvestigationDateFrom = Model.SearchCriteria.InvestigationDateFrom;
                    request.InvestigationDateTo = Model.SearchCriteria.InvestigationDateTo;
                    request.LocalOrFieldSampleID = Model.SearchCriteria.LocalOrFieldSampleID;
                    request.TotalAnimalQuantityFrom = Model.SearchCriteria.TotalAnimalQuantityFrom;
                    request.TotalAnimalQuantityTo = Model.SearchCriteria.TotalAnimalQuantityTo;
                    request.SessionID = Model.SearchCriteria.SessionID;
                    request.DataEntrySiteID = Model.SearchCriteria.DataEntrySiteID;
                    request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel);
                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    //sorting
                    request.SortColumn = !IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "CaseID";
                    request.SortOrder = args.Sorts.FirstOrDefault() != null ? SortConstants.Descending : SortConstants.Ascending;
                    //paging
                    if (args.Skip is > 0)
                    {
                        request.Page = (args.Skip.Value / Grid.PageSize) + 1;
                    }
                    else
                    {
                        request.Page = 1;
                    }
                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;

                    var result = await OutbreakClient.GetVeterinaryCaseList(request, token);
                    if (source.IsCancellationRequested == false)
                    {
                        Model.SearchResults = result;
                        count = Model.SearchResults.FirstOrDefault() != null ? Model.SearchResults.First().TotalRowCount : 0;
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
                Model.SearchResults = new List<VeterinaryCaseGetListViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(SearchVeterinaryCasePageViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                searchSubmitted = true;
                expandSearchCriteria = false;
                expandAdvancedSearchCriteria = false;
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

        // 
        protected void PrintSearch()
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

        protected async Task OpenEdit(long? farmId, long diseaseReportId)
        {
            long reportTypeId;
            if (ReportType == VeterinaryReportTypeEnum.Livestock)
            {
                reportTypeId = (long)CaseTypeEnum.Livestock;
            }
            else
            {
                reportTypeId = (long)CaseTypeEnum.Avian;
            }

            // persist search results before navigation
            await BrowserStorage.SetAsync(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchPerformedIndicatorKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchModelKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchModelKey, Model);

            // set the refresh indicator in case user comes back after edit
            await SessionState.SetAsync("EIDSS",StateKeys.RefreshIndicator, true);

            shouldRender = false;
            const string path = "Veterinary/VeterinaryDiseaseReport/Details";
            var query = $"?reportTypeID={reportTypeId}&farmID={farmId}&diseaseReportID={diseaseReportId}&isEdit=true";
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLink(long? farmId, long caseId)
        {
            switch (Mode)
            {
                case SearchModeEnum.Select:
                    DiagService.Close(Model.SearchResults.First(x => x.CaseKey == caseId));
                    break;
                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close(Model.SearchResults.First(x => x.CaseKey == caseId));
                    break;
                default:
                {
                    long reportTypeId;
                    if (ReportType == VeterinaryReportTypeEnum.Livestock)
                    {
                        reportTypeId = (long)CaseTypeEnum.Livestock;
                    }
                    else
                    {
                        reportTypeId = (long)CaseTypeEnum.Avian;
                    }

                    // persist search results before navigation
                    await BrowserStorage.SetAsync(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchPerformedIndicatorKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(ReportType == VeterinaryReportTypeEnum.Avian ? SearchPersistenceKeys.AvianVeterinaryCaseSearchModelKey : SearchPersistenceKeys.LivestockVeterinaryCaseSearchModelKey, Model);

                    shouldRender = false;
                    const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                    var query = $"?reportTypeID={reportTypeId}&farmID={farmId}&diseaseReportID={caseId}&isReadOnly=true";
                    var uri = $"{NavManager.BaseUri}{path}{query}";

                    NavManager.NavigateTo(uri, true);
                    break;
                }
            }
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = _haCode.Value,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSpeciesTypesAsync()
        {
            SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseType, HACodeList.LiveStockAndAvian);
        }

        protected async Task GetEnteredByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = HACodeList.LiveStockAndAvian,
                AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationWithSite,
                OrganizationTypeID = null,
            };
            DataEntrySites = await OrganizationClient.GetOrganizationAdvancedList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetCaseClassificationsAsync(LoadDataArgs args)
        {
            var request = new BaseReferenceAdvancedListRequestModel()
            {
                advancedSearch = args.Filter,
                intHACode = HACodeList.LiveStockAndAvian,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeName = BaseReferenceConstants.CaseClassification,
                SortColumn = "intOrder",
                SortOrder = SortConstants.Ascending
            };
            CaseClassifications = await CrossCuttingClient.GetBaseReferenceAdvanceList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetReportTypesAsync()
        {
            ReportTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseReportType, _haCode);
        }

        protected async Task GetReportStatusesAsync()
        {
            ReportStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseStatus, HACodeList.HumanHACode);
        }

        #endregion

        #region Private Methods

        private void SetButtonStates()
        {
            if (expandSearchCriteria || expandAdvancedSearchCriteria)
            {
                showSearchCriteriaButtons = true;
            }
            else
            {
                showSearchCriteriaButtons = false;
            }
        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            var authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (authenticatedUser is not null)
            {
                var userPreferences = ConfigurationService.GetUserPreferences(authenticatedUser.UserName);

                Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? authenticatedUser.RegionId : null;
                Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? authenticatedUser.RayonId : null;
            }

            Model.SearchCriteria.DateEnteredTo = DateTime.Today;
            Model.SearchCriteria.DateEnteredFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);

            //Locks out the disease field, when used from Outbreak Human Case
            Model.SearchCriteria.DiseaseID = DiseaseId;
        }

        private void InitializeModel()
        {
            _haCode = ReportType == VeterinaryReportTypeEnum.Livestock ? HACodeList.LivestockHACode : HACodeList.AvianHACode;

            Model = new SearchVeterinaryCasePageViewModel
            {
                VeterinaryCasePermissions = GetUserPermissions(PagePermission.AccessToOutbreakVeterinaryCaseData),
                SearchCriteria =
                {
                    SortColumn = "CaseID",
                    SortOrder = SortConstants.Descending,
                    //set the species type based on avian or livestock disease report and disable
                    SpeciesTypeID = ReportType == VeterinaryReportTypeEnum.Livestock ? CaseTypes.Livestock : CaseTypes.Avian
                },
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

        private static bool HasCriteria(SearchVeterinaryCasePageViewModel model)
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
                var model = Model;

                var nGridCount = Grid.Count;
                try
                {
                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    switch (ReportType)
                    {
                        // see if we are Avian or Livestock
                        case VeterinaryReportTypeEnum.Avian:
                            reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportPageHeading));
                            break;
                        case VeterinaryReportTypeEnum.Livestock:
                            reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportPageHeading));
                            break;
                    }

                    //sorting
                    reportModel.AddParameter("sortColumn", "CaseID");
                    reportModel.AddParameter("sortOrder", SortConstants.Descending);
                    reportModel.AddParameter("pageSize", nGridCount.ToString());
                    
                    //Get lowest administrative level for location
                    if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        model.SearchCriteria.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        model.SearchCriteria.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        model.SearchCriteria.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        model.SearchCriteria.AdministrativeLevelID = null;

                    reportModel.AddParameter("PersonID", _tokenService.GetAuthenticatedUser().PersonId); 
                    reportModel.AddParameter("ReportKey", Model.SearchCriteria.CaseKey.ToString());
                    reportModel.AddParameter("ReportID", Model.SearchCriteria.CaseID);
                    reportModel.AddParameter("LegacyReportID", Model.SearchCriteria.LegacyCaseID);
                    reportModel.AddParameter("SessionKey", Model.SearchCriteria.SessionKey.ToString());
                    reportModel.AddParameter("FarmMasterID", Model.SearchCriteria.FarmMasterID.ToString());
                    reportModel.AddParameter("DiseaseID", Model.SearchCriteria.DiseaseID.ToString());
                    reportModel.AddParameter("ReportStatusTypeID", Model.SearchCriteria.ReportStatusTypeID.ToString());
                    reportModel.AddParameter("AdministrativeLevelID", Model.SearchCriteria.AdministrativeLevelID.ToString());
                    if (Model.SearchCriteria.DateEnteredFrom != null)
                        reportModel.AddParameter("DateEnteredFrom", Model.SearchCriteria.DateEnteredFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateEnteredTo != null)
                        reportModel.AddParameter("DateEnteredTo", Model.SearchCriteria.DateEnteredTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("ClassificationTypeID", Model.SearchCriteria.ClassificationTypeID.ToString());
                    reportModel.AddParameter("ReportTypeID", Model.SearchCriteria.ReportTypeID.ToString());
                    reportModel.AddParameter("SpeciesTypeID", Model.SearchCriteria.SpeciesTypeID.ToString());
                    if (Model.SearchCriteria.DiagnosisDateFrom != null)
                        reportModel.AddParameter("DiagnosisDateFrom", Model.SearchCriteria.DiagnosisDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DiagnosisDateTo != null)
                        reportModel.AddParameter("DiagnosisDateTo", Model.SearchCriteria.DiagnosisDateTo.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.InvestigationDateFrom != null)
                        reportModel.AddParameter("InvestigationDateFrom", Model.SearchCriteria.InvestigationDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.InvestigationDateTo != null)
                        reportModel.AddParameter("InvestigationDateTo", Model.SearchCriteria.InvestigationDateTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("LocalOrFieldSampleID", Model.SearchCriteria.LocalOrFieldSampleID);
                    reportModel.AddParameter("TotalAnimalQuantityFrom", Model.SearchCriteria.TotalAnimalQuantityFrom.ToString());
                    reportModel.AddParameter("TotalAnimalQuantityTo", Model.SearchCriteria.TotalAnimalQuantityTo.ToString());
                    reportModel.AddParameter("SessionID", Model.SearchCriteria.SessionID);
                    reportModel.AddParameter("DataEntrySiteID", Model.SearchCriteria.DataEntrySiteID.ToString());
                    reportModel.AddParameter("UserEmployeeID", _tokenService.GetAuthenticatedUser().PersonId);
                    reportModel.AddParameter("UserOrganizationID", _tokenService.GetAuthenticatedUser().OfficeId.ToString());
                    reportModel.AddParameter("UserSiteID", _tokenService.GetAuthenticatedUser().SiteId);
                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId >= (long) SiteTypes.ThirdLevel ? "1" : "0");

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.VeterinaryDiseaseReportsListHeading),
                        new Dictionary<string, object> { { "ReportName", "SearchForAnimalDiseaseReport" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.VeterinaryDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px",
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
