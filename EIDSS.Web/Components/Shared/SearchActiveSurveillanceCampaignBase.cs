using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Shared.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Shared
{
    public class SearchActiveSurveillanceCampaignBase : SearchComponentBase<SearchActiveSurveillanceCampaignViewModel>,
        IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        [Inject] private IConfigurationClient ConfigurationClient { get; set; }

        [Inject] protected GridContainerServices GridContainerServices { get; set; }

        public GridExtensionBase GridExtension { get; set; }

        [Inject] private ILogger<SearchActiveSurveillanceCampaignBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public long CampaignCategoryId { get; set; }

        #endregion

        #region Private Members

        private int _haCode;
        private int _accessoryCode;
        protected UserPermissions Permissions;
        private string _indicatorKey;
        private string _modelKey;
        private string _addPath;
        private string _editPath;
        private bool _isRecordSelected;

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<ActiveSurveillanceCampaignListViewModel> Grid;
        protected RadzenTemplateForm<SearchActiveSurveillanceCampaignViewModel> Form;
        protected SearchActiveSurveillanceCampaignViewModel Model;
        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases;
        protected IEnumerable<BaseReferenceViewModel> CampaignStatuses;
        protected IEnumerable<BaseReferenceViewModel> CampaignTypes;
        protected DateTime MinDate;
        protected string MinDateValidationMessage;

        #endregion

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            LoadingComponentIndicator = true;

            _logger = Logger;
            MinDate = new DateTime(1900, 1, 1);
            MinDateValidationMessage = $"No dates earlier than {MinDate} are allowed";

            if (CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human))
            {
                _accessoryCode = HACodeList.HumanHACode;
                _haCode = HACodeList.HumanHACode;
                Permissions = GetUserPermissions(PagePermission.AccessToHumanActiveSurveillanceCampaign);
                _indicatorKey = SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchPerformedIndicatorKey;
                _modelKey = SearchPersistenceKeys.HumanActiveSurveillanceCampaignSearchModelKey;
                _addPath = "Human/ActiveSurveillanceCampaign/Add";
                _editPath = "Human/ActiveSurveillanceCampaign/Details";
            }
            else
            {
                _accessoryCode = HACodeList.LiveStockAndAvian;
                _haCode = HACodeList.ASHACode;
                Permissions = GetUserPermissions(PagePermission.AccessToVeterinaryActiveSurveillanceCampaign);
                _indicatorKey = SearchPersistenceKeys.VeterinaryActiveSurveillanceCampaignSearchPerformedIndicatorKey;
                _modelKey = SearchPersistenceKeys.VeterinaryActiveSurveillanceCampaignSearchModelKey;
                _addPath = "Veterinary/ActiveSurveillanceCampaign/Add";
                _editPath = "Veterinary/ActiveSurveillanceCampaign/Details";
            }

            //initialize model
            InitializeModel();

            // see if a search was saved
            var indicatorResult = await BrowserStorage.GetAsync<bool>(_indicatorKey);
            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
            if (searchPerformedIndicator)
            {
                var searchModelResult =
                    await BrowserStorage.GetAsync<SearchActiveSurveillanceCampaignViewModel>(_modelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchResults = searchModel.SearchResults;
                    if (Model.SearchResults != null)
                        count = Model.SearchResults.Count;

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
        /// 
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                LoadingComponentIndicator = false;

                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
        }

        protected void AccordionClick(int index)
        {
            expandSearchCriteria = index switch
            {
                //search criteria toggle
                0 => !expandSearchCriteria,
                _ => expandSearchCriteria
            };

            SetButtonStates();
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
                {"DialogName", "NarrowSearch"},
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)}
            };
            var result =
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
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

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                isLoading = true;
                showSearchResults = true;

                var request = new ActiveSurveillanceCampaignRequestModel
                {
                    CampaignID = Model.SearchCriteria.CampaignID,
                    LegacyCampaignID = Model.SearchCriteria.LegacyCampaignID,
                    CampaignName = Model.SearchCriteria.CampaignName,
                    CampaignStatusTypeID = Model.SearchCriteria.CampaignStatusTypeID,
                    CampaignTypeID = Model.SearchCriteria.CampaignTypeID,
                    CampaignCategoryID = CampaignCategoryId,
                    DiseaseID = Model.SearchCriteria.DiseaseID,
                    StartDateFrom = Model.SearchCriteria.StartDateFrom,
                    StartDateTo = Model.SearchCriteria.StartDateTo,
                    ApplySiteFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    LanguageId = GetCurrentLanguage(),
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                    UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    //sorting
                    SortColumn = !IsNullOrEmpty(args.OrderBy)
                        ? args.Sorts.FirstOrDefault()?.Property
                        : "CampaignID",
                    SortOrder = args.Sorts.FirstOrDefault() != null
                        ? args.Sorts.FirstOrDefault()?.SortOrder.ToString() == "Ascending" ? SortConstants.Ascending : SortConstants.Descending
                        : SortConstants.Descending
                };
                //paging
                if (args.Skip is > 0)
                    request.Page = args.Skip.Value / Grid.PageSize + 1;
                else
                    request.Page = 1;
                request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;

                if (_isRecordSelected == false)
                {
                    var result = await CrossCuttingClient.GetActiveSurveillanceCampaignListAsync(request, token);
                    if (source.IsCancellationRequested == false)
                    {
                        Model.SearchResults = result;
                        count = Model.SearchResults.FirstOrDefault() != null
                            ? Model.SearchResults.First().TotalRowCount
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

        protected async Task HandleValidSearchSubmit(SearchActiveSurveillanceCampaignViewModel model)
        {
            if (Form.IsValid && HasCriteria(model))
            {
                var userPermissions = GetUserPermissions(CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) ? PagePermission.AccessToHumanActiveSurveillanceCampaign : PagePermission.AccessToVeterinaryActiveSurveillanceCampaign);
                if (!userPermissions.Read)
                    await InsufficientPermissionsRedirectAsync($"{NavManager.BaseUri}Administration/Dashboard");

                searchSubmitted = true;
                expandSearchCriteria = false;
                SetButtonStates();

                if (Grid != null) await Grid.Reload();
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
            await CancelSearchAsync();
        }

        protected void ResetSearch()
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
        }

        protected async Task CancelSearch()
        {
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
                {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)}
            };
            var result =
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
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
                //cancel search but user said no so leave everything alone and cancel thread
                source?.Cancel();
            }
        }

        protected async Task OpenAddAsync()
        {
            if (Mode == SearchModeEnum.SelectNoRedirect)
            {
                DiagService.Close("Add");
            }
            else
            {
                //persist search results before navigation
                await BrowserStorage.SetAsync(_indicatorKey, true);
                await BrowserStorage.SetAsync(_modelKey, Model);

                var userPermissions = GetUserPermissions(CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human) ? PagePermission.AccessToHumanActiveSurveillanceCampaign : PagePermission.AccessToVeterinaryActiveSurveillanceCampaign);
                if (userPermissions.Create)
                {
                    shouldRender = false;
                    var uri = $"{NavManager.BaseUri}{_addPath}";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    await InsufficientPermissions();
                }
            }
        }

        protected async Task OpenEditAsync(long campaignId)
        {
            _isRecordSelected = true;

            //persist search results before navigation
            await BrowserStorage.SetAsync(_indicatorKey, true);
            await BrowserStorage.SetAsync(_modelKey, Model);
            shouldRender = false;
            var query = $"?campaignId={campaignId}";
            var uri = $"{NavManager.BaseUri}{_editPath}{query}";

            NavManager.NavigateTo(uri, true);
        }

        protected async Task SendReportLinkAsync(long campaignId)
        {
            _isRecordSelected = true;

            switch (Mode)
            {
                case SearchModeEnum.Import:
                {
                    if (CallbackUrl.EndsWith('/')) CallbackUrl = CallbackUrl[..^1];

                    var url = CallbackUrl + $"?Id={campaignId}";

                    if (CallbackKey != null) url += "&callbackkey=" + CallbackKey;
                    NavManager.NavigateTo(url, true);
                    break;
                }
                case SearchModeEnum.Select:
                    DiagService.Close(Model.SearchResults.First(x => x.CampaignKey == campaignId));
                    break;
                case SearchModeEnum.SelectNoRedirect:
                    shouldRender = false;
                    DiagService.Close(Model.SearchResults.First(x => x.CampaignKey == campaignId));
                    break;
                case SearchModeEnum.Default:
                    // persist search results before navigation
                    await BrowserStorage.SetAsync(_indicatorKey, true);
                    await BrowserStorage.SetAsync(_modelKey, Model);
                    shouldRender = false;
                    var query = $"?campaignId={campaignId}&isReadOnly=true";
                    var uri = $"{NavManager.BaseUri}{_editPath}{query}";
                    NavManager.NavigateTo(uri, true);
                    break;
                case SearchModeEnum.SelectEvent:
                    break;
            }
        }


        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = _accessoryCode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetStatusTypesAsync(LoadDataArgs args)
        {
            CampaignStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.ASCampaignStatus, _accessoryCode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = CampaignStatuses.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                CampaignStatuses = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetCampaignTypesAsync(LoadDataArgs args)
        {
            CampaignTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.ASCampaignType, _accessoryCode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = CampaignTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                CampaignTypes = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Private Methods

        private void SetButtonStates()
        {
            showSearchCriteriaButtons = expandSearchCriteria;

            if (!Model.Permissions.Create) disableAddButton = true;
        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
        }

        private void InitializeModel()
        {
            Model = new SearchActiveSurveillanceCampaignViewModel
            {
                Permissions = Permissions,
                SearchCriteria =
                {
                    SortColumn = "CampaignID",
                    SortOrder = SortConstants.Descending
                }
            };
        }

        private static bool HasCriteria(SearchActiveSurveillanceCampaignViewModel model)
        {
            var properties = model.SearchCriteria.GetType().GetProperties()
                .Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
                if (prop.GetValue(model.SearchCriteria) != null)
                {
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

            return false;
        }


        protected async Task PrintCampaignSearchResults(SearchActiveSurveillanceCampaignViewModel searchModel)
        {
            if (Form.IsValid)
            {
                var nGridCount = Grid.Count;

                    //TODO: remove commented if session-User approach works//var organization = ConfigurationService.GetUserToken().Organization;

                try
                {
                    //TODO: consider usage of _tokenService.GetAuthenticatedUser().Organization
                    var organization = authenticatedUser.Organization;


                    var reportTitle = CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human)
                        ? Localizer.GetString(HeadingResourceKeyConstants
                            .HumanActiveSurveillanceCampaignHumanActiveSurveillanceCampaignHeading)
                        : Localizer.GetString(HeadingResourceKeyConstants.VeterinaryActiveSurveillancePageHeading);

                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("ReportTitle", reportTitle);
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("PageSize", nGridCount.ToString());
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("CampaignID", searchModel.SearchCriteria.CampaignID);
                    reportModel.AddParameter("LegacyCampaignID", searchModel.SearchCriteria.LegacyCampaignID);
                    reportModel.AddParameter("CampaignName", searchModel.SearchCriteria.CampaignName);
                    reportModel.AddParameter("CampaignTypeID", searchModel.SearchCriteria.CampaignTypeID.ToString());
                    reportModel.AddParameter("CampaignStatusTypeID",
                        searchModel.SearchCriteria.CampaignStatusTypeID.ToString());
                    reportModel.AddParameter("CampaignCategoryID", CampaignCategoryId.ToString());
                    if (Model.SearchCriteria.StartDateFrom != null)
                        if (searchModel.SearchCriteria.StartDateFrom != null)
                            reportModel.AddParameter("StartDateFrom",
                                searchModel.SearchCriteria.StartDateFrom.Value.ToString("d", cultureInfo));
                    if (Model.SearchCriteria.StartDateTo != null)
                        if (searchModel.SearchCriteria.StartDateTo != null)
                            reportModel.AddParameter("StartDateTo",
                                searchModel.SearchCriteria.StartDateTo.Value.ToString("d", cultureInfo));
                    reportModel.AddParameter("DiseaseID", searchModel.SearchCriteria.DiseaseID.ToString());
                    reportModel.AddParameter("UserSiteID", _tokenService.GetAuthenticatedUser().SiteId);
                    reportModel.AddParameter("UserEmployeeID", _tokenService.GetAuthenticatedUser().PersonId);
                    reportModel.AddParameter("ApplySiteFiltrationIndicator",
                        _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel ? "1" : "0");
                    reportModel.AddParameter("UserOrganization", organization);

                    var reportName = CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human)
                        ? "SearchForHumanActiveSurveillanceCampaign"
                        : "SearchForVeterinaryActiveSurveillanceCampaign";

                    await DiagService.OpenAsync<DisplayReport>(
                        reportTitle,
                        new Dictionary<string, object>
                            { { "ReportName", reportName }, { "Parameters", reportModel.Parameters } },
                        new DialogOptions
                        {
                            Style = CampaignCategoryId == Convert.ToInt64(CampaignCategory.Human)
                                ? ReportSessionTypeConstants.HumanActiveSurveillanceCampaign
                                : ReportSessionTypeConstants.VeterinaryActiveSurveillanceCampaign,
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

        #endregion

        #region Grid Column Reorder

        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("ActiveSurveillanceCampaign");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig =
                    GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient,
                    Grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
                GridContainerServices.VisibleColumnList =
                    GridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        #endregion
    }
}