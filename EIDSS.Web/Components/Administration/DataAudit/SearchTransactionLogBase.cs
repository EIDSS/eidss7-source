using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq.Dynamic.Core;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.DataAudit;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Components.Human.SearchPerson;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Radzen.Blazor;
using System.Linq;
using System.Reflection;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.Extensions.Localization;
using Radzen;

namespace EIDSS.Web.Components.Administration.DataAudit
{
    public class SearchTransactionLogBase : SearchComponentBase<TransactionLogSearchPageViewModel>,IDisposable
    {

        #region Grid Column Chooser Reorder
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }
        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }
        public CrossCutting.GridExtensionBase GridExtension { get; set; }

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
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
        private IDataAuditClient DataAuditClient { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        private IEmployeeClient EmployeeClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchTransactionLogBase> Logger { get; set; }

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<DataAuditTransactionLogGetListViewModel> grid;
        protected RadzenTemplateForm<TransactionLogSearchPageViewModel> form;
        protected TransactionLogSearchPageViewModel model;
        protected IEnumerable<SiteModel> siteList;
        protected IEnumerable<UserModel> userList;
        protected IEnumerable<BaseReferenceViewModel> actionList;
        protected IEnumerable<BaseReferenceViewModel> objectTypeList;
        protected int siteCount;
        protected int userCount;
        protected bool disableObjectId =true;
        public const string DialogWidth = "800px";
        public const string DialogHeight = "530px";
        public const string LargeDialogWidth = "80%";
        //public const string LargeDialogHeight = "80%";

        #endregion


        #region Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            InitializeModel();

            // see if a search was saved
            ProtectedBrowserStorageResult<bool> indicatorResult = await BrowserStorage.GetAsync<bool>(EIDSSConstants.SearchPersistenceKeys.DataAuditTransLogSearchPerformedIndicatorKey);
            var searchPerformedIndicator = indicatorResult.Success && indicatorResult.Value;
            if (searchPerformedIndicator)
            {
                ProtectedBrowserStorageResult<TransactionLogSearchPageViewModel> searchModelResult = await BrowserStorage.GetAsync<TransactionLogSearchPageViewModel>(EIDSSConstants.SearchPersistenceKeys.DataAuditTransLogSearchModelKey);
                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null)
                {
                    isLoading = true;

                    model.SearchCriteria = searchModel.SearchCriteria;
                    model.SearchResults = searchModel.SearchResults;
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

            await GeSiteListsAsync();
            await GetUserListAsync();
            await GetActionListAsync();
            await GetObjectTypeListAsync();

            await base.OnInitializedAsync();
        }

        private void InitializeModel()
        {

            model = new ()
            {
                SearchCriteria = new DataAuditLogGetRequestModel(),
                SearchResults = new List<DataAuditTransactionLogGetListViewModel>()
            };
            count = 0;
            
            model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.CanRestoreDeletedRecords);
            model.VetActiveSurveillanceCampPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryActiveSurveillanceCampaign);
            model.VetActiveSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryActiveSurveillanceSession);
            model.VectorSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVectorSurveillanceSession);
            model.HumanAggregateDiseaseRepPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanAggregateDiseaseReports);
            model.WeeklyReportFormPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.HumanWeeklyReport);
            model.IliAggregateReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToILIAggregateFormData);
            model.HumanDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanDiseaseReportData);
            model.OutBreakSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToOutbreakSessions);
            model.VetAggregateActionReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateActions);
            model.VetAggregateDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateDiseaseReports);
            model.VetDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryDiseaseReportsData);
            model.HumanActiveSurveillanceCampPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanActiveSurveillanceCampaign);
            model.HumanActiveSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanActiveSurveillanceSession);

            model.SearchCriteria.SortColumn = "TransactionDate";
            model.SearchCriteria.SortOrder = "DESC";

            
        }

        protected async Task HandleValidSearchSubmit(TransactionLogSearchPageViewModel dataModel)
        {
            if (form.IsValid && HasCriteria(dataModel))
            {
                searchSubmitted = true;
                expandSearchCriteria = false;
                await SetButtonStates();

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

        private bool HasCriteria(TransactionLogSearchPageViewModel dataModel)
        {
            PropertyInfo[] properties = dataModel.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

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
        #endregion

        #region Private Methods

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


            if (!model.Permissions.Create)
            {
                disableAddButton = true;
            }

            await InvokeAsync(StateHasChanged);
        }

        private void SetDefaults()
        {
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);

            var systemPreferences = ConfigurationService.SystemPreferences;
            model.SearchCriteria.EndDate = DateTime.Today;
            model.SearchCriteria.StartDate= DateTime.Today.AddDays(-systemPreferences.NumberDaysDisplayedByDefault);
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

                var request = new DataAuditLogGetRequestModel
                {
                    //StartDate = DateTime.Now.AddDays(
                    //    Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault * -1)),
                    //EndDate = DateTime.Now,
                    StartDate = model.SearchCriteria.StartDate,
                    EndDate = model.SearchCriteria.EndDate,
                    IdfSiteId = model.SearchCriteria.IdfSiteId,
                    IdfActionId = model.SearchCriteria.IdfActionId,
                    IdfUserId = model.SearchCriteria.IdfUserId,
                    IdfObjectId = model.SearchCriteria.IdfObjectId,
                    IdfObjetType = model.SearchCriteria.IdfObjetType,
                    LanguageId = GetCurrentLanguage()
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
                    request.SortColumn = "TransactionDate";
                    request.SortOrder = "DESC";
                }

                // paging
                if (args.Skip is > 0 && searchSubmitted == false)
                {
                    request.Page = (args.Skip.Value / grid.PageSize) + 1;
                }
                else
                {
                    request.Page = 1;
                }
                request.PageSize = grid.PageSize != 0 ? grid.PageSize : 10;

                var result = await DataAuditClient.GetTransactionLog(request, token);
                if (result.Count > 0)
                {
                    result.ForEach(c => c.UserName = $"{c.userFirstName} {c.userFamilyName}");
                }

                if (source?.IsCancellationRequested == false)
                {
                    model.SearchResults = result;
                    count = model.SearchResults.FirstOrDefault() != null ? model.SearchResults.First().TotalRowCount : 0;
                    if (searchSubmitted) { await grid.FirstPage(); }
                }
                StateHasChanged();
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

        protected async Task GeSiteListsAsync()
        {
            var siteGblGetRequestModel = new SiteGblGetRequestModel()
            {
                ApplySiteFiltrationIndicator = false,
                LanguageId = GetCurrentLanguage(),
                SortColumn = "SiteName",
                PageSize = 10000,
                 SortOrder = "ASC"
            };

            siteList = await CrossCuttingClient.GetGblSiteList(siteGblGetRequestModel, token);
            siteCount = siteList.Count();

            //var siteGetRequestModel = new SiteGetRequestModel()
            //{
            //    OrganizationID = _tokenService.GetAuthenticatedUser().OfficeId,
            //    SortColumn = "SiteName",
            //    PageSize = 10000,
            //    SortOrder = "ASC",
            //    LanguageId = GetCurrentLanguage()

            //};
            //siteList = await SiteClient.GetSiteList(siteGetRequestModel);
            //siteCount = siteList.Count();
            await InvokeAsync(StateHasChanged);
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
            userList = await CrossCuttingClient.GetGblUserList(userGetListRequestModel);
            userCount = userList.Count();

            //var employeeGetListRequestModel = new EmployeeGetListRequestModel()
            //{
            //    PageSize = 10000,
            //    LanguageId = GetCurrentLanguage(),
            //    OrganizationID = _tokenService.GetAuthenticatedUser().OfficeId,
            //    SortOrder = "ASC",
            //    SortColumn = "EmployeeID"
            //};

            //userList = await EmployeeClient.GetEmployeeList(employeeGetListRequestModel);
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetActionListAsync()
        { 
            actionList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.DataAuditEventType, null);
        }

        protected async Task GetObjectTypeListAsync()
        {
            objectTypeList = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.DataAuditObjectType, null);
          
        }

        /// <summary>
        /// </summary>
        protected async void CancelSearchClicked()
        {
            switch (Mode)
            {
                case SearchModeEnum.SelectNoRedirect:
                    DiagService.Close("Cancelled");
                    break;
                case SearchModeEnum.Import:
                   await CancelSearchAsync();
                    break;
                default:
                    // navigate back to where we came from e.g.(veterinary/farm/details...)
                    NavManager.NavigateTo($"{NavManager.Uri}", true);
                    break;
            }
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

        public async Task OpenEdit(DataAuditTransactionLogGetListViewModel dataModel)
        {
            try
            {
                // persist search results before navigation
                await BrowserStorage.SetAsync(EIDSSConstants.SearchPersistenceKeys.DataAuditTransLogSearchPerformedIndicatorKey, true);
                await BrowserStorage.SetAsync(EIDSSConstants.SearchPersistenceKeys.DataAuditTransLogSearchModelKey, model);

                //TransactionLogDetailPageViewModel transactionLogPageModel = new TransactionLogDetailPageViewModel()
                //{
                //    SearchResults = new List<DataAuditTransactionLogGetDetailViewModel>(),
                //    SelectedRecord = dataModel
                //};

                //transactionLogPageModel.SelectedRecord._transDate = transactionLogPageModel.SelectedRecord.TransactionDate.ToString();


                Dictionary<string, object> dialogParams = new()
                {
                    { "SelectedAuditRecord", dataModel }

                };
                dynamic dialogService = await DiagService.OpenAsync<DataAuditComponent>(
                    Localizer.GetString(HeadingResourceKeyConstants.DataAuditLogDetailsDataAuditTransactionDetailsHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = DialogWidth,
                        //Height = DialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

               

            }
            catch (Exception e)
            {
                _logger.LogError(e.Message, null);
                throw;
            }
           


        }

        protected void OnChangeObjectType(object args)
        {
            model.SearchCriteria.IdfObjectId = null;
            if (args == null)
            {
                disableObjectId = true;
            }
            else
            {
                if ((long) args == (long) DataAuditObjectTypeEnum.VetActiveSurveillanceCampaign ||
                    (long)args == (long)DataAuditObjectTypeEnum.VetActiveSurveillanceSessiion ||
                    (long)args == (long)DataAuditObjectTypeEnum.HumanActiveSurveillanceSession ||
                    (long) args == (long) DataAuditObjectTypeEnum.HumanActiveSurveillanceCampaign ||
                    (long) args == (long) DataAuditObjectTypeEnum.VectorSurveillanceSession ||
                    (long) args == (long) DataAuditObjectTypeEnum.AggregateHumanCase ||
                    // (long) args == (long)  DataAuditObjectTypeEnum.weekly || // For weekly reporting form
                    // (long) args == (long) DataAuditObjectTypeEnum.ili ||  // For ILI Aggregate Report
                    (long) args == (long) DataAuditObjectTypeEnum.HumanCase ||
                    (long) args == (long) DataAuditObjectTypeEnum.Outbreak ||
                    (long) args == (long) DataAuditObjectTypeEnum.VetAggregateAction ||
                    (long) args == (long) DataAuditObjectTypeEnum.VetAggregateCase ||
                    (long) args == (long) DataAuditObjectTypeEnum.VeterinaryCase ||
                    (long)args == (long)DataAuditObjectTypeEnum.HumanDiseaseReport)

                {
                    disableObjectId = false;
                }
                else
                {
                    disableObjectId = true;
                }
            }
        }

        //protected bool DisableObjectId()
        //{
           
        //    model.VetActiveSurveillanceCampPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryActiveSurveillanceCampaign);
        //    model.VetActiveSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryActiveSurveillanceSession);
        //    model.VectorSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVectorSurveillanceSession);
        //    model.HumanAggregateDiseaseRepPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanAggregateDiseaseReports);
        //    model.WeeklyReportFormPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.HumanWeeklyReport);
        //    model.IliAggregateReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToILIAggregateFormData);
        //    model.HumanDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanDiseaseReportData);
        //    model.OutBreakSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToOutbreakSessions);
        //    model.VetAggregateActionReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateActions);
        //    model.VetAggregateDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateDiseaseReports);
        //    model.VetDiseaseReportPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryDiseaseReportsData);
        //    model.HumanActiveSurveillanceCampPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanActiveSurveillanceCampaign);
        //    model.HumanActiveSurveillanceSessionPermissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToHumanActiveSurveillanceSession);

        //    return true;
        //}

        #endregion

        public void Dispose()
        {
            DiagService?.Dispose();
            source?.Cancel();
            source?.Dispose();
        }
    }

    

}
