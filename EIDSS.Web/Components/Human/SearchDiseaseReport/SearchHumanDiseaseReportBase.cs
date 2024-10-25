#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
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
using EIDSS.Web.Areas.Human.ViewModels.Human;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
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
using static System.String;

#endregion

namespace EIDSS.Web.Components.Human.SearchDiseaseReport
{
    public class SearchHumanDiseaseReportBase : SearchComponentBase<SearchHumanDiseaseReportPageViewModel>, IDisposable
    {
        #region Grid Column Picker Row Reorder

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public GridExtensionBase GridExtension { get; set; }
        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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

        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("SearchHumanDiseaseReport");

            base.OnInitialized();
        }

        #endregion

        #region Globals

        #region Dependencies

        [Inject]
        private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ILogger<SearchHumanDiseaseReportBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public bool? OutbreakCasesIndicator { get; set; }

        #endregion

        #region Properties

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<HumanDiseaseReportViewModel> Grid;
        protected RadzenTemplateForm<SearchHumanDiseaseReportPageViewModel> Form;
        protected RadzenDatePicker<DateTime?> DateEnteredFrom;
        protected SearchHumanDiseaseReportPageViewModel Model;
        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases;
        protected IEnumerable<BaseReferenceViewModel> ReportStatuses;
        protected IEnumerable<BaseReferenceAdvancedListResponseModel> CaseClassifications;
        protected IEnumerable<BaseReferenceViewModel> HospitalizationStatuses;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> SentByFacilities;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> ReceivedByFacilities;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> DataEntrySites;
        protected IEnumerable<BaseReferenceViewModel> Outcomes;
        protected int DiseaseCount;
        protected LocationView LocationViewComponent;
        protected LocationView ExposureLocationViewComponent;

        #endregion

        #region Private Members

        private bool _isRecordSelected;

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            LoadingComponentIndicator = true;

