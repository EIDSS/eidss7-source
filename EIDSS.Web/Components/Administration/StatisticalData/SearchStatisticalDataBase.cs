#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Threading;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.Domain.ResponseModels.Administration;
using System.Linq;
using Microsoft.JSInterop;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Administration.StatisticalData
{
    public class SearchStatisticalDataBase : BaseComponent, IDisposable
    {
        protected IEnumerable<int> pageSizeOptions = new[] { 10, 25, 50, 100 };
        internal ILogger _logger;
        
        #region Properties

        protected RadzenTemplateForm<SearchStatisticalDataViewModel> _form;
        protected RadzenDataGrid<StatisticalDataResponseModel> _grid;
        protected RadzenDropDown<long?> _StatisticalDataTypeDD;        
        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool showSearchResults;
        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool showSearchCriteriaButtons;
        protected bool displayCancel;
        public int StatisticalDataResultsCount { get; set; }

        #endregion

        #region Parameters

        [Parameter] public SearchStatisticalDataViewModel model { get; set; }
        [Parameter] public long? idfStatistic { get; set; }
        [Parameter] public string UserName { get; set; }

        #endregion

        #region Variables

        protected IEnumerable<BaseReferenceTypeListViewModel> statisticalDataTypesList { get; set; }
        protected int statisticalDataTypesListCount { get; set; }
        protected bool isLoading;

        #endregion 

        #region Dependencies

        [Parameter] public UserPermissions userPermissions { get; set; }
        [Inject] private ILogger<SearchStatisticalDataBase> Logger { get; set; }
        [Inject] private IAdminClient AdministrationClient { get; set; }
        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] protected IStatisticalDataClient StatisticalDataClient { get; set; }
        [Inject] private ISiteClient SiteClient { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] protected Radzen.DialogService _dialogService { get; set; }
        
        #endregion

        #region Lifecycle Events

        /// <summary>
        /// 
        /// </summary>
        protected override void OnInitialized()
        {
            _dialogService.OnOpen += Open;
            userPermissions = GetUserPermissions(PagePermission.AccessToStatisticsList);

            _logger = Logger;
            source = new();
            token = source.Token;

            LoadLocationControls();

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            UserName = authenticatedUser.UserName;

            //Default Date Settings
            model.FromDate = new DateTime(DateTime.Now.Year - 1, 01, 01);
            model.ToDate = DateTime.Now;
            expandSearchCriteria = true;
            showSearchResults = false;
            displayCancel = false;

            base.OnInitialized();
        }

        void Open(string title, Type type, Dictionary<string, object> parameters, DialogOptions options)
        {

        }

        public async void ResetFields()
        {
            model.FromDate = new DateTime(DateTime.Now.Year - 1, 01, 01);
            model.ToDate = DateTime.Now;
            _StatisticalDataTypeDD.Reset();

            if (model.StatisticalDataResults != null)
            {
                model.StatisticalDataResults.Clear();
                _grid.Reload();
            }

            await RefreshLocationViewModelHandlerAsync(model.LocationViewModel);

            //expandSearchCriteria = false;
            showSearchResults = false;
            displayCancel = false;
            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {

        }

        #endregion

        #region MyRegion

        protected async Task GetStatisticalDataItems(LoadDataArgs args)
        {
            isLoading = true;
            try
            {
                List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                request.ReferenceTypeIds = "19000090";
                request.MaxPagesPerFetch = 10;
                request.PageSize = 100;
                request.LanguageId = GetCurrentLanguage();
                request.PaginationSet = 1;
                request.Term = "Population";

                //paging
                //if (args.Skip.HasValue && args.Skip.Value > 0)
                //{
                //    request.PaginationSet = (args.Skip.Value / _StatisticalDataTypeDD.PageSize) + 1;
                //}
                //else
                //{
                //    request.PaginationSet = 1;
                //}
                //request.PageSize = _StatisticalDataTypeDD.PageSize != 0 ? _StatisticalDataTypeDD.PageSize : 100;

                list = await CrossCuttingClient.GetReferenceTypesByIdPaged(request);
                statisticalDataTypesList = list;
                statisticalDataTypesListCount = list.Count;

                if (!IsNullOrEmpty(args.Filter))
                {
                    statisticalDataTypesList = statisticalDataTypesList.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));
                }

                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                isLoading = false;
                _logger.LogError(ex.Message);
                throw;
            }

        }
        public void SetStatisticalData(object data)
        {
            try
            {
                if (data != null)
                {
                    model.selectedStatisticalDataItem = (long)data;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }
        protected async void HandleValidSearchSubmit(SearchStatisticalDataViewModel _model)
        {
            expandSearchCriteria = true;
            showSearchResults = true;
            displayCancel = true;
            try
            {
                if (_form.IsValid)
                {
                    StatisticalDataRequestModel request = new StatisticalDataRequestModel();
                    request.LangID = GetCurrentLanguage();
                    request.datStatisticStartDateFrom = _model.FromDate.Value;
                    request.datStatisticStartDateTo = _model.ToDate.Value;
                    if (_model.selectedStatisticalDataItem != 0 && _model.selectedStatisticalDataItem != null)
                    {
                        request.idfsStatisticalDataType = _model.selectedStatisticalDataItem;
                    }
                    if (_model.LocationViewModel.AdminLevel6Value != null)
                    {
                        request.idfsArea = _model.LocationViewModel.AdminLevel6Value;
                    }
                    else if (_model.LocationViewModel.AdminLevel5Value != null)
                    {
                        request.idfsArea = _model.LocationViewModel.AdminLevel5Value;
                    }
                    else if (_model.LocationViewModel.AdminLevel4Value != null)
                    {
                        request.idfsArea = _model.LocationViewModel.AdminLevel4Value;
                    }
                    else if (_model.LocationViewModel.AdminLevel3Value != null)
                    {
                        request.idfsArea = _model.LocationViewModel.AdminLevel3Value;
                    }
                    else if (_model.LocationViewModel.AdminLevel2Value != null)
                    {
                        request.idfsArea = _model.LocationViewModel.AdminLevel2Value;
                    }
                    else if (_model.LocationViewModel.AdminLevel1Value != null)
                    {
                        request.idfsArea = _model.LocationViewModel.AdminLevel1Value;
                    }
                    //else if (_model.LocationViewModel.AdminLevel0Value != null)
                    //{
                    //    request.idfsArea = _model.LocationViewModel.AdminLevel0Value;
                    //}

                    request.pageSize = 10;
                    request.pageNo = 1;
                    // sorting


                    List<StatisticalDataResponseModel> response = new List<StatisticalDataResponseModel>();
                    response = await StatisticalDataClient.GetStatisticalData(request);

                    if (response.Count > 0)
                    {
                        model.StatisticalDataResults = response;
                        StatisticalDataResultsCount = response[0].TotalRowCount.Value;
                    }
                    else
                    {
                        model.StatisticalDataResults = new List<StatisticalDataResponseModel>();
                        StatisticalDataResultsCount = 0;
                    }

                    showSearchResults = true;
                    await InvokeAsync(StateHasChanged);

                    if (_form.EditContext.IsModified())
                    {
                        // searchSubmitted = true;

                        //SetButtonStates();

                        //if (_grid != null)
                        //{
                        //    await _grid.Reload();
                        //}
                    }
                    else
                    {
                        //no search criteria entered - display the EIDSS dialog component
                        // searchSubmitted = false;
                        //await ShowNoSearchCriteriaDialog();
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }
        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
        }

        protected async void LoadStatisticalDataGrid(LoadDataArgs args)
        {
            showSearchResults = true;
            isLoading = true;
            try
            {
                if (_form.IsValid)
                {
                    if (_form.Data.FromDate != null && _form.Data.ToDate != null)
                    {
                        StatisticalDataRequestModel request = new StatisticalDataRequestModel();
                        request.datStatisticStartDateFrom = model.FromDate.Value;
                        request.datStatisticStartDateTo = model.ToDate.Value;
                        request.LangID = GetCurrentLanguage();
                        if (model.selectedStatisticalDataItem != 0 && model.selectedStatisticalDataItem != null)
                        {
                            request.idfsStatisticalDataType = model.selectedStatisticalDataItem;
                        }
                        if (model.LocationViewModel.AdminLevel6Value != null)
                        {
                            request.idfsArea = model.LocationViewModel.AdminLevel6Value;
                        }
                        else if (model.LocationViewModel.AdminLevel5Value != null)
                        {
                            request.idfsArea = model.LocationViewModel.AdminLevel5Value;
                        }
                        else if (model.LocationViewModel.AdminLevel4Value != null)
                        {
                            request.idfsArea = model.LocationViewModel.AdminLevel4Value;
                        }
                        else if (model.LocationViewModel.AdminLevel3Value != null)
                        {
                            request.idfsArea = model.LocationViewModel.AdminLevel3Value;
                        }
                        else if (model.LocationViewModel.AdminLevel2Value != null)
                        {
                            request.idfsArea = model.LocationViewModel.AdminLevel2Value;
                        }
                        else if (model.LocationViewModel.AdminLevel1Value != null)
                        {
                            request.idfsArea = model.LocationViewModel.AdminLevel1Value;
                        }
                        //else if (model.LocationViewModel.AdminLevel0Value != null)
                        //{
                        //    request.idfsArea = model.LocationViewModel.AdminLevel0Value;
                        //}

                        if (args.Sorts.FirstOrDefault() != null)
                        {
                            request.sortColumn = args.Sorts.FirstOrDefault().Property;
                            request.sortOrder = args.Sorts.FirstOrDefault().SortOrder.Value.ToString().ToLower();

                        }

                        List<StatisticalDataResponseModel> response = new List<StatisticalDataResponseModel>();

                        //paging
                        if (args.Skip.HasValue && args.Skip.Value > 0)
                        {
                            request.pageNo = (args.Skip.Value / _grid.PageSize) + 1;
                        }
                        else
                        {
                            request.pageNo = 1;
                        }

                        request.pageSize = _grid.PageSize != 0 ? _grid.PageSize : 10;

                        //database call
                        response = await StatisticalDataClient.GetStatisticalData(request);

                        if (response.Count > 0)
                        {
                            StatisticalDataResultsCount = response[0].TotalRowCount.Value;
                            model.StatisticalDataResults = response;
                        }
                        else
                        {
                            StatisticalDataResultsCount = 0;
                            model.StatisticalDataResults = new List<StatisticalDataResponseModel>();
                        }

                        // StateHasChanged();
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }

        }
        protected void CancelEdit(StatisticalDataResponseModel item)
        {
            //if (item == testToInsert)
            //{
            //    testToInsert = null;
            //}

            _grid.CancelEditRow(item);
        }

        public async Task EditRow(StatisticalDataResponseModel item)
        {
            await RedirectToRecord(item.idfStatistic);
        }

        protected async Task RedirectToRecord(long id)
        {
            var uri = $"{NavManager.BaseUri}Administration/StatisticalData/Add/" + id.ToString();
            NavManager.NavigateTo(uri, true);
            await JsRuntime.InvokeAsync<string>("showPermissionsWarning");
        }

        public async Task ConfirmDeleteRow(StatisticalDataResponseModel item)
        {
            if (userPermissions.Delete != false)
            {
                await JsRuntime.InvokeAsync<string>("deleteRecord");
                idfStatistic = item.idfStatistic;
            }
            else
            {
                await JsRuntime.InvokeAsync<string>("showPermissionsWarning");
            }
        }

        public async void DeleteRecord(long id)
        {
            try
            {
                USP_ADMIN_STAT_DELResultRequestModel request = new USP_ADMIN_STAT_DELResultRequestModel();
                List<USP_ADMIN_STAT_DELResultResponseModel> response = new List<USP_ADMIN_STAT_DELResultResponseModel>();
                
                request.idfStatistic = id;
                request.UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
                request.SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                response = await StatisticalDataClient.DeleteStatisticalData(request);

                if (response.Count > 0)
                {
                    if (response[0].returnMessage == "SUCCESS")
                    {
                        await JsRuntime.InvokeAsync<string>("cancelDeleteRecord");
                        _grid.Reload();
                        isLoading = false;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                isLoading = false;
                throw;
            }
        }

        public void OnUpdateRow(StatisticalDataResponseModel item)
        {
            //if (order == orderToInsert)
            //{
            //    orderToInsert = null;
            //}

            //dbContext.Update(order);

            //// For demo purposes only
            //order.Customer = dbContext.Customers.Find(order.CustomerID);
            //order.Employee = dbContext.Employees.Find(order.EmployeeID);

            //// For production
            ////dbContext.SaveChanges();
        }
        
        public void OnCreateRow(StatisticalDataResponseModel item)
        {
            //dbContext.Add(order);

            //// For demo purposes only
            //order.Customer = dbContext.Customers.Find(order.CustomerID);
            //order.Employee = dbContext.Employees.Find(order.EmployeeID);

            //// For production
            ////dbContext.SaveChanges();
        }
        
        public void SelectRow(StatisticalDataResponseModel item)
        {

        }
        
        public void ChangeLocationSettings(Object value)
        {
            try
            {
                model.LocationViewModel = (LocationViewModel)value;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            try
            {
                model.LocationViewModel = locationViewModel;
                model.LocationViewModel.AdminLevel1Value = null;
                model.LocationViewModel.AdminLevel2Value = null;
                model.LocationViewModel.AdminLevel3Value = null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task LoadLocationControls()
        {
            try
            {
                var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId), Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId));
                LocationViewModel locationViewModel = new LocationViewModel();
                if (model.LocationViewModel != null)
                {
                    locationViewModel = model.LocationViewModel;
                }
                locationViewModel.AdminLevel0Value = siteDetails.CountryID;
                locationViewModel.AdminLevel0LevelType = 10036005;
                locationViewModel.DivAdminLevel0 = false;
                locationViewModel.ShowSettlement = true;
                locationViewModel.ShowSettlementType = false;
                locationViewModel.EnableAdminLevel1 = true;
                locationViewModel.EnableAdminLevel2 = true;
                locationViewModel.EnableAdminLevel3 = true;
                locationViewModel.ShowAdminLevel0 = false;//Country
                locationViewModel.ShowAdminLevel1 = true;//Region
                locationViewModel.ShowAdminLevel2 = true;//Rayon
                locationViewModel.ShowAdminLevel3 = true;//Settlement
                locationViewModel.ShowAdminLevel4 = false;
                locationViewModel.ShowAdminLevel5 = false;
                locationViewModel.ShowAdminLevel6 = false;
                locationViewModel.IsDbRequiredAdminLevel1 = false;
                locationViewModel.IsDbRequiredAdminLevel2 = false;
                locationViewModel.IsDbRequiredAdminLevel3 = false;
                locationViewModel.EnableStreet = false;
                locationViewModel.EnablePostalCode = false;
                locationViewModel.ShowPostalCode = false;
                locationViewModel.ShowStreet = false;
                locationViewModel.ShowApartment = false;
                locationViewModel.ShowBuilding = false;
                locationViewModel.ShowHouse = false;
                locationViewModel.ShowBuildingHouseApartmentGroup = false;
                locationViewModel.ShowLatitude = false;
                locationViewModel.ShowLongitude = false;
                locationViewModel.ShowElevation = false;
                locationViewModel.ShowCoordinates = false;
                locationViewModel.ShowMap = false;

                model.LocationViewModel = locationViewModel;
                // StateHasChanged();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }
        protected async Task RedirectToDashBoard()
        {
            var uri = $"{NavManager.BaseUri}Administration/Dashboard";
            NavManager.NavigateTo(uri, true);
        }

        protected async Task RedirectToAdd()
        {
            var uri = $"{NavManager.BaseUri}Administration/StatisticalData/Add";
            NavManager.NavigateTo(uri, true);
        }

        private async Task SetButtonStates()
        {
            if (expandSearchCriteria || expandAdvancedSearchCriteria)
            {
                showSearchCriteriaButtons = true;
            }
            else
            {
                showSearchCriteriaButtons = false;
            }

            await InvokeAsync(StateHasChanged);
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
                    showSearchResults = !showSearchResults;
                    break;

                default:
                    break;
            }
            SetButtonStates();
        }


        #endregion
    }
}
