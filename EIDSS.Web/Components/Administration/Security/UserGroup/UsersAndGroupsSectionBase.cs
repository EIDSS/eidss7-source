using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Components;
using Radzen.Blazor;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.Administration.ViewModels.Administration;
using System.Threading;
using EIDSS.Web.Enumerations;
using System.Threading.Tasks;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;
using System.Collections.Generic;
using EIDSS.Web.Components.CrossCutting;
using System;
using Radzen;
using EIDSS.Domain.RequestModels.Administration;
using System.Linq;
using EIDSS.Web.Administration.Security.ViewModels.UserGroup;
using Microsoft.JSInterop;

namespace EIDSS.Web.Components.Administration.Security.UserGroup
{
    public class UsersAndGroupsSectionBase : UsersAndGroupsBaseComponent, IDisposable
    {
        #region Dependency Injection

        [Inject]
        private ILogger<UsersAndGroupsSectionBase> Logger { get; set; }

        [Inject]
        private IUserGroupClient UserGroupClient { get; set; }

        //[Inject]
        //private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependency Injection

        #region Protected and Public Fields

        protected RadzenDataGrid<EmployeesForUserGroupViewModel> _grid;
        //protected RadzenTemplateForm<SearchEmployeeActorViewModel> _form;

        protected bool isLoading;
        protected bool shouldRender = true;

        protected bool showCancelButton;
        protected bool showSearchButton;

        protected bool disableAddButton;
        protected bool disableDeleteButton;

        //protected SearchEmployeeActorViewModel Model;
        //protected UsersAndGroupsSectionViewModel Model;

        protected IEnumerable<EmployeesForUserGroupViewModel> lstUsersAndGroups { get; set; }

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private bool searchSubmitted;
        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion Private Fields and Properties

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        [Parameter]
        public UsersAndGroupsSectionViewModel Model { get; set; }

        #endregion Parameters

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();
            _logger = Logger;

            //reset the cancellation token
            source = new();
            token = source.Token;

            //wire up dialog events
            DiagService.OnClose += DialogClose;

            //initialize model
            InitializeModelAsync();

            //set grid for not loaded
            isLoading = false;

            //set up the accordions
            //showCriteria = true;
            //expandSearchCriteria = true;
            //showSelectedReports = false;
            //showReportData = false;
            //showSummaryData = false;
            //SetButtonStates();

            //await base.OnInitializedAsync();

            //_logger = Logger;
        }

        protected void DialogClose(dynamic result)
        {
            if (result is DialogReturnResult)
            {
                var dialogResult = result as DialogReturnResult;

                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    ResetSearch();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                {
                    //cancel search but user said no
                    source?.Cancel();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoPrint")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoCriteria")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    //showResults = false;
                    //expandSelectedReports = false;
                    //showCriteria = true;
                    //expandSearchCriteria = true;
                    //SetButtonStates();
                }
            }
            else
            {
                //DiagService.Close(result);

                source?.Dispose();
            }