            InitializeModel();

            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.HumanDiseaseReportSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult is { Success: true, Value: true };
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<SearchHumanDiseaseReportPageViewModel>(SearchPersistenceKeys.HumanDiseaseReportSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                    Model.SearchExposureLocationViewModel = searchModel.SearchExposureLocationViewModel;

                    Model.SearchResults = searchModel.SearchResults;

                    count = (int) (Model.SearchResults.Count > 0
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
                isLoading = false;

                SetDefaults();

                //set up the accordions
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
                await ExposureLocationViewComponent.RefreshComponent(Model.SearchExposureLocationViewModel);

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
                _logger.LogError(ex.Message, null);
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
                    {"DialogName", "NarrowSearch"},
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
                };
                var dialogOptions = new DialogOptions()
                {
                    ShowTitle = true,
                    ShowClose = false
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams, dialogOptions);
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
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                isLoading = true;
                showSearchResults = true;

                var request = new HumanDiseaseReportSearchRequestModel
                {
                    ReportID = Model.SearchCriteria.ReportID,
                    LegacyReportID = Model.SearchCriteria.LegacyReportID,
                    DiseaseID = Model.SearchCriteria.DiseaseID,
                    ReportStatusTypeID = Model.SearchCriteria.ReportStatusTypeID,
                    PatientFirstName = Model.SearchCriteria.PatientFirstName,
                    PatientMiddleName = Model.SearchCriteria.PatientMiddleName,
                    PatientLastName = Model.SearchCriteria.PatientLastName,
                    //Get lowest administrative level for location
                    AdministrativeLevelID = Common.GetLocationId(Model.SearchLocationViewModel)
                };

                if (request.AdministrativeLevelID is not null && request.AdministrativeLevelID.ToString() == CountryID)
                    request.AdministrativeLevelID = null;

                //Get lowest administrative level for location of exposure
                if (Model.SearchExposureLocationViewModel.AdminLevel3Value.HasValue)
                    request.LocationOfExposureAdministrativeLevelID = Model.SearchExposureLocationViewModel.AdminLevel3Value.Value;
                else if (Model.SearchExposureLocationViewModel.AdminLevel2Value.HasValue)
                    request.LocationOfExposureAdministrativeLevelID = Model.SearchExposureLocationViewModel.AdminLevel2Value.Value;
                else if (Model.SearchExposureLocationViewModel.AdminLevel1Value.HasValue)
                    request.LocationOfExposureAdministrativeLevelID = Model.SearchExposureLocationViewModel.AdminLevel1Value.Value;
                else
                    request.LocationOfExposureAdministrativeLevelID = null;

                request.DateEnteredFrom = Model.SearchCriteria.DateEnteredFrom;
                request.DateEnteredTo = Model.SearchCriteria.DateEnteredTo;
                request.ClassificationTypeID = Model.SearchCriteria.ClassificationTypeID;
                request.HospitalizationYNID = Model.SearchCriteria.HospitalizationYNID;
                request.SentByFacilityID = Model.SearchCriteria.SentByFacilityID;
                request.ReceivedByFacilityID = Model.SearchCriteria.ReceivedByFacilityID;
                request.DataEntrySiteID = Model.SearchCriteria.DataEntrySiteID;
                request.DateOfFinalCaseClassificationFrom = Model.SearchCriteria.DateOfFinalCaseClassificationFrom;
                request.DateOfFinalCaseClassificationTo = Model.SearchCriteria.DateOfFinalCaseClassificationTo;
                request.DateOfSymptomsOnsetFrom = Model.SearchCriteria.DateOfSymptomsOnsetFrom;
                request.DateOfSymptomsOnsetTo = Model.SearchCriteria.DateOfSymptomsOnsetTo;
                request.NotificationDateFrom = Model.SearchCriteria.NotificationDateFrom;
                request.NotificationDateTo = Model.SearchCriteria.NotificationDateTo;
                request.DiagnosisDateFrom = Model.SearchCriteria.DiagnosisDateFrom;
                request.DiagnosisDateTo = Model.SearchCriteria.DiagnosisDateTo;
                request.LocalOrFieldSampleID = Model.SearchCriteria.LocalOrFieldSampleID;
                request.OutcomeID = Model.SearchCriteria.OutcomeID;
                request.OutbreakCasesIndicator = OutbreakCasesIndicator;
                request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel;
                request.LanguageId = GetCurrentLanguage();
                request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                if ((!IsNullOrEmpty(request.ReportID) || !IsNullOrEmpty(request.LegacyReportID)) &&
                    request.AdministrativeLevelID is null &&
                    request.ClassificationTypeID is null &&
                    request.DataEntrySiteID is null &&
                    request.DateEnteredFrom is null &&
                    request.DateEnteredTo is null &&
                    request.DateOfFinalCaseClassificationFrom is null &&
                    request.DateOfFinalCaseClassificationTo is null &&
                    request.DateOfSymptomsOnsetFrom is null &&
                    request.DateOfSymptomsOnsetTo is null &&
                    request.DiagnosisDateFrom is null &&
                    request.DiagnosisDateTo is null &&
                    request.DiseaseID is null &&
                    request.HospitalizationYNID is null &&
                    IsNullOrEmpty(request.LocalOrFieldSampleID) &&
                    request.LocationOfExposureAdministrativeLevelID is null &&
                    request.NotificationDateFrom is null &&
                    request.NotificationDateTo is null &&
                    request.OutcomeID is null &&
                    IsNullOrEmpty(request.PatientFirstName) &&
                    IsNullOrEmpty(request.PatientLastName) &&
                    IsNullOrEmpty(request.PatientMiddleName) &&
                    IsNullOrEmpty(request.PersonID) &&
                    request.ReceivedByFacilityID is null &&
                    request.ReportStatusTypeID is null &&
                    request.SentByFacilityID is null &&
                    request.SessionKey is null)
                    request.RecordIdentifierSearchIndicator = true;
                else
                    request.RecordIdentifierSearchIndicator = false;

                // sorting
                if (args.Sorts.FirstOrDefault() != null)
                {
                    request.SortColumn = args.Sorts.FirstOrDefault()?.Property;
                    request.SortOrder = args.Sorts.FirstOrDefault()
                        ?.SortOrder?.ToString().Replace("Ascending", SortConstants.Ascending).Replace("Descending", SortConstants.Descending);
                }
                else
                {
                    request.SortColumn = "ReportID";
                    request.SortOrder = SortConstants.Descending;
                }

                // paging
                if (args.Skip is > 0 && searchSubmitted == false)
                {
                    request.Page = args.Skip.Value / Grid.PageSize + 1;
                }
                else
                {
                    request.Page = 1;

                }
                request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                Model.SearchCriteria.Page = request.Page;
                Model.SearchCriteria.PageSize = request.PageSize;

                if (_isRecordSelected == false)
                {
                    var result = await HumanDiseaseReportClient.GetHumanDiseaseReports(request, token);
                    if (source?.IsCancellationRequested == false)
                    {
                        count = 0;
                        Model.SearchResults = result;
                        count = (int)(Model.SearchResults.Count > 0
                            ? Model.SearchResults.FirstOrDefault()?.RecordCount
                            : 0);
                        if (searchSubmitted)
                        {
                            await Grid.FirstPage();
                        }
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

        protected async Task HandleValidSearchSubmit(SearchHumanDiseaseReportPageViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                expandAdvancedSearchCriteria = false;
                SetButtonStates();

                if (Grid != null)
                {
                    await Grid.Reload();
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

        protected void LocationChanged()
        {
            //Get lowest administrative level for location
            if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                Model.SearchCriteria.AdministrativeLevelID = Model.SearchLocationViewModel.AdminLevel3Value.Value;
            else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                Model.SearchCriteria.AdministrativeLevelID = Model.SearchLocationViewModel.AdminLevel2Value.Value;
            else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                Model.SearchCriteria.AdministrativeLevelID = Model.SearchLocationViewModel.AdminLevel1Value.Value;
            else
                Model.SearchCriteria.AdministrativeLevelID = null;
        }

        protected void ExposureLocationChanged()
        {
            //Get lowest administrative level for location of exposure
            if (Model.SearchExposureLocationViewModel.AdminLevel3Value.HasValue)
                Model.SearchCriteria.LocationOfExposureAdministrativeLevelID = Model.SearchExposureLocationViewModel.AdminLevel3Value.Value;
            else if (Model.SearchExposureLocationViewModel.AdminLevel2Value.HasValue)
                Model.SearchCriteria.LocationOfExposureAdministrativeLevelID = Model.SearchExposureLocationViewModel.AdminLevel2Value.Value;
            else if (Model.SearchExposureLocationViewModel.AdminLevel1Value.HasValue)
                Model.SearchCriteria.LocationOfExposureAdministrativeLevelID = Model.SearchExposureLocationViewModel.AdminLevel1Value.Value;
            else
                Model.SearchCriteria.LocationOfExposureAdministrativeLevelID = null;
        }

        protected async Task CancelSearchClicked()
        {
            switch (Mode)
            {
                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close("Cancelled");
                    break;
                case SearchModeEnum.Import:
                    await CancelSearchByUrlAsync();
                    break;
                default:
                    await CancelSearchAsync();
                    break;
            }
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

        protected async Task OpenEdit(long id)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportSearchModelKey, Model);

            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Human/HumanDiseaseReport/SelectForEdit/{id}";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task OpenPerson(long id)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportSearchModelKey, Model);

            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Human/Person/Details/{id}";
            NavManager.NavigateTo(uri, true);
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
                    DiagService.Close(Model.SearchResults.First(x => x.ReportKey == id));
                    break;
                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close(Model.SearchResults.First(x => x.ReportKey == id));
                    break;
                default:
                    {
                        // persist search results before navigation
                        await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportSearchPerformedIndicatorKey, true);
                        await BrowserStorage.SetAsync(SearchPersistenceKeys.HumanDiseaseReportSearchModelKey, Model);

                        shouldRender = false;
                        var uri = $"{NavManager.BaseUri}Human/HumanDiseaseReport/SelectForReadOnly/{id}";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
            }
        }

        protected async Task PrintResults()
        {
            if (Form.IsValid)
            {
                var nGridCount = Grid.Count;

                try
                {
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

                    // get lowest location of exposure administrative level for location
                    long? locationOfExposureId;
                    if (Model.SearchExposureLocationViewModel.AdminLevel3Value.HasValue)
                        locationOfExposureId = Model.SearchExposureLocationViewModel.AdminLevel3Value.Value;
                    else if (Model.SearchExposureLocationViewModel.AdminLevel2Value.HasValue)
                        locationOfExposureId = Model.SearchExposureLocationViewModel.AdminLevel2Value.Value;
                    else if (Model.SearchExposureLocationViewModel.AdminLevel1Value.HasValue)
                        locationOfExposureId = Model.SearchExposureLocationViewModel.AdminLevel1Value.Value;
                    else
                        locationOfExposureId = null;

                    // required parameters
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportHumanDiseaseReportHeading));
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("pageSize", nGridCount.ToString());

                    // optional parameters
                    reportModel.AddParameter("ReportID", Model.SearchCriteria.ReportID);
                    reportModel.AddParameter("LegacyReportID", Model.SearchCriteria.LegacyReportID);
                    reportModel.AddParameter("PatientID", Model.SearchCriteria.PatientID.ToString());
                    reportModel.AddParameter("DiseaseID", Model.SearchCriteria.DiseaseID.ToString());
                    reportModel.AddParameter("ReportStatusTypeID", Model.SearchCriteria.ReportStatusTypeID.ToString());
                    reportModel.AddParameter("AdministrativeLevelID", locationId.ToString());
                    if (Model.SearchCriteria.DateEnteredFrom != null)
                        reportModel.AddParameter("DateEnteredFrom", Model.SearchCriteria.DateEnteredFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateEnteredTo != null)
                        reportModel.AddParameter("DateEnteredTo", Model.SearchCriteria.DateEnteredTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("ClassificationTypeID", Model.SearchCriteria.ClassificationTypeID.ToString());
                    reportModel.AddParameter("HospitalizationYNID", Model.SearchCriteria.HospitalizationYNID.ToString());
                    reportModel.AddParameter("PatientFirstName", Model.SearchCriteria.PatientFirstName);
                    reportModel.AddParameter("PatientMiddleName", Model.SearchCriteria.PatientMiddleName);
                    reportModel.AddParameter("PatientLastName", Model.SearchCriteria.PatientLastName);
                    reportModel.AddParameter("SentByFacilityID", Model.SearchCriteria.SentByFacilityID.ToString());
                    reportModel.AddParameter("ReceivedByFacilityID", Model.SearchCriteria.ReceivedByFacilityID.ToString());
                    if (Model.SearchCriteria.DiagnosisDateFrom != null)
                        reportModel.AddParameter("DiagnosisDateFrom", Model.SearchCriteria.DiagnosisDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DiagnosisDateTo != null)
                        reportModel.AddParameter("DiagnosisDateTo", Model.SearchCriteria.DiagnosisDateTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("LocalOrFieldSampleID", Model.SearchCriteria.LocalOrFieldSampleID);
                    reportModel.AddParameter("DataEntrySiteID", Model.SearchCriteria.DataEntrySiteID.ToString());
                    if (Model.SearchCriteria.DateOfSymptomsOnsetFrom != null)
                        reportModel.AddParameter("DateOfSymptomsOnsetFrom", Model.SearchCriteria.DateOfSymptomsOnsetFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateOfSymptomsOnsetTo != null)
                        reportModel.AddParameter("DateOfSymptomsOnsetTo", Model.SearchCriteria.DateOfSymptomsOnsetTo.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.NotificationDateFrom != null)
                        reportModel.AddParameter("NotificationDateFrom", Model.SearchCriteria.NotificationDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.NotificationDateTo != null)
                        reportModel.AddParameter("NotificationDateTo", Model.SearchCriteria.NotificationDateTo.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateOfFinalCaseClassificationFrom != null)
                        reportModel.AddParameter("DateOfFinalCaseClassificationFrom", Model.SearchCriteria.DateOfFinalCaseClassificationFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateOfFinalCaseClassificationTo != null)
                        reportModel.AddParameter("DateOfFinalCaseClassificationTo", Model.SearchCriteria.DateOfFinalCaseClassificationTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("LocationOfExposureAdministrativeLevelID", locationOfExposureId.ToString());
                    reportModel.AddParameter("UserSiteID", _tokenService.GetAuthenticatedUser().SiteId);
                    reportModel.AddParameter("UserOrganizationID", _tokenService.GetAuthenticatedUser().OfficeId.ToString());
                    reportModel.AddParameter("UserEmployeeID", _tokenService.GetAuthenticatedUser().PersonId);
                    reportModel.AddParameter("sortColumn", Model.SearchCriteria.SortColumn);
                    reportModel.AddParameter("sortOrder", Model.SearchCriteria.SortOrder);
                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId >= ((long)SiteTypes.ThirdLevel) ? "1" : "0");
                    reportModel.AddParameter("OutcomeID", null);
                    reportModel.AddParameter("FilterOutbreakTiedReports", null);
                    reportModel.AddParameter("OutbreakCasesIndicator", null);

                    //if ((!IsNullOrEmpty(Model.SearchCriteria.ReportID) || !IsNullOrEmpty(Model.SearchCriteria.LegacyReportID)) &&
                    //    Model.SearchCriteria.AdministrativeLevelID is null &&
                    //    Model.SearchCriteria.ClassificationTypeID is null &&
                    //    Model.SearchCriteria.DataEntrySiteID is null &&
                    //    Model.SearchCriteria.DateEnteredFrom is null &&
                    //    Model.SearchCriteria.DateEnteredTo is null &&
                    //    Model.SearchCriteria.DateOfFinalCaseClassificationFrom is null &&
                    //    Model.SearchCriteria.DateOfFinalCaseClassificationTo is null &&
                    //    Model.SearchCriteria.DateOfSymptomsOnsetFrom is null &&
                    //    Model.SearchCriteria.DateOfSymptomsOnsetTo is null &&
                    //    Model.SearchCriteria.DiagnosisDateFrom is null &&
                    //    Model.SearchCriteria.DiagnosisDateTo is null &&
                    //    Model.SearchCriteria.DiseaseID is null &&
                    //    Model.SearchCriteria.HospitalizationYNID is null &&
                    //    IsNullOrEmpty(Model.SearchCriteria.LocalOrFieldSampleID) &&
                    //    Model.SearchCriteria.LocationOfExposureAdministrativeLevelID is null &&
                    //    Model.SearchCriteria.NotificationDateFrom is null &&
                    //    Model.SearchCriteria.NotificationDateTo is null &&
                    //    Model.SearchCriteria.OutcomeID is null &&
                    //    IsNullOrEmpty(Model.SearchCriteria.PatientFirstName) &&
                    //    IsNullOrEmpty(Model.SearchCriteria.PatientLastName) &&
                    //    IsNullOrEmpty(Model.SearchCriteria.PatientMiddleName) &&
                    //    IsNullOrEmpty(Model.SearchCriteria.PersonID) &&
                    //    Model.SearchCriteria.ReceivedByFacilityID is null &&
                    //    Model.SearchCriteria.ReportStatusTypeID is null &&
                    //    Model.SearchCriteria.SentByFacilityID is null &&
                    //    Model.SearchCriteria.SessionKey is null)
                    //    reportModel.AddParameter("RecordIdentifierSearchIndicator", "1");
                    //else
                    //    reportModel.AddParameter("RecordIdentifierSearchIndicator", "0");

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportHumanDiseaseReportHeading),
                        new Dictionary<string, object> { { "ReportName", "SearchForHumanDiseaseReport" }, { "Parameters", reportModel.Parameters } },
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

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = HACodeList.HumanHACode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            DiseaseCount = Diseases.Count();
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSentByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = HACodeList.HumanHACode,
                AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                OrganizationTypeID = null
            };
            var list = await OrganizationClient.GetOrganizationAdvancedList(request);

            SentByFacilities = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList().AsODataEnumerable();

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetReceivedByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = HACodeList.HumanHACode,
                AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                OrganizationTypeID = null
            };
            var list = await OrganizationClient.GetOrganizationAdvancedList(request);

            ReceivedByFacilities = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList().AsODataEnumerable();

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetEnteredByOrganizationsAsync(LoadDataArgs args)
        {
            var request = new OrganizationAdvancedGetRequestModel()
            {
                LangID = GetCurrentLanguage(),
                AccessoryCode = HACodeList.HumanHACode,
                AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                OrganizationTypeID = null
            };
            var list = await OrganizationClient.GetOrganizationAdvancedList(request);

            DataEntrySites = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList().AsODataEnumerable();

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetHospitalizationStatusAsync()
        {
            HospitalizationStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.YesNoValueList, HACodeList.HumanHACode);
        }

        protected async Task GetCaseClassificationsAsync(LoadDataArgs args)
        {
            var request = new BaseReferenceAdvancedListRequestModel()
            {
                advancedSearch = args.Filter,
                intHACode = HACodeList.HumanHACode,
                LanguageId = GetCurrentLanguage(),
                ReferenceTypeName = BaseReferenceConstants.CaseClassification,
                SortColumn = "intOrder",
                SortOrder = SortConstants.Descending
            };
            CaseClassifications = await CrossCuttingClient.GetBaseReferenceAdvanceList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetOutcomesAsync()
        {
            Outcomes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Outcome, HACodeList.HumanHACode);
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
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model.SearchCriteria.DateEnteredTo = DateTime.Today;
            Model.SearchCriteria.DateEnteredFrom = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;

            //Locks out the disease field, when used from Outbreak Human Case
            Model.SearchCriteria.DiseaseID = DiseaseId;
        }

        private void InitializeModel()
        {
            _ = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            Model = new SearchHumanDiseaseReportPageViewModel
            {
                HumanDiseaseReportPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData),
                SearchCriteria = new HumanDiseaseReportSearchRequestModel(),
                SearchResults = new List<HumanDiseaseReportViewModel>(),
                BottomAdminLevel = _tokenService.GetAuthenticatedUser().BottomAdminLevel //19000002 is level 2, 19000003 is level 3, etc
            };
            Model.SearchCriteria.SortColumn = "ReportID";
            Model.SearchCriteria.SortOrder = SortConstants.Descending;

            // initialize the location control
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

            // initialize the exposure location control
            Model.SearchExposureLocationViewModel = new LocationViewModel
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

        private static bool HasCriteria(SearchHumanDiseaseReportPageViewModel model)
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

        #endregion
    }
}