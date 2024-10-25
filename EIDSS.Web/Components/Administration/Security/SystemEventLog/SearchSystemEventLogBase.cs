
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Reflection;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemEventLog;
using EIDSS.Web.Components.Administration.DataAudit;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static System.String;

namespace EIDSS.Web.Components.Administration.Security.SystemEventLog
{
    public class SearchSystemEventLogBase : SearchComponentBase<SearchSystemEventLogBase>, IDisposable
    {

        #region Grid Column Chooser Reorder
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public CrossCutting.GridExtensionBase GridExtension { get; set; }

        //[Inject]
        //protected TimeZoneService TimeZoneService { get; set; }

        /// <summary>
        /// OnInitialized
        /// </summary>
        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("SearchPersonHumanModule");

            base.OnInitialized();
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="columnNameId"></param>
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
        private async Task StateContainerChangeAsync(string property)
        {

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Globals

        [Inject]
        private ISystemEventClient SystemEventClient { get; set; }

        [Inject]
        private IEmployeeClient EmployeeClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchTransactionLogBase> Logger { get; set; }

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<SystemEventLogGetListViewModel> Grid;
        protected RadzenTemplateForm<SystemEventLogSearchPageViewModel> Form;
        protected SystemEventLogSearchPageViewModel Model;

        protected IEnumerable<UserModel> UserList;
        protected IEnumerable<BaseReferenceViewModel> EventTypeList;

        protected int UserCount;

        #endregion

        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            InitializeModel();

            // see if a search was saved
            ProtectedBrowserStorageResult<bool> indicatorResult = await BrowserStorage.GetAsync<bool>(EIDSSConstants.SearchPersistenceKeys.SystemEventLogSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult.Success && indicatorResult.Value;
            if (searchPerformedIndicator)
            {
                ProtectedBrowserStorageResult<SystemEventLogSearchPageViewModel> searchModelResult = await BrowserStorage.GetAsync<SystemEventLogSearchPageViewModel>(EIDSSConstants.SearchPersistenceKeys.SystemEventLogSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    Model.SearchCriteria = searchModel.SearchCriteria;
                    Model.SearchResults = searchModel.SearchResults;
                    count = Model.SearchResults.Count();

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
            }

            await SetButtonStates();

            await GetUserListAsync();

            await base.OnInitializedAsync();
        }


        private void InitializeModel()
        {

            Model = new()
            {
                SearchCriteria = new SystemEventLogGetRequestModel(),
                SearchResults = new List<SystemEventLogGetListViewModel>()
            };
            count = 0;

            Model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToSecurityLog);
            Model.SearchCriteria.SortColumn = "EventDate";
            Model.SearchCriteria.SortOrder = "DESC";


        }

        private void SetDefaults()
        {
            var systemPreferences = ConfigurationService.SystemPreferences;
            Model.SearchCriteria.ToDate = DateTime.Today;
            Model.SearchCriteria.FromDate = DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
        }

        private async Task SetButtonStates()
        {
            if (expandSearchCriteria)
            {
                showSearchCriteriaButtons = true;
            }
            else
            {
                showSearchCriteriaButtons = false;
            }


            if (!Model.Permissions.Create)
            {
                disableAddButton = true;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task HandleValidSearchSubmit(SystemEventLogSearchPageViewModel dataModel)
        {
            if (Form.IsValid && HasCriteria(dataModel))
            {
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

        private bool HasCriteria(SystemEventLogSearchPageViewModel dataModel)
        {
            PropertyInfo[] properties = dataModel.SearchCriteria.GetType().GetProperties()
                .Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                if (prop.GetValue(dataModel.SearchCriteria) != null)
                {
                    if (prop.PropertyType == typeof(System.String))
                    {
                        var value = prop.GetValue(dataModel.SearchCriteria)?.ToString().Trim();
                        if (!string.IsNullOrWhiteSpace(value)) return true;
                        if (!string.IsNullOrEmpty(value)) return true;
                    }
                    else
                    {
                        return true;
                    }
                }
            }
            return false;
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
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    source = new();
                    token = source.Token;
                    expandSearchCriteria = true;
                    await SetButtonStates();
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;
            }
        }

        protected async Task AccordionClick(int index)
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
            await SetButtonStates();
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                isLoading = true;
                showSearchResults = true;

                var request = new SystemEventLogGetRequestModel()
                {
                    //StartDate = DateTime.Now.AddDays(
                    //    Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault * -1)),
                    //EndDate = DateTime.Now,
                    FromDate = Model.SearchCriteria.FromDate,
                    ToDate = Model.SearchCriteria.ToDate,
                    EventTypeId = Model.SearchCriteria.EventTypeId,
                    UserId = Model.SearchCriteria.UserId,
                    LanguageId = GetCurrentLanguage(),
                    
                };

                // sorting
                if (args.Sorts.FirstOrDefault() != null)
                {
                    request.SortColumn = args.Sorts.FirstOrDefault().Property;
                    request.SortOrder = args.Sorts.FirstOrDefault().SortOrder.Value
                        .ToString().Replace("Ascending", "ASC").Replace("Descending", "DESC");
                }
                else
                {
                    request.SortColumn = "EventDate";
                    request.SortOrder = "DESC";
                }

                // paging
                if (args.Skip is > 0 && searchSubmitted == false)
                {
                    request.Page = (args.Skip.Value / Grid.PageSize) + 1;
                }
                else
                {
                    request.Page = 1;
                }
                request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;

                var result = await SystemEventClient.GetSystemEventLogList(request, token);
                if (result != null)
                {
                    //result.ForEach( r=>r.datActionDate = TimeZoneService.GetLocalDateTime(DateTime.SpecifyKind(r.datActionDate.ToLocalTime(),DateTimeKind.Utc).ToLocalTime()).ConfigureAwait(false));

                }

                if (source?.IsCancellationRequested == false)
                {
                    Model.SearchResults = result;
                    count = Model.SearchResults.FirstOrDefault() != null ? Model.SearchResults.FirstOrDefault().TotalRowCount.Value : 0;
                    if (searchSubmitted) { await Grid.FirstPage(); }
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

        protected async Task GetUserListAsync()
        {
            var userGetListRequestModel = new UserGetRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                SortColumn = "Name",
                PageSize = 10000,
                SortOrder = "ASC"
            };
            UserList = await CrossCuttingClient.GetGblUserList(userGetListRequestModel);
            UserCount = UserList.Count();
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetEventTypeListAsync(LoadDataArgs args)
        {
            EventTypeList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.EventType, null);

            if (!IsNullOrEmpty(args.Filter))
                EventTypeList = EventTypeList.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        protected async void CancelSearchClicked()
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
                    await CancelSearchAsync();

                    break;
            }
        }

        protected async Task SendReportLink(SystemEventLogGetListViewModel systemEventLogGetListViewModel  )
        {
            try
            {

                // persist search results before navigation
                await BrowserStorage.SetAsync(EIDSSConstants.SearchPersistenceKeys.SystemEventLogSearchPerformedIndicatorKey, true);
                await BrowserStorage.SetAsync(EIDSSConstants.SearchPersistenceKeys.SystemEventLogSearchModelKey, Model);

                shouldRender = false;

                //Construct a path based on EventType

                // Need to Implement a logic based on EventTypeId

                var uri = BuildUri(systemEventLogGetListViewModel);

                //if (systemEventLogGetListViewModel.idfsCaseType == (long?) EIDSS.Domain.Enumerations.CaseTypeEnum.Avian)
                //{

                //}

                //if (systemEventLogGetListViewModel.idfsCaseType == (long?)EIDSS.Domain.Enumerations.CaseTypeEnum.Livestock)
                //{

                //}

                //var path =   $"{systemEventLogGetListViewModel.Area}/{systemEventLogGetListViewModel.SubArea}/{systemEventLogGetListViewModel.strEditAction}";

                //var query = $"?{systemEventLogGetListViewModel.strEditActionParm}={systemEventLogGetListViewModel.ObjectId}&isReadOnly=true";
                ////var uri = $"{NavManager.BaseUri}{path}{query}";
                //NavManager.NavigateTo(uri, true);
    
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        private string BuildUri(SystemEventLogGetListViewModel model)
        {
            var uri = "";

            return uri;

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

        #endregion

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
        }
    }
}