            //SetButtonStates();
        }

        protected void ResetSearch()
        {
            //initialize new model with defaults
            InitializeModelAsync();

            //set grid for not loaded
            //isLoading = false;

            //reset the cancellation token
            source = new();
            token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            //showCriteria = true;
            //expandSearchCriteria = true;
            //expandAdvancedSearchCriteria = false;
            //expandSelectedReports = false;
            //showSelectedReports = false;
            //SetButtonStates();
        }

        public void Dispose()
        {
        }

        protected async Task CancelSearch()
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
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

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
            catch (Exception)
            {
                throw;
            }
        }

        #endregion Lifecycle Methods

        protected async Task OpenAddModal()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchUsersAndGroups>(Localizer.GetString(HeadingResourceKeyConstants.SearchActorsModalHeading),
                    new Dictionary<string, object>() { { "SearchModel", Model.SearchEmployeeActorViewModel } },
                    new DialogOptions() { Width = "1000px", Resizable = true, Draggable = false });

                if (result == null)
                {
                    return;
                }

                if (result is DialogReturnResult)
                {
                    var dialogResult = result as DialogReturnResult;

                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.SelectButton))
                    {
                        IList<EmployeesForUserGroupViewModel> list = new List<EmployeesForUserGroupViewModel>();
                        foreach (var item in lstUsersAndGroups)
                        {
                            list.Add(item);
                        }

                        foreach (var item2 in UserGroupService.SelectedUsersAndGroups)
                        {
                            if (list.Contains(item2) == false)
                                list.Add(item2);
                        }

                        lstUsersAndGroups = list;
                        Model.UsersAndGroupsToSave = list;

                        await JsRuntime.InvokeAsync<string>("SetUsersAndGroupsData", Model);
                        UserGroupService.SetUsersAndGroupsModel(Model);

                        await _grid.Reload();
                    }

                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        //if (SelectedReportsShow == true)
                        //{
                        //    expandSelectedReports = true;
                        //    disableAdminLevelTimeIntervalDropDowns = true;
                        //    showSelectedReports = true;
                        //    model.SearchCriteria.AdministrativeUnitTypeID = adminLevelID;
                        //    model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeID;
                        //    disableSearchButton = false;
                        //}
                        //else
                        //{
                        //    model.SearchCriteria.AdministrativeUnitTypeID = adminLevelID;
                        //    model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeID;
                        //    EnableSearchButton();
                        //    return;
                        //}
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task DeleteEmployees()
        {
            try
            {
                if (UserGroupService.SelectedUsersAndGroupsToDelete != null && UserGroupService.SelectedUsersAndGroupsToDelete.Count > 0)
                {
                    IList<EmployeesForUserGroupViewModel> list = new List<EmployeesForUserGroupViewModel>();
                    IList<EmployeesForUserGroupViewModel> list2 = UserGroupService.SelectedUsersAndGroupsToDelete.OrderBy(s => s.idfEmployee).ToList();

                    foreach (var item in lstUsersAndGroups)
                    {
                        foreach (var item2 in list2)
                        {
                            if (item.idfEmployee != item2.idfEmployee && list.Contains(item) == false && list2.Contains(item) == false)
                                list.Add(item);
                        }
                    }

                    lstUsersAndGroups = list;
                    Model.UsersAndGroupsToSave = list;
                    UserGroupService.SelectedUsersAndGroupsToDelete = null;
                    disableDeleteButton = true;

                    await JsRuntime.InvokeAsync<string>("SetUsersAndGroupsData", Model);
                    UserGroupService.SetUsersAndGroupsModel(Model);

                    await _grid.Reload();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected void OnCheckChange(bool value)
        {
            if (value == true)
                disableDeleteButton = false;
            else
                disableDeleteButton = true;
        }

        #region Private Methods

        private async Task InitializeModelAsync()
        {
            if (Model.UserGroupPermissions.Create)
                disableAddButton = false;
            else
                disableAddButton = true;

            if (Model.UserGroupPermissions.Delete)
            {
                if (UserGroupService.SelectedUsersAndGroupsToDelete != null && UserGroupService.SelectedUsersAndGroupsToDelete.Count > 0)
                    disableDeleteButton = false;
                else
                    disableDeleteButton = true;
            }
            else
                disableDeleteButton = true;

            if (Model.EmployeesForUserGroup.Count > 0)
            {
                isLoading = true;
                lstUsersAndGroups = Model.EmployeesForUserGroup.OrderBy(s => s.idfEmployee).ToList();
                Model.UsersAndGroupsToSave = (IList<EmployeesForUserGroupViewModel>)lstUsersAndGroups;

                await JsRuntime.InvokeAsync<string>("SetUsersAndGroupsData", Model);
                UserGroupService.SetUsersAndGroupsModel(Model);
            }
            else
            {
                lstUsersAndGroups = new List<EmployeesForUserGroupViewModel>();
                isLoading = false;
            }

            //await LoadData();
        }

        protected async Task LoadData()
        {
            if (Model.idfEmployeeGroup != null)
            {
                try
                {
                    isLoading = true;

                    if (Model.EmployeesForUserGroup.Count > 0)
                    {
                        lstUsersAndGroups = Model.EmployeesForUserGroup;
                    }
                    else
                    {
                        var request = new EmployeesForUserGroupGetRequestModel();
                        request.idfEmployeeGroup = Model.idfEmployeeGroup;
                        request.langId = GetCurrentLanguage();

                        //paging
                        //if (args.Skip.HasValue && args.Skip.Value > 0)
                        //{
                        //    request.pageNo = (args.Skip.Value / _grid.PageSize) + 1;
                        //}
                        //else
                        //{
                        //    request.pageNo = 1;
                        //}
                        request.pageNo = 1;
                        request.pageSize = 10;
                        //request.pageSize = _grid.PageSize != 0 ? _grid.PageSize : 10;
                        //sorting
                        //request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : "Name";
                        //request.SortOrder = args.Sorts.FirstOrDefault() != null ? "ASC" : "ASC";
                        request.SortColumn = "Name";
                        request.SortOrder = "ASC";
                        //request.Type = model.SearchCriteria.Type;
                        //request.Name = model.SearchCriteria.Name;
                        //request.Organization = model.SearchCriteria.Organization;
                        //request.Description = model.SearchCriteria.Description;
                        request.idfsSite = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                        //request.user = "Search";

                        var result = await UserGroupClient.GetEmployeesForUserGroupList(request);

                        if (source?.IsCancellationRequested == false)
                        {
                            lstUsersAndGroups = result;
                            //UserGroupService.SearchUsersAndGroups = result;
                            //count = SearchResults.FirstOrDefault() != null ? SearchResults.First().RecordCount.Value : 0;
                        }
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch cancellation or timeout exception
                    if (e.HResult == -2146233088 || source?.IsCancellationRequested == true)
                    {
                        //await ShowNarrowSearchCriteriaDialog();
                    }
                }
                finally
                {
                    isLoading = false;
                    //StateHasChanged();
                }
            }
            else
            {
                //initialize the grid so that it displays 'No records message'
                lstUsersAndGroups = new List<EmployeesForUserGroupViewModel>();
                //count = 0;
                isLoading = false;
            }
        }

        //private void SetButtonStates()
        //{
        //    if (expandSelectedReports)
        //    {
        //        showCancelButton = false;
        //        //showPrintButton = false;
        //        //showCancelSummaryButton = false;
        //        showCancelSelectedReportsButton = true;
        //        showSearchButton = true;
        //        showRemoveAllButton = true;
        //        showSummaryDataButton = true;
        //    }
        //    else if (showSummaryData)
        //    {
        //        //showPrintButton = true;
        //        //showCancelSummaryButton = true;
        //        showCancelButton = false;
        //        //showCancelSelectedReportsButton = false;
        //        showSearchButton = false;
        //        //showRemoveAllButton = false;
        //        //showSummaryDataButton = false;
        //    }
        //    else
        //    {
        //        //showPrintButton = false;
        //        //showCancelSummaryButton = false;
        //        showCancelButton = true;
        //        //showCancelSelectedReportsButton = false;
        //        showSearchButton = true;
        //        //showRemoveAllButton = false;
        //        //showSummaryDataButton = false;
        //    }

        //    //if (!model.Permissions.Delete)
        //    //    disableRemoveButton = true;
        //}

        #endregion Private Methods
    }
}