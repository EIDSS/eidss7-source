using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
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

namespace EIDSS.Web.Components.Human.WeeklyReporting
{
    public class WeeklyReportingFormSearchBase : SearchComponentBase<WeeklyReportingFormSearchViewModel>, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<WeeklyReportingFormSearchBase> Logger { get; set; }

        [Inject]
        private IWeeklyReportingFormClient WeeklyReportingFormClient { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        #endregion

        #region Parameters

        public bool DisplayReport { get; set; }

        #endregion

        #region Member Variables

        private string _indicatorKey;
        private string _modelKey;

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<ReportFormViewModel> Grid;
        protected RadzenTemplateForm<WeeklyReportingFormSearchViewModel> Form;
        protected WeeklyReportingFormSearchViewModel Model;
        protected LocationView LocationViewComponent;

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;

                InitializeModel();

                // see if a search was saved
                var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.WeeklyReportingFormSearchPerformedIndicatorKey);
                var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                if (searchPerformedIndicator)
                {
                    var searchModelResult = await BrowserStorage.GetAsync<WeeklyReportingFormSearchViewModel>(SearchPersistenceKeys.WeeklyReportingFormSearchModelKey);
                    var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                    if (searchModel != null)
                    {
                        _indicatorKey = SearchPersistenceKeys.WeeklyReportingFormSearchPerformedIndicatorKey;
                        _modelKey = SearchPersistenceKeys.WeeklyReportingFormSearchModelKey;

                        isLoading = true;

                        Model.SearchCriteria = searchModel.SearchCriteria;
                        Model.SearchResults = searchModel.SearchResults;
                        count = (int) (Model.SearchResults.Count > 0
                                ? Model.SearchResults.FirstOrDefault()?.TotalRowCount
                                : 0);

                        Model.SearchLocationViewModel = searchModel.SearchLocationViewModel;
                        await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                        if (Grid is not null)
                            Grid.PageSize = Model.SearchCriteria.PageSize != 0 ? Model.SearchCriteria.PageSize : 10;

                        // set up the accordions
                        expandSearchCriteria = false;
                        showSearchCriteriaButtons = false;
                        showSearchResults = true;

                        isLoading = false;
                    }

                    await SetRegionRayonDefaultsAsync(Model, false);
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

                    await SetRegionRayonDefaultsAsync(Model);
                }

                SetButtonStates();

