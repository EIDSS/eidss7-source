using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Veterinary.ViewModels.Veterinary;
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
using EIDSS.Web.Areas.Veterinary.ViewModels.VeterinaryDiseaseReport;
using EIDSS.Web.ViewModels;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Administration.Deduplication.VeterinaryDiseaseReport
{
    public class SearchVeterinaryDiseaseReportDeduplicationBase : VeterinaryDiseaseReportDeduplicationBaseComponent, IDisposable
    {
        #region Dependencies

        [Inject]
        private IVeterinaryClient VeterinaryClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchVeterinaryDiseaseReportDeduplicationBase> Logger { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        #endregion

        #region Parameters
        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public VeterinaryReportTypeEnum ReportType { get; set; }

        //[Parameter]
        //public bool RefreshResultsIndicator { get; set; }

        [Parameter]
        public bool ShowSelectedRecordsIndicator { get; set; }

        #endregion

        #region Properties
        public bool IsSelectedRecordsLoading { get; set; }
        public IList<VeterinaryDiseaseReportViewModel> SelectedRecords { get; set; }
        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> grid;
        protected RadzenTemplateForm<SearchVeterinaryDiseaseReportPageViewModel> form;
        protected SearchVeterinaryDiseaseReportPageViewModel model;
        protected IEnumerable<FilteredDiseaseGetListViewModel> diseases;
        protected IEnumerable<BaseReferenceViewModel> reportStatuses;
        protected IEnumerable<BaseReferenceViewModel> reportTypes;
        protected IEnumerable<BaseReferenceAdvancedListResponseModel> caseClassifications;
        protected IEnumerable<BaseReferenceViewModel> speciesTypes;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> dataEntrySites;

        protected RadzenDataGrid<VeterinaryDiseaseReportViewModel> gridSelectedRecords;
        protected bool showDeduplicateButton;
        protected bool disableDeduplicateButton;

        protected int count;
        protected bool shouldRender = true;
        protected bool isLoading;
        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool showSearchResults;
        protected bool showSearchCriteriaButtons;
        protected bool searchSubmitted;

        protected CancellationTokenSource source;
        protected CancellationToken token;

        #endregion

        #region Private Members

        private int? haCode;

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            // reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            _logger = Logger;

            InitializeModel();

            // see if a search was saved
            ProtectedBrowserStorageResult<bool> indictatorResult;
            if (ReportType == VeterinaryReportTypeEnum.Livestock)
                indictatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.LivestockDiseaseReportDeduplicationSearchPerformedIndicatorKey);
            else
                indictatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.AvianDiseaseReportDeduplicationSearchPerformedIndicatorKey);

            var searchPerformedIndicator = indictatorResult.Success && indictatorResult.Value;
            if (searchPerformedIndicator && ShowSelectedRecordsIndicator)
            {
                ProtectedBrowserStorageResult<SearchVeterinaryDiseaseReportPageViewModel> searchModelResult;
                if (ReportType == VeterinaryReportTypeEnum.Livestock)
                    searchModelResult = await BrowserStorage.GetAsync<SearchVeterinaryDiseaseReportPageViewModel>(SearchPersistenceKeys.LivestockDiseaseReportDeduplicationSearchModelKey);
                else
                    searchModelResult = await BrowserStorage.GetAsync<SearchVeterinaryDiseaseReportPageViewModel>(SearchPersistenceKeys.AvianDiseaseReportDeduplicationSearchModelKey);

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
                        VeterinaryDiseaseReportDeduplicationService.SelectedRecords = searchModel.SelectedRecords;
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

                //advanced search toggle
                case 1:
                    expandAdvancedSearchCriteria = !expandAdvancedSearchCriteria;
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

                var dialogParams = new Dictionary<string, object>
                {
                    { "DialogName", "NarrowSearch" },
                    { nameof(EIDSSDialog.DialogButtons), buttons },
                    { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage) }
                };
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

                    var request = new VeterinaryDiseaseReportSearchRequestModel
                    {
                        ReportID = model.SearchCriteria.ReportID,
                        LegacyReportID = model.SearchCriteria.LegacyReportID,
                        SpeciesTypeID = model.SearchCriteria.SpeciesTypeID,
                        DiseaseID = model.SearchCriteria.DiseaseID,
                        ReportStatusTypeID = model.SearchCriteria.ReportStatusTypeID,
                        ReportTypeID = model.SearchCriteria.ReportTypeID
                    };

                    //Get lowest administrative level for location
                    if (model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                        request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel3Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                        request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel2Value.Value;
                    else if (model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                        request.AdministrativeLevelID = model.SearchLocationViewModel.AdminLevel1Value.Value;
                    else
                        request.AdministrativeLevelID = null;

                    request.DateEnteredFrom = model.SearchCriteria.DateEnteredFrom;
                    request.DateEnteredTo = model.SearchCriteria.DateEnteredTo;
                    request.ClassificationTypeID = model.SearchCriteria.ClassificationTypeID;
                    request.DiagnosisDateFrom = model.SearchCriteria.DiagnosisDateFrom;
                    request.DiagnosisDateTo = model.SearchCriteria.DiagnosisDateTo;
                    request.InvestigationDateFrom = model.SearchCriteria.InvestigationDateFrom;
                    request.InvestigationDateTo = model.SearchCriteria.InvestigationDateTo;
                    request.LocalOrFieldSampleID = model.SearchCriteria.LocalOrFieldSampleID;
                    request.TotalAnimalQuantityFrom = model.SearchCriteria.TotalAnimalQuantityFrom;
                    request.TotalAnimalQuantityTo = model.SearchCriteria.TotalAnimalQuantityTo;
                    request.SessionID = model.SearchCriteria.SessionID;
                    request.IncludeSpeciesListIndicator = true;
                    request.DataEntrySiteID = model.SearchCriteria.DataEntrySiteID;

                    if (_tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel))
                        request.ApplySiteFiltrationIndicator = true;
                    else
                        request.ApplySiteFiltrationIndicator = false;
                    request.LanguageId = GetCurrentLanguage();
                    request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                    request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                    request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                    //sorting
                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "ReportID";
                    request.SortOrder = args.Sorts.FirstOrDefault() != null ? SortConstants.Descending : SortConstants.Descending;
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

                    var result = await VeterinaryClient.GetVeterinaryDiseaseReportListAsync(request, token);
                    result = result.DistinctBy(r => r.ReportID).ToList();
                    if (source.IsCancellationRequested == false)
                    {
                        model.SearchResults = result;
                        count = model.SearchResults.FirstOrDefault() != null ? model.SearchResults.First().TotalRowCount : 0;
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
                //initialize the grid so that it displays 'No records message'
                model.SearchResults = new List<VeterinaryDiseaseReportViewModel>();
                count = 0;
                isLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(SearchVeterinaryDiseaseReportPageViewModel model)
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
            expandAdvancedSearchCriteria = false;
            showSearchResults = false;
            SetButtonStates();
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {

            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = haCode.Value,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = EIDSSConstants.UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSpeciesTypesAsync()
        {
            speciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.CaseType, EIDSSConstants.HACodeList.LiveStockAndAvian);
        }

        protected async Task GetEnteredByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = HACodeList.LiveStockAndAvian,
                AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationWithSite,
                OrganizationTypeID = null,
            };
            dataEntrySites = await OrganizationClient.GetOrganizationAdvancedList(request);
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
                SortOrder = "asc"
            };
            caseClassifications = await CrossCuttingClient.GetBaseReferenceAdvanceList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetReportTypesAsync()
        {
            reportTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseReportType, haCode);
        }

        protected async Task GetReportStatusesAsync()
        {
            reportStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.CaseStatus, EIDSSConstants.HACodeList.HumanHACode);
        }

        protected async Task PrintSearchResults()
        {
            if (form.IsValid)
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
                        reportModel.AddParameter("LangID", GetCurrentLanguage());
                        reportModel.AddParameter("ReportTitle",
                            Localizer.GetString(HeadingResourceKeyConstants
                                .VeterinaryAggregateDiseaseReportSummarySearchHeading)); // "Weekly Reporting List"); 
                        reportModel.AddParameter("PersonID", authenticatedUser.PersonId);

                        // optional parameters
                        //reportModel.AddParameter("PersonalIDType", model.SearchCriteria.PersonalIDType.ToString());
                        //reportModel.AddParameter("PersonalID", model.SearchCriteria.PersonalID);
                        //reportModel.AddParameter("FirstOrGivenName", model.SearchCriteria.FirstOrGivenName);
                        //reportModel.AddParameter("SecondName", model.SearchCriteria.SecondName);
                        //reportModel.AddParameter("LastOrSurname", model.SearchCriteria.LastOrSurname);
                        //reportModel.AddParameter("DateOfBirthFrom", model.SearchCriteria.DateOfBirthFrom.ToString());
                        //reportModel.AddParameter("DateOfBirthTo", model.SearchCriteria.DateOfBirthTo.ToString());
                        //reportModel.AddParameter("GenderTypeID", model.SearchCriteria.GenderTypeID.ToString());
                        //reportModel.AddParameter("EIDSSPersonID", model.SearchCriteria.EIDSSPersonID);
                        //reportModel.AddParameter("idfsLocation", LocationID.ToString());

                        if (_tokenService.GetAuthenticatedUser().SiteTypeId >= ((long) SiteTypes.ThirdLevel))
                            reportModel.AddParameter("ApplySiteFiltrationIndicator", "1");
                        else
                            reportModel.AddParameter("ApplySiteFiltrationIndicator", "0");

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

                model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? authenticatedUser.RegionId : null;
                model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? authenticatedUser.RayonId : null;
            }

            model.SearchCriteria.DateEnteredTo = DateTime.Today;
            model.SearchCriteria.DateEnteredFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
        }

        private void InitializeModel()
        {

            if (ReportType == VeterinaryReportTypeEnum.Livestock)
                haCode = HACodeList.LivestockHACode;
            else
                haCode = HACodeList.AvianHACode;

            model = new SearchVeterinaryDiseaseReportPageViewModel
            {
                VeterinaryDiseaseReportPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData)
            };
            model.SearchCriteria.SortColumn = "ReportID";
            model.SearchCriteria.SortOrder = SortConstants.Descending;

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
                AdminLevel0Value = Convert.ToInt64(base.CountryID)

            };

            //set the species type based on avian or livestock disease report and disable
            if (ReportType == VeterinaryReportTypeEnum.Livestock)
            {
                model.SearchCriteria.SpeciesTypeID = CaseTypes.Livestock;
            }
            else
            {
                model.SearchCriteria.SpeciesTypeID = CaseTypes.Avian;
            }
        }

        private static bool HasCriteria(SearchVeterinaryDiseaseReportPageViewModel model)
        {
            PropertyInfo[] properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                if (prop.GetValue(model.SearchCriteria) != null)
                {
                    if (prop.PropertyType == typeof(string))
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
        protected bool IsRecordSelected(VeterinaryDiseaseReportViewModel item)
        {
            try
            {
                if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords != null)
                {
                    if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Any(x => x.ReportKey == item.ReportKey))
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

        protected async Task RowSelectAsync(VeterinaryDiseaseReportViewModel item)
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
            await RecordSelectionChangeAsync(item.Selected, item);
        }

        protected async Task RowDeSelectAsync(VeterinaryDiseaseReportViewModel item)
        {
            item.Selected = false;
            await RecordSelectionChangeAsync(item.Selected, item);
        }

        protected async Task RecordSelectionChangeAsync(bool? value, VeterinaryDiseaseReportViewModel item)
        {
            try
            {
                IsSelectedRecordsLoading = true;

                if (SelectedRecords == null)
                    SelectedRecords = new List<VeterinaryDiseaseReportViewModel>();

                if (value == false)
                {
                    if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Where(x => x.ReportKey == item.ReportKey).FirstOrDefault() != null)
                    {
                        VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Remove(item);
                    }
                }
                else
                {
                    if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords == null)
                        VeterinaryDiseaseReportDeduplicationService.SelectedRecords = new List<VeterinaryDiseaseReportViewModel>();

                    if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Count < 2)
                        VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Add(item);
                    else
                    {
                        if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Where(x => x.ReportKey == item.ReportKey).FirstOrDefault() != null)
                        {
                            VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Remove(item);
                            IsRecordSelected(item);
                        }
                    }
                }

                SelectedRecords = VeterinaryDiseaseReportDeduplicationService.SelectedRecords;
                // check if the Selected Records are from the same farm
                if (SelectedRecords.Count == 2 && SelectedRecords[0].FarmID == SelectedRecords[1].FarmID)
                    disableDeduplicateButton = false;
                else
                {
                    disableDeduplicateButton = true;
                    if (SelectedRecords.Count == 2 && SelectedRecords[0].FarmID != SelectedRecords[1].FarmID)
                        await ShowErrorDialog(MessageResourceKeyConstants.AvianDiseaseReportDeduplicationUnabletocompletededuplicationofrecordsfromdifferentfarmsMessage, null);
                }

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
                IList<VeterinaryDiseaseReportViewModel> list = new List<VeterinaryDiseaseReportViewModel>();

                foreach (var record in VeterinaryDiseaseReportDeduplicationService.SelectedRecords)
                {
                    if (id != record.ReportKey && record.Selected == true)
                        list.Add(record);
                    else
                        record.Selected = false;
                }

                VeterinaryDiseaseReportDeduplicationService.SelectedRecords = list;
                SelectedRecords = VeterinaryDiseaseReportDeduplicationService.SelectedRecords;

                if (SelectedRecords.Count == 2 && SelectedRecords[0].FarmID == SelectedRecords[1].FarmID)
                    disableDeduplicateButton = false;
                else
                    disableDeduplicateButton = true;

                await gridSelectedRecords.Reload();

                if (VeterinaryDiseaseReportDeduplicationService.SelectedRecords.Count == 0)
                {
                    VeterinaryDiseaseReportDeduplicationService.SearchRecords = null;
                    VeterinaryDiseaseReportDeduplicationService.SelectedRecords = null;
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
            if (await ValidateCheckAsync() == true)
            {
                long id = 0;
                long id2 = 0;

                // persist search results before navigation
                model.SelectedRecords = SelectedRecords;
                if (ReportType == VeterinaryReportTypeEnum.Livestock)
                {
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LivestockDiseaseReportDeduplicationSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LivestockDiseaseReportDeduplicationSearchModelKey, model);
                } else 
                {
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.AvianDiseaseReportDeduplicationSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.AvianDiseaseReportDeduplicationSearchModelKey, model);
                }

                if (SelectedRecords.Count == 2)
                {
                    id = (long)SelectedRecords[0].ReportKey;
                    id2 = (long)SelectedRecords[1].ReportKey;
                }

                shouldRender = false;
                var path = "Administration/Deduplication/VeterinaryDiseaseReportDeduplication/Details";
                var query = $"?VeterinaryDiseaseReportID={id}&VeterinaryDiseaseReportID2={id2}&ReportType={ReportType}";
                var uri = $"{NavManager.BaseUri}{path}{query}";
                NavManager.NavigateTo(uri, true);
            }
        }

        #endregion Selected Records

        private async Task<bool> ValidateCheckAsync()
        {
            try
            {
                var FarmInventory1 = await GetFarmInventory(SelectedRecords[0].ReportKey, (long)SelectedRecords[0].FarmMasterKey, SelectedRecords[0].idfFarm);
                var FarmInventory2 = await GetFarmInventory(SelectedRecords[1].ReportKey, (long)SelectedRecords[1].FarmMasterKey, SelectedRecords[1].idfFarm);
                var HerdFlocklist1 = FarmInventory1.Where(x => x.RecordType == RecordTypeConstants.Herd).ToList();
                var HerdFlocklist2 = FarmInventory2.Where(x => x.RecordType == RecordTypeConstants.Herd).ToList();

                // check if each selected record has more than one flock/herd
                if (HerdFlocklist1.Count > 1 || HerdFlocklist2.Count > 1)
                {
                    if (ReportType == VeterinaryReportTypeEnum.Livestock)
                        await ShowErrorDialog(MessageResourceKeyConstants.DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithmorethanoneherdMessage, null);
                    else
                        await ShowErrorDialog(MessageResourceKeyConstants.AvianDiseaseReportDeduplicationUnabletocompletededuplicationofrecordswithmorethanoneflockMessage, null);

                    return false;
                }

                var Specieslist1 = FarmInventory1.Where(x => x.RecordType == RecordTypeConstants.Species).ToList();
                var Specieslist2 = FarmInventory2.Where(x => x.RecordType == RecordTypeConstants.Species).ToList();

                // check if each selected record has more than one species
                if (Specieslist1.Count > 1 || Specieslist2.Count > 1)
                {
                    await ShowErrorDialog(MessageResourceKeyConstants.DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithmorethanonespeciesMessage, null);
                    return false;
                }

                // check if the two selected record have only one same species
                if (Specieslist1.Count == Specieslist2.Count && Specieslist1.Count == 1)
                {
                    if (Specieslist1[0].SpeciesTypeID != Specieslist2[0].SpeciesTypeID)
                    {
                        await ShowErrorDialog(MessageResourceKeyConstants.DeduplicationLivestockReportUnabletocompletededuplicationofrecordswithdifferentspeciesMessage, null);
                        return false;
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }
    }
}
