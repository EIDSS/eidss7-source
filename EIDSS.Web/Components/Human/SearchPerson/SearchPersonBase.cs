#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Human.Person;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Components.Veterinary.Farm;
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
using System.Globalization;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Human.SearchPerson
{
    public class SearchPersonBase : SearchComponentBase<PersonSearchPageViewModel>, IDisposable
    {
        #region Grid Column Chooser Reorder

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public GridExtensionBase GridExtension { get; set; }

        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("SearchPersonHumanModule");

            base.OnInitialized();
        }

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
            bool visible = true;
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

        #endregion

        #region Globals

        #region Dependencies

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchPersonBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public long? MonitoringSessionID { get; set; }

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<PersonViewModel> Grid;
        protected RadzenTemplateForm<PersonSearchPageViewModel> Form;
        protected PersonSearchPageViewModel Model;
        protected IEnumerable<BaseReferenceViewModel> PersonnelIdTypes;
        protected IEnumerable<BaseReferenceViewModel> PersonnelIdTypesFiltered;
        protected IEnumerable<BaseReferenceViewModel> GenderIdTypes;
        protected bool PersonalIdDisabled;
        protected LocationView LocationViewComponent;

        [Parameter] public bool ClearSearchResults { get; set; }

        private bool _isRecordSelected;

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            LoadingComponentIndicator = true;

            _logger = Logger;

            DiagService.OnClose += property => HandleResponse(property);

            InitializeModel();

            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
            Model.SearchLocationViewModel.AdminLevel1Value = userPreferences.DefaultRegionInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RegionId
                : null;
            Model.SearchLocationViewModel.AdminLevel2Value = userPreferences.DefaultRayonInSearchPanels
                ? _tokenService.GetAuthenticatedUser().RayonId
                : null;

            var searchPerformedIndicator = false;
            if (!ClearSearchResults)
            {
                // see if a search was saved
                var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey);
                searchPerformedIndicator = indicatorResult is { Success: true, Value: true };
            }
            if (searchPerformedIndicator)
            {
                var searchModelResult = await BrowserStorage.GetAsync<PersonSearchPageViewModel>(SearchPersistenceKeys.PersonSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchResults = searchModel.SearchResults;
                    count = Model.SearchResults.Count;

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

                await LoadData(new LoadDataArgs());
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
            }

            await SetButtonStates();

            await base.OnInitializedAsync();
        }

        protected void HandleResponse(dynamic result)
        {
            if (result is not DialogReturnResult returnResult) return;
            result = returnResult;

            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                try
                {

                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
            else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
            {
                // just close modal
                DiagService.OnClose -= property => HandleResponse(property);
                DiagService.Close();
            }
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await LocationViewComponent.RefreshComponent(Model.SearchLocationViewModel);

                LoadingComponentIndicator = false;

                await InvokeAsync(StateHasChanged);

                if (!IsNullOrEmpty(CancelUrl) && CancelUrl.Contains("/Outbreak/OutbreakCases?queryData="))
                {
                    if (!VerifyOutbreakCasePermissions())
                    {
                        await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}" + CancelUrl.Remove(0, 1));
                    }
                }
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers
        /// </summary>
        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();

            DiagService.OnClose -= property => HandleResponse(property);
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
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
                {"DialogType", EIDSSDialogType.Warning},
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
            };
            var dialogOptions = new DialogOptions
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
                await SetButtonStates();
            }
        }

        protected async Task PersonalIdTypeChangedAsync(object value)
        {
            if (Convert.ToInt64(value) == PersonalIDTypes.Unknown)
            {
                Model.SearchCriteria.PersonalID = null;
                PersonalIdDisabled = true;
            }
            else
            {
                PersonalIdDisabled = false;
            }
            await InvokeAsync(StateHasChanged);
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

        protected async Task LoadData(LoadDataArgs args)
        {
            // Thread.CurrentThread.CurrentCulture = new CultureInfo(reportQueryModel.PriorLanguageId);
            // Thread.CurrentThread.CurrentUICulture = new CultureInfo(reportQueryModel.PriorLanguageId);
            //_ = DateTime.TryParse(reportQueryModel.StartIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime startIssueDate);
            //_ = DateTime.TryParse(reportQueryModel.EndIssueDate, new CultureInfo(reportQueryModel.LanguageId), DateTimeStyles.None, out DateTime endIssueDate);
            Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
            Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

            try
            {
                isLoading = true;
                showSearchResults = true;

                HumanPersonSearchRequestModel request;

                // null out other fields if search is on person id
                if (!IsNullOrEmpty(Model.SearchCriteria.EIDSSPersonID))
                {
                    request = new HumanPersonSearchRequestModel
                    {
                        EIDSSPersonID = Model.SearchCriteria.EIDSSPersonID,
                        PersonalIDType = null,
                        PersonalID = null,
                        DateOfBirthFrom = null,
                        DateOfBirthTo = null,
                        GenderTypeID = null,
                        LastOrSurname = null,
                        SecondName = null,
                        FirstOrGivenName = null,
                        MonitoringSessionID = null,
                        idfsLocation = null,
                        SettlementTypeID = null
                    };
                }
                else
                {
                    if (Model.SearchCriteria.DateOfBirthFrom != null)
                    {
                        _ = DateTime.TryParse(Model.SearchCriteria.DateOfBirthFrom.Value.ToString(),
                            new CultureInfo("en-US"),
                            DateTimeStyles.None, out var dateOfBirthTo);
                        Model.SearchCriteria.DateOfBirthFrom = dateOfBirthTo;
                    }
                    else
                    {
                        Model.SearchCriteria.DateOfBirthFrom = null;
                    }

                    if (Model.SearchCriteria.DateOfBirthTo != null)
                    {
                        _ = DateTime.TryParse(Model.SearchCriteria.DateOfBirthTo.Value.ToString(),
                            new CultureInfo("en-US"),
                            DateTimeStyles.None, out var dateOfBirthTo);
                        Model.SearchCriteria.DateOfBirthTo = dateOfBirthTo;
                    }
                    else
                    {
                        Model.SearchCriteria.DateOfBirthTo = null;
                    }

                    request = new HumanPersonSearchRequestModel
                    {
                        EIDSSPersonID = Model.SearchCriteria.EIDSSPersonID,
                        PersonalIDType = Model.SearchCriteria.PersonalIDType,
                        PersonalID = Model.SearchCriteria.PersonalID,
                        DateOfBirthFrom = Model.SearchCriteria.DateOfBirthFrom,
                        DateOfBirthTo = Model.SearchCriteria.DateOfBirthTo,
                        GenderTypeID = Model.SearchCriteria.GenderTypeID,
                        LastOrSurname = Model.SearchCriteria.LastOrSurname,
                        SecondName = Model.SearchCriteria.SecondName,
                        FirstOrGivenName = Model.SearchCriteria.FirstOrGivenName,
                        MonitoringSessionID = MonitoringSessionID,
                        idfsLocation = Common.GetLocationId(Model.SearchLocationViewModel),
                        SettlementTypeID = Model.SearchLocationViewModel.SettlementType == -1
                            ? null
                            : Model.SearchLocationViewModel.SettlementType
                    };
                }

                //Get lowest administrative level for location
                if (Model.SearchLocationViewModel.AdminLevel3Value.HasValue)
                    request.idfsLocation = Model.SearchLocationViewModel.AdminLevel3Value.Value;
                else if (Model.SearchLocationViewModel.AdminLevel2Value.HasValue)
                    request.idfsLocation = Model.SearchLocationViewModel.AdminLevel2Value.Value;
                else if (Model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                    request.idfsLocation = Model.SearchLocationViewModel.AdminLevel1Value.Value;
                else
                {
                    request.idfsLocation = null;
                    request.SettlementTypeID = null;
                }

                request.LanguageId = GetCurrentLanguage();

                // sorting
                if (args.Sorts?.FirstOrDefault() != null)
                {
                    request.SortColumn = args.Sorts.FirstOrDefault()?.Property;
                    request.SortOrder = args.Sorts.FirstOrDefault()
                        ?.SortOrder?.ToString().Replace("Ascending", SortConstants.Ascending)
                        .Replace("Descending", SortConstants.Descending);
                }
                else
                {
                    request.SortColumn = "EIDSSPersonID";
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

                if ((!IsNullOrEmpty(request.EIDSSPersonID) || !IsNullOrEmpty(request.PersonalID)) &&
                    request.DateOfBirthFrom is null &&
                    request.DateOfBirthTo is null &&
                    IsNullOrEmpty(request.FirstOrGivenName) &&
                    request.GenderTypeID is null &&
                    request.idfsLocation is null &&
                    IsNullOrEmpty(request.LastOrSurname) &&
                    request.MonitoringSessionID is null &&
                    request.PersonalIDType is null &&
                    IsNullOrEmpty(request.SecondName) &&
                    request.SettlementTypeID is null)
                    request.RecordIdentifierSearchIndicator = true;
                else
                    request.RecordIdentifierSearchIndicator = false;

                if (_isRecordSelected == false)
                {
                    var result = await PersonClient.GetPersonList(request, token);
                    if (source?.IsCancellationRequested == false)
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

        protected async Task HandleValidSearchSubmit(PersonSearchPageViewModel model)
        {
            if (Form.IsValid && HasCriteria(model) || MonitoringSessionID is not null)
            {
                var userPermissions = GetUserPermissions(PagePermission.AccessToPersonsList);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                await SetButtonStates();

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

        protected void OnLocationChanged(LocationViewModel locationViewModel)
        {
            //Get lowest administrative level for location
            if (locationViewModel.AdminLevel3Value.HasValue)
                Model.SearchCriteria.idfsLocation = locationViewModel.AdminLevel3Value.Value;
            else if (locationViewModel.AdminLevel2Value.HasValue)
                Model.SearchCriteria.idfsLocation = locationViewModel.AdminLevel2Value.Value;
            else if (locationViewModel.AdminLevel1Value.HasValue)
                Model.SearchCriteria.idfsLocation = locationViewModel.AdminLevel1Value.Value;
            else
                Model.SearchCriteria.idfsLocation = null;
        }

        protected async Task ResetSearch()
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
            showSearchResults = false;
            await SetButtonStates();
        }

        /// <summary>
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
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey, true);
                await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchModelKey, Model);

                // save the URI that we came form
                // next we want to load a dialog, and not navigate away

                var userPermissions = GetUserPermissions(PagePermission.AccessToPersonsList);
                if (userPermissions.Create)
                {
                    shouldRender = false;
                    var uri = $"{NavManager.BaseUri}Human/Person/Details";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    await InsufficientPermissions();
                }
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddFarmOwnerClick()
        {
            try
            {
                if (Mode == SearchModeEnum.SelectNoRedirect)
                {
                    DiagService.Close();
                }
                else
                //if (Model.SampleCategoryTypeID == (long)CaseTypeEnum.Human)
                {
                    var result = await DiagService.OpenAsync<PersonSections>(
                        Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalPersonHeading),
                        new Dictionary<string, object> { { "ShowInDialog", true } },
                        new DialogOptions
                        {
                            Style = LaboratoryModuleCSSClassConstants.AddPersonDialog,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = false,
                            Draggable = false,
                            Resizable = true
                        });

                    if (result != null)
                    {
                        if (result is PersonViewModel record)
                        {
                            //Model.HumanMasterID = record.HumanMasterID;
                            //Model.PatientFarmOrFarmOwnerName = record.FullName;
                        }

                        //Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                    }

                    if (result != null)
                    {
                        result = await DiagService.OpenAsync<FarmSections>(
                            Localizer.GetString(HeadingResourceKeyConstants.RegisterNewSampleModalFarmHeading),
                            new Dictionary<string, object>(),
                            new DialogOptions
                            {
                                Style = LaboratoryModuleCSSClassConstants.AddFarmDialog,
                                AutoFocusFirstElement = true,
                                CloseDialogOnOverlayClick = false,
                                Draggable = false,
                                Resizable = true
                            });

                        if (result != null)
                        {
                            var record = result as FarmViewModel;

                            if (record is { FarmOwnerID: null })
                            {
                                //Model.PatientFarmOrFarmOwnerName = record.FarmName ?? record.EIDSSFarmID;
                            }
                            else if (record != null)
                            {
                                //Model.PatientFarmOrFarmOwnerName = record.FarmOwnerName;
                            }

                            if (record != null)
                            {
                                //Model.HumanMasterID = record.FarmOwnerID;
                                //Model.FarmMasterID = record.FarmMasterID;
                            }

                            //Model.PatientSpeciesVectorInformation = Model.PatientFarmOrFarmOwnerName;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        protected async Task CancelSearchClicked()
        {
            switch (Mode)
            {
                case SearchModeEnum.SelectNoRedirect:
                    DialogReturnResult dialogResult = await CancelSearchAsync();
                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close("Cancelled");
                    }
                    break;

                case SearchModeEnum.Import:
                    await CancelSearchAsync();
                    break;

                default:
                    // navigate back to where we came from e.g.(veterinary/farm/details...)
                    await CancelSearchAsync();
                    //NavManager.NavigateTo($"{NavManager.Uri}", true);
                    break;
            }
        }

        protected async Task PrintResults()
        {
            if (Form.IsValid)
            {
                var nGridCount = Grid.Count;
                Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US");
                Thread.CurrentThread.CurrentUICulture = new CultureInfo("en-US");

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

                    // required parameters
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("ReportTitle", Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading)); // "Weekly Reporting List");
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("pageSize", nGridCount.ToString());

                    // optional parameters
                    reportModel.AddParameter("PersonalIDType", Model.SearchCriteria.PersonalIDType.ToString());
                    reportModel.AddParameter("PersonalID", Model.SearchCriteria.PersonalID);
                    reportModel.AddParameter("FirstOrGivenName", Model.SearchCriteria.FirstOrGivenName);
                    reportModel.AddParameter("SecondName", Model.SearchCriteria.SecondName);
                    reportModel.AddParameter("LastOrSurname", Model.SearchCriteria.LastOrSurname);

                    if (Model.SearchCriteria.DateOfBirthFrom != null)
                        reportModel.AddParameter("DateOfBirthFrom", Model.SearchCriteria.DateOfBirthFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.DateOfBirthTo != null)
                        reportModel.AddParameter("DateOfBirthTo", Model.SearchCriteria.DateOfBirthTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("GenderTypeID", Model.SearchCriteria.GenderTypeID.ToString());
                    reportModel.AddParameter("EIDSSPersonID", Model.SearchCriteria.EIDSSPersonID);
                    reportModel.AddParameter("idfsLocation", locationId.ToString());
                    reportModel.AddParameter("MonitoringSessionID", MonitoringSessionID.HasValue ? MonitoringSessionID.ToString() : "");
                    reportModel.AddParameter("SettlementTypeID", Model.SearchLocationViewModel.AdminLevel3LevelType is > 0 ? Model.SearchLocationViewModel.AdminLevel3LevelType.ToString() : "");

                    reportModel.AddParameter("sortColumn", Model.SearchCriteria.SortColumn);
                    reportModel.AddParameter("sortOrder", Model.SearchCriteria.SortOrder);

                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.PersonPageHeading),
                        new Dictionary<string, object> { { "ReportName", "SearchForPersonRecord" }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = ReportSessionTypeConstants.HumanActiveSurveillanceSession,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1100px"
                        });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            }
        }

        protected async Task OpenEdit(long humanMasterId)
        {
            _isRecordSelected = true;

            // persist search results before navigation
            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey, true);
            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchModelKey, Model);

            shouldRender = false;
            var uri = $"{NavManager.BaseUri}Human/Person/Details/?id={humanMasterId}";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLink(long humanMasterId)
        {
            try
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

                            var url = CallbackUrl + $"?Id={humanMasterId}";

                            if (CallbackKey != null)
                            {
                                url += "&callbackkey=" + CallbackKey;
                            }
                            NavManager.NavigateTo(url, true);
                            break;
                        }
                    case SearchModeEnum.Select:
                        DiagService.Close(Model.SearchResults.First(x => x.HumanMasterID == humanMasterId));
                        break;
                    case SearchModeEnum.SelectNoRedirect:
                        {
                            string building, apartment, postalCode;
                            var house = building = apartment = postalCode = Empty;

                            HumanPersonDetailsRequestModel request = new()
                            {
                                HumanMasterID = humanMasterId,
                                LangID = GetCurrentLanguage()
                            };

                            var personDetailList = await PersonClient.GetHumanDiseaseReportPersonInfoAsync(request);

                            if (personDetailList is { Count: > 0 })
                            {
                                var personDetail = personDetailList.FirstOrDefault();

                                if (personDetail != null)
                                {
                                    house = personDetail.HumanstrHouse;
                                    building = personDetail.HumanstrBuilding;
                                    apartment = personDetail.HumanstrApartment;
                                    postalCode = personDetail.HumanstrPostalCode;
                                }
                            }

                            Model.SearchResults.First(x => x.HumanMasterID == humanMasterId).House = house;
                            Model.SearchResults.First(x => x.HumanMasterID == humanMasterId).Building = building;
                            Model.SearchResults.First(x => x.HumanMasterID == humanMasterId).Apartment = apartment;
                            Model.SearchResults.First(x => x.HumanMasterID == humanMasterId).PostalCode = postalCode;

                            DiagService.Close(Model.SearchResults.First(x => x.HumanMasterID == humanMasterId));
                            break;
                        }
                    default:
                        {
                            isLoading = false;
                            // persist search results before navigation
                            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchPerformedIndicatorKey, true);
                            await BrowserStorage.SetAsync(SearchPersistenceKeys.PersonSearchModelKey, Model);

                            shouldRender = false;
                            var uri = $"{NavManager.BaseUri}Human/Person/DetailsReviewPage/?id={humanMasterId}&reviewPageNo=3";
                            NavManager.NavigateTo(uri, true);
                            break;
                        }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task GetPersonalIdTypesAsync(LoadDataArgs args)
        {
            PersonnelIdTypes ??=
                await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.PersonalIDType, null);
            PersonnelIdTypesFiltered = args.Filter != "" ? PersonnelIdTypes.Where(x => x.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList() : PersonnelIdTypes;

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetGenderTypesAsync(LoadDataArgs args)
        {
            GenderIdTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.HumanGender, null);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = GenderIdTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                GenderIdTypes = toList;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Private Methods

        private async Task SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.PersonsListPermissions.Create)
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

        private void InitializeModel()
        {
            var bottomAdmin = _tokenService.GetAuthenticatedUser().BottomAdminLevel;

            Model = new PersonSearchPageViewModel
            {
                SearchCriteria = new HumanPersonSearchRequestModel(),
                SearchResults = new List<PersonViewModel>()
            };
            count = 0;
            Model.PersonsListPermissions = new UserPermissions();
            Model.HumanDiseaseReportDataPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            Model.PersonsListPermissions = GetUserPermissions(PagePermission.AccessToPersonsList);
            Model.SearchCriteria.SortColumn = "EIDSSPersonID";
            Model.SearchCriteria.SortOrder = "desc";

            //initialize the location control
            Model.SearchLocationViewModel = new()
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
            };
        }

        private bool VerifyOutbreakCasePermissions()
        {
            var userPermissions = GetUserPermissions(PagePermission.AccessToOutbreakHumanCaseData);

            return userPermissions.Create;
        }

        private static bool HasCriteria(PersonSearchPageViewModel model)
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

        #endregion
    }
}