                await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        private async Task SetRegionRayonDefaultsAsync(WeeklyReportingFormSearchViewModel model, bool setAdministrativeLevelsIndicator = true)
        {
            try
            {
                // get the default admin levels
                var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
                long? eidssUserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
                long? userEmployeeId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                long? userOrganizationId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                long? userSiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                var adminLevel1 = _tokenService.GetAuthenticatedUser().Adminlevel1;
                var adminLevel2 = _tokenService.GetAuthenticatedUser().Adminlevel2;
                var regionSetting = userPreferences.DefaultRegionInSearchPanels;
                var rayonSetting = userPreferences.DefaultRayonInSearchPanels;

                Model.UserEmployeeID = userEmployeeId;
                Model.UserOrganizationID = userOrganizationId;
                Model.UserSiteID = userSiteId;
                Model.EIDSS_UuserID = eidssUserId;
                Model.DefaultRegionShown = regionSetting;
                Model.DefaultRayonShown = rayonSetting;
                Model.AdminLevel1 = adminLevel1;
                Model.AdminLevel2 = adminLevel2;

                var langId = GetCurrentLanguage();
                var siteId = Convert.ToInt64(Model.UserSiteID);
                var userId = Convert.ToInt64(Model.EIDSS_UuserID);

                var siteDetails = await SiteClient.GetSiteDetails(langId, siteId, userId);

                if (setAdministrativeLevelsIndicator)
                {
                    model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;
                    model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;
                }

                LoadSiteDetails(siteDetails);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected void LoadSiteDetails(SiteGetDetailViewModel siteDetails)
        {
            Model.SiteDetailViewModel.SiteOrganizationName = siteDetails.SiteOrganizationName;
            Model.SiteDetailViewModel.PersonID = siteDetails.PersonID;
            Model.SiteDetailViewModel.SiteOrganizationName = siteDetails.SiteOrganizationName;
            Model.SiteDetailViewModel.ActiveStatusIndicator = siteDetails.ActiveStatusIndicator;
            Model.SiteDetailViewModel.AdministrativeLevel3ID = siteDetails.AdministrativeLevel3ID;
            Model.SiteDetailViewModel.AdministrativeLevel2ID = siteDetails.AdministrativeLevel2ID;
            Model.SiteDetailViewModel.ActiveStatusIndicator = siteDetails.ActiveStatusIndicator;
            Model.SiteDetailViewModel.CountryID = siteDetails.CountryID;
            Model.SiteDetailViewModel.ActiveStatusIndicator = siteDetails.ActiveStatusIndicator;
            Model.SiteDetailViewModel.CustomizationPackageID = siteDetails.CustomizationPackageID;
            Model.SiteDetailViewModel.EIDSSSiteID = siteDetails.EIDSSSiteID;
            Model.SiteDetailViewModel.HASCSiteID = siteDetails.HASCSiteID;
            Model.SiteDetailViewModel.LanguageID = siteDetails.LanguageID;
            Model.SiteDetailViewModel.UserID = siteDetails.UserID;
            Model.SiteDetailViewModel.SiteID = siteDetails.SiteID;
            Model.SiteDetailViewModel.SiteName = siteDetails.SiteName;
            Model.SiteDetailViewModel.SettlementID = siteDetails.SettlementID;
            Model.SiteDetailViewModel.SiteTypeID = siteDetails.SiteTypeID;
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
        }

        private void InitializeModel()
        {
            try
            {
                _ = _tokenService.GetAuthenticatedUser().BottomAdminLevel;
                Model = new WeeklyReportingFormSearchViewModel
                {
                    SearchCriteria = new WeeklyReportingFormGetRequestModel(),
                    SearchResults = new List<ReportFormViewModel>(),
                    Permissions = new UserPermissions(),
                    SiteDetailViewModel = new()
                };
                count = 0;
                Model.Permissions = GetUserPermissions(PagePermission.HumanWeeklyReport);
                Model.SearchCriteria.SortColumn = "ReportID";
                Model.SearchCriteria.SortOrder = SortConstants.Descending;

                //initialize the location control
                Model.SearchLocationViewModel = new LocationViewModel
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
                    AdminLevel0Value = Convert.ToInt64(Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            Model.SearchCriteria.EndDate = DateTime.Today;
            Model.SearchCriteria.StartDate = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
        }

        private void SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.Permissions.Create)
            {
                disableAddButton = true;
            }
        }

        protected void LocationChanged(LocationViewModel locationViewModel)
        {
            //Get lowest administrative level for location
            if (locationViewModel.AdminLevel3Value.HasValue)
            {
                Model.SearchLocationViewModel.AdminLevel0Value = locationViewModel.AdminLevel3Value.Value;
            }
            else if (locationViewModel.AdminLevel2Value.HasValue)
            {
                Model.SearchLocationViewModel.AdminLevel2Value = locationViewModel.AdminLevel2Value.Value;
            }
            else if (locationViewModel.AdminLevel1Value.HasValue)
            {
                Model.SearchLocationViewModel.AdminLevel1Value = locationViewModel.AdminLevel1Value.Value;
            }
        }

        protected void AccordionClick(int index)
        {
            try
            {
                expandSearchCriteria = index switch
                {
                    //search criteria toggle
                    0 => !expandSearchCriteria,
                    _ => expandSearchCriteria
                };
                SetButtonStates();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
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
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                isLoading = true;
                showSearchResults = true;

                var request = new WeeklyReportingFormGetRequestModel
                {
                    EIDSSReportID = Model.SearchCriteria.EIDSSReportID,
                    ReportFormTypeId = (long?)ReportFormTypes.HumanWeeklyReportForm,
                    StartDate = Model.SearchCriteria.StartDate,
                    EndDate = Model.SearchCriteria.EndDate

                };

                //Get lowest administrative level for location
                if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                {
                    request.AdministrativeLevelId = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                    request.AdministrativeUnitTypeId = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                }
                else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                {
                    request.AdministrativeLevelId = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                    request.AdministrativeUnitTypeId = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                }
                else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                {
                    request.AdministrativeLevelId = Model.SearchLocationViewModel.AdminLevel1Value.Value;
                    if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                    {
                        request.AdministrativeUnitTypeId = Model.SearchLocationViewModel.AdminLevel1Value.Value;
                    }
                }
                else
                {
                    request.AdministrativeLevelId = null;
                    request.AdministrativeUnitTypeId = null;
                }

                request.UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                request.UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId);
                request.UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                request.ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel;

                request.LanguageId = GetCurrentLanguage();
                //request.OrganizationId = _tokenService.GetAuthenticatedUser().OfficeId;
                request.SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                //sorting
                request.SortColumn = !string.IsNullOrEmpty(args.OrderBy)
                    ? args.Sorts.FirstOrDefault()?.Property
                    : "EIDSSReportID";
                request.SortOrder = args.Sorts.FirstOrDefault() != null
                    ? args.Sorts.FirstOrDefault()?.SortOrder.ToString() == "Ascending" ? SortConstants.Ascending : SortConstants.Descending
                    : SortConstants.Descending;
                //paging
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

                var result = await WeeklyReportingFormClient.GetWeeklyReportingFormList(request);
                if (source.IsCancellationRequested == false)
                {
                    Model.SearchResults = result;
                    count = Model.SearchResults.FirstOrDefault() != null
                        ? Model.SearchResults.First().TotalRowCount
                        : 0;
                    if (searchSubmitted)
                    {
                        await Grid.FirstPage();
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

        protected async Task HandleValidSearchSubmit(WeeklyReportingFormSearchViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(PagePermission.HumanWeeklyReport);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                SetButtonStates();

                // make the API call
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

        private static bool HasCriteria(WeeklyReportingFormSearchViewModel model)
        {
            var properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                var name = prop.Name;
                var val = prop.GetValue(model.SearchCriteria);
                switch (name)
                {
                    case "EIDSSReportID" when val != null:
                        return true;
                    case "StartDate" when val != null:
                        return true;
                    case "EndDate" when val != null:
                        return true;
                }
            }

            //Check the location
            return model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                   model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                   model.SearchLocationViewModel.AdminLevel1Value.HasValue;
        }

        protected async Task CancelSearchClicked()
        {
            // clear the flag so we are not displayed
            DisplayReport = false;

            await CancelSearchAsync();
        }

        public async Task ResetSearch()
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

            await SetRegionRayonDefaultsAsync(Model);
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

                    // required parameters N.B.(Every report needs these three)
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.WeeklyReportingFormDetailsPageHeading)); // "Weekly Reporting List"); 
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("PageSize", nGridCount.ToString());

                    // optional parameters 
                    reportModel.AddParameter("ReportFormTypeID", ((long?)ReportFormTypes.HumanWeeklyReportForm).ToString());
                    reportModel.AddParameter("EIDSSReportID", Model.SearchCriteria.EIDSSReportID);
                    if (Model.SearchCriteria.StartDate != null)
                        reportModel.AddParameter("StartDate", Model.SearchCriteria.StartDate.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.EndDate != null)
                        reportModel.AddParameter("EndDate", Model.SearchCriteria.EndDate.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("AdministrativeLevelID", locationId.ToString());
                    reportModel.AddParameter("SortOrder", Model.SearchCriteria.SortOrder);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.WeeklyReportingFormDetailsPageHeading),
                        new Dictionary<string, object> { { "ReportName", "SearchForWeeklyReportingForm" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.HumanDiseaseReport,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "875px"
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        protected async Task CancelSearch()
        {
            //displayReport = false;

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
                // if we have parameters then we were at Print
                //if (model.ReportParameters.Any())
                //{
                //    await PrintResults();
                //}

                //cancel search but user said no so leave everything alone and cancel thread
                source?.Cancel();
            }
        }

        protected void OpenAdd()
        {
            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Human/WeeklyReportingForm/Add";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task OpenEditAsync(long formId)
        {
            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.WeeklyReportingFormSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.WeeklyReportingFormSearchModelKey, Model);

            shouldRender = false;
            const string path = "Human/WeeklyReportingForm/Details";
            var query = $"?formID={formId}";
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLinkAsync(long reportId)
        {
            if (Mode == SearchModeEnum.Import)
            {
                if (CallbackUrl.EndsWith('/'))
                {
                    CallbackUrl = CallbackUrl[..^1];
                }

                var url = CallbackUrl + $"?Id={reportId}";

                if (CallbackKey != null)
                {
                    url += "&callbackkey=" + CallbackKey.ToString();
                }
                NavManager.NavigateTo(url, true);
            }
            else if (Mode == SearchModeEnum.Select)
            {
                DiagService.Close(Model.SearchResults.First(x => x.ReportFormId == reportId));
            }
            else
            {
                // persist search results before navigation
                await BrowserStorage.SetAsync(SearchPersistenceKeys.WeeklyReportingFormSearchPerformedIndicatorKey, true);
                await BrowserStorage.SetAsync(SearchPersistenceKeys.WeeklyReportingFormSearchModelKey, Model);

                shouldRender = false;
                const string path = "Human/WeeklyReportingForm/Details";
                var query = $"?formID={reportId}&isReadOnly=true";
                var uri = $"{NavManager.BaseUri}{path}{query}";

                NavManager.NavigateTo(uri, true);
            }
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
        }

        #endregion
    }
}
