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
using System.Globalization;
using Microsoft.JSInterop;
using Microsoft.AspNetCore.WebUtilities;
using EIDSS.Domain.ViewModels;
using System.Text;
using EIDSS.Web.Components.Shared;

#endregion

namespace EIDSS.Web.Components.Administration.StatisticalData
{
    public class AddStatisticalDataBase : BaseComponent, IDisposable
    {
        internal ILogger _logger;

        #region properties
        protected RadzenTemplateForm<AddStatisticalDataViewModel> _form;
        protected RadzenDropDown<long?> _StatisticalDataTypeDD;
        protected RadzenDropDown<long?> _ParameterDD;
        protected RadzenDropDown<long?> _AgeGroupDD;
        [Parameter]
        public AddStatisticalDataViewModel model { get; set; }
        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool showAgeGroups;
        protected bool isHumanGenderSelected;
        protected long IdfsStatisticPeriodType;
        protected bool IsDuplicate;
        public int StatisticalDataResultsCount { get; set; }
        [Parameter]
        public string ModalHeading { get; set; }
        [Parameter]
        public string SuccessMsg { get; set; }
        
        public int parametersCount { get; set; }
        public int ageGroupsCount { get; set; }

        protected LocationView LocationComponent { get; set; }

        #endregion

        #region Variables
        protected IEnumerable<BaseReferenceTypeListViewModel> statisticalDataTypesList { get; set; }
        protected IEnumerable<BaseReferenceTypeListViewModel> parametersList { get; set; }
        protected IEnumerable<BaseReferenceTypeListViewModel> agegroupsList { get; set; }
        protected int statisticalDataTypesListCount { get; set; }
        
        [Parameter]
        public UserPermissions userPermissions { get; set; }
        #endregion 

        #region Dependencies

        [Inject]
        private ILogger<SearchStatisticalDataBase> Logger { get; set; }
        [Inject]
        private IAdminClient AdministrationClient { get; set; }
        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected IStatisticalDataClient StatisticalDataClient { get; set; }
        [Inject]
        private IJSRuntime JsRuntime { get; set; }
        [Inject]
        protected IStatisticalTypeClient StatisticalTypeClient { get; set; }
        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        protected IInterfaceEditorClient  interfaceEditorClient { get; set; }
        #endregion

        #region Lifecycle Events

        /// <summary>
        /// 
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            userPermissions = GetUserPermissions(PagePermission.AccessToStatisticsList);
            _logger = Logger;
            source = new();
            token = source.Token;
            await LoadLocationControls();
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            //Default Date Settings
            showAgeGroups = false;
            isHumanGenderSelected = false;

            var uri = NavManager.ToAbsoluteUri(NavManager.Uri);

            //EXISTING AGGREGATE COLLECTION
            if (model.idfStatistic != null)
            { 
                await GetExistingRecord(model.idfStatistic.Value);
            }
            
            await LocationComponent.RefreshComponent(model.LocationViewModel);
        
            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
            }
        }

        public async Task GetExistingRecord(long id)
        {
            try
            {
                List<USP_ADMIN_STAT_GetDetailResultResponseModel> results = new List<USP_ADMIN_STAT_GetDetailResultResponseModel>(); 
               USP_ADMIN_STAT_GetDetailResultRequestModel request = new USP_ADMIN_STAT_GetDetailResultRequestModel();
                request.idfStatistic = id;
                request.LangID = GetCurrentLanguage();
                results = await StatisticalDataClient.GetStatisticalDataDetails(request);
                if (results.Count > 0)
                {
                    model.idfStatistic = results[0].idfStatistic;
                    model.ToDate = DateTime.Parse(results[0].datStatisticStartDate);

                    model.selectedStatisticalDataItem = results[0].idfsStatisticDataType;
                    model.selectedAreaType = results[0].idfsStatisticAreaType;
                    model.selectedAgeGroup = results[0].idfsStatisticalAgeGroup;

                    // public string results[0].defDataTypeName 
                    //model.varValue = results[0].varValue;
                    //model.i = results[0].idfsMainBASeReference 
                    model.selectedPeriodType = results[0].idfsStatisticPeriodType;
                    CompareSelectedPeriodType(results[0].idfsStatisticPeriodType.Value);
                    //model.results[0].idfsArea 
                    model.FromDate = DateTime.Parse(results[0].datStatisticStartDate);
                    //public string results[0].setnDataTypeName 
                    model.ParameterType = results[0].ParameterType;
                   // = results[0].idfsParameterType;
                    //public string results[0].defParameterName 
                    //public string results[0].setnParameterName 
                    //public long? results[0].idfsParameterName 
                    model.StatisticalAreaType = results[0].defAreaTypeName;
                    //public string results[0].setnAreaTypeName 
                   
                    @model.StatisticalPeriodType = results[0].setnPeriodTypeName;
                    model.varValue = long.Parse(results[0].varValue.ToString());

                    if (results[0].idfsStatisticalAgeGroup != null)
                    {
                        showAgeGroups = true;
                    }
                    else
                    {
                        showAgeGroups = false;
                    }
                    if (results[0].idfsMainBASeReference!= null)
                    {
                        model.selectedParameter = results[0].idfsMainBASeReference;
                        isHumanGenderSelected = true;
                    }
                    else
                    {
                        isHumanGenderSelected = false;
                    }

                    model.LocationViewModel.AdminLevel0Text = results[0].AdminLevel0Text;
                    model.LocationViewModel.AdminLevel0Value = results[0].AdminLevel0Value;

                    model.LocationViewModel.AdminLevel1Text = results[0].AdminLevel1Text;
                    model.LocationViewModel.AdminLevel1Value = results[0].AdminLevel1Value;
                    model.LocationViewModel.AdminLevel2Text = results[0].AdminLevel2Text;
                    model.LocationViewModel.AdminLevel2Value = results[0].AdminLevel2Value;
                    model.LocationViewModel.AdminLevel3Text = results[0].AdminLevel3Text;
                    model.LocationViewModel.AdminLevel3Value = results[0].AdminLevel3Value;
                    model.LocationViewModel.AdminLevel4Text = results[0].AdminLevel4Text;
                    model.LocationViewModel.AdminLevel4Value = results[0].AdminLevel4Value;
                    model.LocationViewModel.AdminLevel5Text = results[0].AdminLevel5Text;
                    model.LocationViewModel.AdminLevel5Value = results[0].AdminLevel5Value;
                    model.LocationViewModel.AdminLevel6Text = results[0].AdminLevel6Text;
                    model.LocationViewModel.AdminLevel6Value = results[0].AdminLevel6Value;

                    model.LocationViewModel.IsDbRequiredAdminLevel2 = false;
                    model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                    //public long? results[0].idfsCountry 
                    //public long? results[0].idfsRegion 
                    //public long? results[0].idfsRayon 
                    //public long? results[0].idfsSettlement 
                    //setnArea 

                    if (results[0].idfsStatisticAreaType == 10089001) // Country
                    {
                        model.LocationViewModel.DivSettlementType = true;

                        model.LocationViewModel.EnableSettlement = false;
                        model.LocationViewModel.EnableSettlementType = false;
                        model.LocationViewModel.ShowAdminLevel1 = false;
                        model.LocationViewModel.ShowAdminLevel2 = false;
                        model.LocationViewModel.ShowAdminLevel3 = false;
                        model.LocationViewModel.ShowAdminLevel4 = false;
                        model.LocationViewModel.ShowAdminLevel5 = false;
                        model.LocationViewModel.ShowAdminLevel6 = false;
                        model.LocationViewModel.ShowSettlement = false;
                        model.LocationViewModel.ShowSettlementType = false;
                        model.LocationViewModel.EnableAdminLevel1 = false;
                        model.LocationViewModel.EnableAdminLevel2 = false;
                        model.LocationViewModel.EnableAdminLevel3 = false;
                        model.LocationViewModel.EnableAdminLevel4 = false;
                        model.LocationViewModel.EnableAdminLevel5 = false;
                        model.LocationViewModel.EnableAdminLevel6 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel1 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel2 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                    }
                    else if (results[0].idfsStatisticAreaType == 10089003) //Region 
                    {
                        model.LocationViewModel.DivSettlementType = true;

                        model.LocationViewModel.EnableSettlement = false;
                        model.LocationViewModel.EnableSettlementType = false;
                        model.LocationViewModel.ShowAdminLevel1 = true;
                        model.LocationViewModel.ShowAdminLevel2 = false;
                        model.LocationViewModel.ShowAdminLevel3 = false;
                        model.LocationViewModel.ShowAdminLevel4 = false;
                        model.LocationViewModel.ShowAdminLevel5 = false;
                        model.LocationViewModel.ShowAdminLevel6 = false;
                        model.LocationViewModel.ShowSettlement = false;
                        model.LocationViewModel.ShowSettlementType = false;
                        model.LocationViewModel.EnableAdminLevel1 = true;
                        model.LocationViewModel.EnableAdminLevel2 = false;
                        model.LocationViewModel.EnableAdminLevel3 = false;
                        model.LocationViewModel.EnableAdminLevel4 = false;
                        model.LocationViewModel.EnableAdminLevel5 = false;
                        model.LocationViewModel.EnableAdminLevel6 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel1 = true;
                        model.LocationViewModel.IsDbRequiredAdminLevel2 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                    }
                    else if (results[0].idfsStatisticAreaType == 10089002) // Rayon
                    {
                        model.LocationViewModel.DivSettlementType = true;

                        model.LocationViewModel.EnableSettlement = false;
                        model.LocationViewModel.EnableSettlementType = false;
                        model.LocationViewModel.ShowAdminLevel1 = true;
                        model.LocationViewModel.ShowAdminLevel2 = true;
                        model.LocationViewModel.ShowAdminLevel3 = false;
                        model.LocationViewModel.ShowAdminLevel4 = false;
                        model.LocationViewModel.ShowAdminLevel5 = false;
                        model.LocationViewModel.ShowAdminLevel6 = false;
                        model.LocationViewModel.ShowSettlement = false;
                        model.LocationViewModel.ShowSettlementType = false;
                        model.LocationViewModel.EnableAdminLevel1 = true;
                        model.LocationViewModel.EnableAdminLevel2 = true;
                        model.LocationViewModel.EnableAdminLevel3 = false;
                        model.LocationViewModel.EnableAdminLevel4 = false;
                        model.LocationViewModel.EnableAdminLevel5 = false;
                        model.LocationViewModel.EnableAdminLevel6 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel1 = true;
                        model.LocationViewModel.IsDbRequiredAdminLevel2 = true;
                        model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                    }
                    else if (results[0].idfsStatisticAreaType == 10089004) // Settlement
                    {
                        model.LocationViewModel.DivSettlementType = true;

                        model.LocationViewModel.EnableSettlement = true;
                        model.LocationViewModel.EnableSettlementType = true;
                        model.LocationViewModel.ShowAdminLevel1 = true;
                        model.LocationViewModel.ShowAdminLevel2 = true;
                        model.LocationViewModel.ShowAdminLevel3 = true;
                        model.LocationViewModel.ShowAdminLevel4 = false;
                        model.LocationViewModel.ShowAdminLevel5 = false;
                        model.LocationViewModel.ShowAdminLevel6 = false;
                        model.LocationViewModel.ShowSettlement = true;
                        model.LocationViewModel.ShowSettlementType = true;
                        model.LocationViewModel.EnableAdminLevel1 = true;
                        model.LocationViewModel.EnableAdminLevel2 = true;
                        model.LocationViewModel.EnableAdminLevel3 = true;
                        model.LocationViewModel.EnableAdminLevel4 = false;
                        model.LocationViewModel.EnableAdminLevel5 = false;
                        model.LocationViewModel.EnableAdminLevel6 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel1 = true;
                        model.LocationViewModel.IsDbRequiredAdminLevel2 = true;
                        model.LocationViewModel.IsDbRequiredAdminLevel3 = true;
                        model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                        model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
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
            try
            {
                List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                request.ReferenceTypeIds = "19000090";
                request.MaxPagesPerFetch = 10;
                request.PageSize = 100;
                request.LanguageId = GetCurrentLanguage();
                request.PaginationSet = 1;
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
                statisticalDataTypesListCount = list.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

       protected async Task GetParameterItems(LoadDataArgs args)
        {
            try
            {
                List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                request.ReferenceTypeIds = "19000043";
                request.MaxPagesPerFetch = 10;
                request.PageSize = 100;
                request.LanguageId = GetCurrentLanguage();
                request.PaginationSet = 1;
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
                parametersList = list;
                parametersCount = list.Count;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }
        protected async Task GetAgeGroups(LoadDataArgs args)
        {
            try
            {
                List<BaseReferenceTypeListViewModel> list = new List<BaseReferenceTypeListViewModel>();
                ReferenceTypeByIdRequestModel request = new ReferenceTypeByIdRequestModel();
                request.ReferenceTypeIds = "19000145";
                request.MaxPagesPerFetch = 10;
                request.PageSize = 100;
                request.LanguageId = GetCurrentLanguage();
                request.PaginationSet = 1;
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
                agegroupsList = list;
                ageGroupsCount = list.Count;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        public async void SetStatisticalData(object data)
        {

            try
            {

                if (data != null)
                {
                    model.selectedStatisticalDataItem = (long)data;


                    var request = new StatisticalTypeGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SortColumn = "strName",
                        SortOrder = "asc", 
                        idfsStatisticDataType = model.selectedStatisticalDataItem
                    };

                    List<BaseReferenceEditorsViewModel> stlvm = await StatisticalTypeClient.GetStatisticalTypeList(request);
                    IEnumerable<BaseReferenceEditorsViewModel> StatisticalTypeList = stlvm;
                    if (stlvm.Count > 0)
                    {
                        model.StatisticalPeriodType = stlvm[0].StrStatisticPeriodType;
                        model.ParameterType = stlvm[0].StrParameterType;
                        model.StatisticalAreaType = stlvm[0].StrStatisticalAreaType;
                        model.selectedAreaType = stlvm[0].IdfsStatisticAreaType;
                        if (stlvm[0].blnStatisticalAgeGroup != null)
                        {
                            showAgeGroups = stlvm[0].blnStatisticalAgeGroup;
                            //Show hide location controls based on settlementType
                            if (stlvm[0].IdfsStatisticAreaType == 10089001 ) // Country
                            {
                                model.LocationViewModel.DivSettlementType = true;
                               
                                model.LocationViewModel.EnableSettlement = false;
                                model.LocationViewModel.EnableSettlementType = false;
                                model.LocationViewModel.ShowAdminLevel1 = false;
                                model.LocationViewModel.ShowAdminLevel2 = false;
                                model.LocationViewModel.ShowAdminLevel3 = false;
                                model.LocationViewModel.ShowAdminLevel4 = false;
                                model.LocationViewModel.ShowAdminLevel5 = false;
                                model.LocationViewModel.ShowAdminLevel6 = false;
                                model.LocationViewModel.ShowSettlement = false;
                                model.LocationViewModel.ShowSettlementType = false;
                                model.LocationViewModel.EnableAdminLevel1 = false;
                                model.LocationViewModel.EnableAdminLevel2 = false;
                                model.LocationViewModel.EnableAdminLevel3 = false;
                                model.LocationViewModel.EnableAdminLevel4 = false;
                                model.LocationViewModel.EnableAdminLevel5 = false;
                                model.LocationViewModel.EnableAdminLevel6= false;
                                model.LocationViewModel.IsDbRequiredAdminLevel1 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel2 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                            }
                            else if (stlvm[0].IdfsStatisticAreaType == 10089003) //Region 
                            {
                                model.LocationViewModel.DivSettlementType = true;

                                model.LocationViewModel.EnableSettlement = false;
                                model.LocationViewModel.EnableSettlementType = false;
                                model.LocationViewModel.ShowAdminLevel1 = true;
                                model.LocationViewModel.ShowAdminLevel2 = false;
                                model.LocationViewModel.ShowAdminLevel3 = false;
                                model.LocationViewModel.ShowAdminLevel4 = false;
                                model.LocationViewModel.ShowAdminLevel5 = false;
                                model.LocationViewModel.ShowAdminLevel6 = false;
                                model.LocationViewModel.ShowSettlement = false;
                                model.LocationViewModel.ShowSettlementType = false;
                                model.LocationViewModel.EnableAdminLevel1 = true;
                                model.LocationViewModel.EnableAdminLevel2 = false;
                                model.LocationViewModel.EnableAdminLevel3 = false;
                                model.LocationViewModel.EnableAdminLevel4 = false;
                                model.LocationViewModel.EnableAdminLevel5 = false;
                                model.LocationViewModel.EnableAdminLevel6 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel1 = true;
                                model.LocationViewModel.IsDbRequiredAdminLevel2 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                            }
                            else if (stlvm[0].IdfsStatisticAreaType == 10089002) // Rayon
                            {
                                model.LocationViewModel.DivSettlementType = true;

                                model.LocationViewModel.EnableSettlement = false;
                                model.LocationViewModel.EnableSettlementType = false;
                                model.LocationViewModel.ShowAdminLevel1 = true;
                                model.LocationViewModel.ShowAdminLevel2 = true;
                                model.LocationViewModel.ShowAdminLevel3 = false;
                                model.LocationViewModel.ShowAdminLevel4 = false;
                                model.LocationViewModel.ShowAdminLevel5 = false;
                                model.LocationViewModel.ShowAdminLevel6 = false;
                                model.LocationViewModel.ShowSettlement = false;
                                model.LocationViewModel.ShowSettlementType = false;
                                model.LocationViewModel.EnableAdminLevel1 = true;
                                model.LocationViewModel.EnableAdminLevel2 = true;
                                model.LocationViewModel.EnableAdminLevel3 = false;
                                model.LocationViewModel.EnableAdminLevel4 = false;
                                model.LocationViewModel.EnableAdminLevel5 = false;
                                model.LocationViewModel.EnableAdminLevel6 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel1 = true;
                                model.LocationViewModel.IsDbRequiredAdminLevel2 = true;
                                model.LocationViewModel.IsDbRequiredAdminLevel3 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                            }
                            else if (stlvm[0].IdfsStatisticAreaType == 10089004) // Settlement
                            {
                                model.LocationViewModel.DivSettlementType = true;

                                model.LocationViewModel.EnableSettlement = true;
                                model.LocationViewModel.EnableSettlementType = true;
                                model.LocationViewModel.ShowAdminLevel1 = true;
                                model.LocationViewModel.ShowAdminLevel2 = true;
                                model.LocationViewModel.ShowAdminLevel3 = true;
                                model.LocationViewModel.ShowAdminLevel4 = false;
                                model.LocationViewModel.ShowAdminLevel5 = false;
                                model.LocationViewModel.ShowAdminLevel6 = false;
                                model.LocationViewModel.ShowSettlement = true;
                                model.LocationViewModel.ShowSettlementType = true;
                                model.LocationViewModel.EnableAdminLevel1 = true;
                                model.LocationViewModel.EnableAdminLevel2 = true;
                                model.LocationViewModel.EnableAdminLevel3 = true;
                                model.LocationViewModel.EnableAdminLevel4 = false;
                                model.LocationViewModel.EnableAdminLevel5 = false;
                                model.LocationViewModel.EnableAdminLevel6 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel1 = true;
                                model.LocationViewModel.IsDbRequiredAdminLevel2 = true;
                                model.LocationViewModel.IsDbRequiredAdminLevel3 = true;
                                model.LocationViewModel.IsDbRequiredAdminLevel4 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel5 = false;
                                model.LocationViewModel.IsDbRequiredAdminLevel6 = false;
                            }
                            //else
                            //{
                            //    model.LocationViewModel.EnableSettlement = true;
                            //    model.LocationViewModel.EnableSettlementType = true;
                            //    model.LocationViewModel.DivSettlementType = true;
                            //    model.LocationViewModel.ShowSettlementType = true;
                            //    model.LocationViewModel.EnableAdminLevel3 = true;
                            //    model.LocationViewModel.EnableAdminLevel4 = true;
                            //    model.LocationViewModel.EnableAdminLevel5 = true;
                            //    model.LocationViewModel.EnableAdminLevel6 = true;
                            //    model.LocationViewModel.IsDbRequiredAdminLevel3 = true;


                            //}
                        }
                        
                        else
                        {
                            showAgeGroups = false;
                        }
                        if (stlvm[0].IdfsReferenceType == 19000043)
                        {
                            isHumanGenderSelected = true;
                        }
                        else
                        {
                            isHumanGenderSelected = false;
                        }
                        IdfsStatisticPeriodType = stlvm[0].IdfsStatisticPeriodType;
                        model.selectedPeriodType = IdfsStatisticPeriodType;
                        /*Set Start Date
                         10091001	19000091	sptMonth	Month
                        10091002	19000091	sptOnday	Day
                        10091003	19000091	sptQuarter	Quarter
                        10091004	19000091	sptWeek	Week
                        10091005	19000091	sptYear	Year
                        */
                        if (model.FromDate != null)
                        {
                            
                          await  CompareSelectedPeriodType(stlvm[0].IdfsStatisticPeriodType);
                        }

                       
                    }

                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }
        //Format Date Based on Statistical Period Type
        public async Task CompareSelectedPeriodType(long periodType)
        {
            /*Set Start Date
            10091001	19000091	sptMonth	Month
            10091002	19000091	sptOnday	Day
            10091003	19000091	sptQuarter	Quarter
            10091004	19000091	sptWeek	Week
            10091005	19000091	sptYear	Year
            */
            try
            {
                if (model.FromDate != null)
                {
                    if (periodType == 10091005)
                    {
                        model.FromDate = new DateTime(model.FromDate.Value.Year, 1, 1);
                        model.ToDate = new DateTime(model.FromDate.Value.Year, 12, 31);
                    }
                    if (periodType == 10091003)
                    {
                        if (model.FromDate.Value.Month <= 3)
                        {
                            model.FromDate = new DateTime(model.FromDate.Value.Year, 1, 1);
                            model.ToDate = new DateTime(model.FromDate.Value.Year, 3, 31);
                        }
                        if (model.FromDate.Value.Month > 3 && model.FromDate.Value.Month <= 6)
                        {
                            model.FromDate = new DateTime(model.FromDate.Value.Year, 4, 1);
                            model.ToDate = new DateTime(model.FromDate.Value.Year, 6, 30);
                        }
                        if (model.FromDate.Value.Month > 6 && model.FromDate.Value.Month <= 9)
                        {
                            model.FromDate = new DateTime(model.FromDate.Value.Year, 7, 1);
                            model.ToDate = new DateTime(model.FromDate.Value.Year, 9, 30);
                        }
                        if (model.FromDate.Value.Month > 9 && model.FromDate.Value.Month <= 12)
                        {
                            model.FromDate = new DateTime(model.FromDate.Value.Year, 10, 1);
                            model.ToDate = new DateTime(model.FromDate.Value.Year, 12, 31);
                        }
                    }
                    if (periodType == 10091001)
                    {
                        model.FromDate = new DateTime(model.FromDate.Value.Year, model.FromDate.Value.Month, 1);
                        model.ToDate = new DateTime(model.FromDate.Value.Year, model.FromDate.Value.Month, 1).AddMonths(1).AddDays(-1); 
                    }
                    if (periodType == 10091004)
                    {
                        model.FromDate = GetFirstDayOfWeek(model.FromDate.Value);
                        model.ToDate = model.FromDate.Value.AddDays(7);
                    }
                    if (periodType == 10091002)
                    {
                        model.FromDate = model.FromDate.Value;
                        model.ToDate = model.FromDate.Value;
                    }
                }
            }
            catch (Exception ex)
            {

                _logger.LogError(ex.Message);
                throw;
            }
            await InvokeAsync(StateHasChanged);
        }

        protected async  void DateChanged(DateTime? data)
        {
            if (data != null)
            {
                if (IdfsStatisticPeriodType != null)
                {
                    if (IdfsStatisticPeriodType > 0)
                    {
                        await CompareSelectedPeriodType(IdfsStatisticPeriodType);
                    }
                }
                
            }


        }
        /// <summary>
        /// Returns the first day of the week that the specified
        /// date is in using the current culture. 
        /// </summary>
        public  DateTime GetFirstDayOfWeek(DateTime dayInWeek)
        {
            try
            {
                CultureInfo defaultCultureInfo = CultureInfo.CurrentCulture;
                return GetFirstDayOfWeek(dayInWeek, defaultCultureInfo);
            }
            catch (Exception ex)
            {

                _logger.LogError(ex.Message);
                throw;
            }
           
        }

        /// <summary>
        /// Returns the first day of the week that the specified date 
        /// is in. 
        /// </summary>
        public  DateTime GetFirstDayOfWeek(DateTime dayInWeek, CultureInfo cultureInfo)
        {
            DayOfWeek firstDay = cultureInfo.DateTimeFormat.FirstDayOfWeek;
            DateTime firstDayInWeek = dayInWeek.Date;
            while (firstDayInWeek.DayOfWeek != firstDay)
                firstDayInWeek = firstDayInWeek.AddDays(-1);

            return firstDayInWeek;
        }
        public async Task SetParameter(object data)
        {

            try
            {

                if (data != null)
                {
                    model.selectedParameter = (long)data;
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            await InvokeAsync(StateHasChanged);
        }
        public async Task SetAgeGroups(object data)
        {

            try
            {

                if (data != null)
                {
                    model.selectedAgeGroup = (long)data;
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

            await InvokeAsync(StateHasChanged);
        }
        protected async void HandleValidSearchSubmit(AddStatisticalDataViewModel _model)
        {
            List<USP_ADMIN_STAT_SETResultResponseModel> response = new List<USP_ADMIN_STAT_SETResultResponseModel>();
            USP_ADMIN_STAT_SETResultRequestModel request = new USP_ADMIN_STAT_SETResultRequestModel();
            try
            {
                StringBuilder sb = new StringBuilder();
                if (userPermissions.Create)
                {
                   
                    if (_form.IsValid)
                    {
                        if (model.idfStatistic != null)
                        {
                            request.idfStatistic = model.idfStatistic;
                        }

                        request.datStatisticStartDate = _model.FromDate.Value;
                        request.datStatisticFinishDate = model.ToDate.Value;
                        sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.StatisticalDataDetailsStartDateForPeriodFieldLabel) + ":" + _model.FromDate.Value.ToString());
                        sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.ToFieldLabel) + ":" + model.ToDate.Value.ToString() +",");
                      
                        if (_model.selectedStatisticalDataItem != 0 && _model.selectedStatisticalDataItem != null)
                        {
                            request.idfsStatisticDataType = _model.selectedStatisticalDataItem;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.StatisticalDataDetailsStatisticalDataTypeFieldLabel) + ":" + _StatisticalDataTypeDD.TextProperty + ",");
                        }
                        request.varValue = Int32.Parse(_model.varValue.ToString());
                        if (_model.selectedAgeGroup != null)
                        {
                            request.idfsStatisticalAgeGroup = _model.selectedAgeGroup.Value;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.StatisticalAgeGroupFieldLabel) + ":" + _AgeGroupDD.TextProperty.ToString() + ",");
                        }
                        if (_model.selectedParameter != null)
                        {
                            request.idfsMainBaseReference = _model.selectedParameter.Value;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.ParameterFieldLabel) + ":" + _ParameterDD.TextProperty + ",");
                        }
                        if (model.selectedAreaType != null)
                        {
                            request.idfsStatisticAreaType = model.selectedAreaType;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.StatisticalDataStatisticalAreaTypeFieldLabel) + ":" + model.StatisticalAreaType + ",");
                        }
                        if (model.selectedPeriodType != null)
                        {
                            request.idfsStatisticPeriodType = model.selectedPeriodType;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.StatisticalDataStatisticalAreaTypeFieldLabel) + ":" + model.StatisticalPeriodType + ",");
                        }




                        if (_model.LocationViewModel.AdminLevel3Value != null)
                        {
                            request.LocationUserControlidfsSettlement = _model.LocationViewModel.AdminLevel3Value;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel3FieldLabel ) + ":" + _model.LocationViewModel.AdminLevel3Text + ",");
                        }
                        else if (_model.LocationViewModel.AdminLevel2Value != null)
                        {
                            request.LocationUserControlidfsRayon = _model.LocationViewModel.AdminLevel2Value;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel2FieldLabel) + ":" + _model.LocationViewModel.AdminLevel2Text + ",");
                        }
                        else if (_model.LocationViewModel.AdminLevel1Value != null)
                        {
                            request.LocationUserControlidfsRegion = _model.LocationViewModel.AdminLevel1Value;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel1FieldLabel) + ":" + _model.LocationViewModel.AdminLevel1Text + ",");
                        }
                        else if (_model.LocationViewModel.AdminLevel0Value != null)
                        {
                            request.LocationUserControlidfsCountry = _model.LocationViewModel.AdminLevel0Value;
                            sb.AppendLine(Localizer.GetString(FieldLabelResourceKeyConstants.LocationAdministrativeLevel0FieldLabel) + ":" + _model.LocationViewModel.AdminLevel0Text + ",");
                        }

                        request.UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId);
                        request.SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);

                        response = await StatisticalDataClient.SaveStatisticalData(request);
                        if (response.Count > 0)
                        {
                            if (response[0].ReturnMessage == "DOES EXIST")
                            {
                                IsDuplicate = true;
                                ModalHeading = Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading);
                                SuccessMsg = String.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), sb.ToString());
                            }
                            else if (response[0].ReturnMessage == "SUCCESS")
                            {
                                IsDuplicate = false;
                                ModalHeading = Localizer.GetString(HeadingResourceKeyConstants.EIDSSSuccessModalHeading);
                                SuccessMsg = Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                await JsRuntime.InvokeAsync<string>("ShowSaveComplete");
                            }
                            await JsRuntime.InvokeAsync<string>("ShowSaveComplete");
                        }
                        await InvokeAsync(StateHasChanged);
                    }
                }
                else
                {
                    await JsRuntime.InvokeAsync<string>("showPermissionsWarning");
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
                locationViewModel.DivAdminLevel0 = true;
                locationViewModel.EnableAdminLevel0 = false;
                locationViewModel.ShowSettlement = true;
                locationViewModel.ShowSettlementType = false;
                locationViewModel.EnableAdminLevel1 = true;
                locationViewModel.EnableAdminLevel2 = true;
                locationViewModel.EnableAdminLevel3 = true;
                locationViewModel.ShowAdminLevel0 = true;//Country
                locationViewModel.ShowAdminLevel1 = true;//Region
                locationViewModel.ShowAdminLevel2 = true;//Rayon
                locationViewModel.ShowAdminLevel3 = true;//Settlement
                locationViewModel.ShowAdminLevel4 = false;
                locationViewModel.ShowAdminLevel5 = false;
                locationViewModel.ShowAdminLevel6 = false;
                locationViewModel.IsDbRequiredAdminLevel1 = true;
                if (model.idfStatistic != null)
                {
                    locationViewModel.IsDbRequiredAdminLevel2 = false;
                    locationViewModel.IsDbRequiredAdminLevel3 = false;
                }
                else
                {
                    locationViewModel.IsDbRequiredAdminLevel2 = true;
                    locationViewModel.IsDbRequiredAdminLevel3 = true;
                }
              
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


        protected async Task RedirectToSearch()
        {

            var uri = $"{NavManager.BaseUri}Administration/StatisticalData";
            NavManager.NavigateTo(uri, true);
        }
       
        #endregion
    }
}
