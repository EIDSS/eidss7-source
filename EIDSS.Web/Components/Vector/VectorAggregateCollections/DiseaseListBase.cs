using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.ViewModels.Vector;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Vector.VectorAggregateCollections
{
    public class DiseaseListBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        protected IVectorTypeClient VectorTypeClient { get; set; }

        [Inject]
        private IVectorSpeciesTypeClient VectorSpeciesTypeClient { get; set; }

        [Inject]
        protected IVectorTypeCollectionMethodMatrixClient VectorTypeCollectionMethodMatrixClient { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private ISpeciesTypeClient SpeciesTypeClient { get; set; }

        [Inject]
        private ILogger<DiseaseListBase> Logger { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        protected IDiseaseClient DiseaseClient { get; set; }

        #endregion Dependencies

        #region Properties

        protected RadzenDataGrid<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel> Grid { get; set; }
        protected RadzenTemplateForm<VectorSurveillancePageViewModel> Form { get; set; }
        protected RadzenDropDown<VectorSurveillancePageViewModel> DiseaseDropDown { get; set; }
        protected List<BaseReferenceEditorsViewModel> VectorTypesList { get; set; }
        protected List<FilteredDiseaseGetListViewModel> DiseaseList { get; set; }
        protected bool IsDiseaseSelected { get; set; }
        protected bool IsLoading { get; set; }
        protected int DiseaseDatabaseQueryCount { get; set; }
        protected int NewDiseaseCount { get; set; }
        protected int DiseaseCount { get; set; }
        protected int DiseaseLastDatabasePage { get; set; }
        protected int DiseaseLastPage { get; set; }
        protected int PreviousPageSize { get; set; }
        protected bool AddButtonIsDisabled { get; set; }

        #endregion Properties

        #region Member Variables

        private CancellationToken _token;
        private CancellationTokenSource _source;

        #endregion Member Variables

        #region Constants

        private const string DefaultSortColumn = "DiseaseName";

        #endregion Constants

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            _source = new();
            _token = _source.Token;

            IsDiseaseSelected = true;

            VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            await LoadDiseases(new LoadDataArgs());

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("AggregateCollectionDiseaseList.SetDotNetReference", _token, lDotNetReference);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            VectorSessionStateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
        }

        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "VectorSessionSummaryKey")
            {
                await InvokeAsync(StateHasChanged);
                await Grid.Reload();
            }
        }

        #endregion State Container Events

        #region Load Disease Grid

        protected async Task LoadDiseaseListGridView(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (Grid.PageSize != 0)
                    pageSize = Grid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (VectorSessionStateContainer.AggregateCollectionDiseaseList is { Count: 0 } ||
                        DiseaseLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
                        IsLoading = true;

                    
                    if (IsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        if (VectorSessionStateContainer.VectorSessionSummaryKey.HasValue)
                        {
                            var request = new USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailRequestModel()
                            {
                                LangID = GetCurrentLanguage(),
                                idfsVSSessionSummary = VectorSessionStateContainer.VectorSessionSummaryKey.Value
                            };

                            VectorSessionStateContainer.AggregateCollectionDiseaseList = await VectorClient.GetSessionDiagnosis(request, _token);
                        }
                        else
                        {
                            VectorSessionStateContainer.AggregateCollectionDiseaseList =
                                new List<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>();
                        }
                        
                        if (page == 1)
                            DiseaseDatabaseQueryCount = !VectorSessionStateContainer.AggregateCollectionDiseaseList.Any() ? 0 : VectorSessionStateContainer.AggregateCollectionDiseaseList.First().TotalRowCount;
                    }
                    else if (VectorSessionStateContainer.AggregateCollectionDiseaseList != null)
                    {
                        DiseaseDatabaseQueryCount = VectorSessionStateContainer.AggregateCollectionDiseaseList.All(x =>
                            x.intRowStatus == (int)RowStatusTypeEnum.Inactive || x.idfsVSSessionSummaryDiagnosis < 0)
                            ? 0
                            : VectorSessionStateContainer.AggregateCollectionDiseaseList.First(x => x.idfsVSSessionSummaryDiagnosis > 0).TotalRowCount;
                    }

                    if (VectorSessionStateContainer.AggregateCollectionDiseaseList != null)
                        for (var index = 0; index < VectorSessionStateContainer.AggregateCollectionDiseaseList.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (VectorSessionStateContainer.AggregateCollectionDiseaseList[index].idfsVSSessionSummaryDiagnosis < 0)
                            {
                                VectorSessionStateContainer.AggregateCollectionDiseaseList.RemoveAt(index);
                                index--;
                            }

                            if (VectorSessionStateContainer.PendingAggregateCollectionDiseaseList == null || index < 0 || VectorSessionStateContainer.AggregateCollectionDiseaseList.Count == 0 ||
                                VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.All(x =>
                                    x.idfsVSSessionSummaryDiagnosis != VectorSessionStateContainer.AggregateCollectionDiseaseList[index].idfsVSSessionSummaryDiagnosis)) continue;
                            {
                                if (VectorSessionStateContainer.PendingAggregateCollectionDiseaseList
                                        .First(x => x.idfsVSSessionSummaryDiagnosis == VectorSessionStateContainer.AggregateCollectionDiseaseList[index].idfsVSSessionSummaryDiagnosis)
                                        .intRowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    VectorSessionStateContainer.AggregateCollectionDiseaseList.RemoveAt(index);
                                    DiseaseDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    VectorSessionStateContainer.AggregateCollectionDiseaseList[index] = VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.First(x =>
                                        x.idfsVSSessionSummaryDiagnosis == VectorSessionStateContainer.AggregateCollectionDiseaseList[index].idfsVSSessionSummaryDiagnosis);
                                }
                            }
                        }

                    DiseaseCount = DiseaseDatabaseQueryCount + NewDiseaseCount;

                    if (NewDiseaseCount > 0)
                    {
                        DiseaseLastDatabasePage = Math.DivRem(DiseaseDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || DiseaseLastDatabasePage == 0)
                            DiseaseLastDatabasePage += 1;

                        if (page >= DiseaseLastDatabasePage && VectorSessionStateContainer.PendingAggregateCollectionDiseaseList != null &&
                            VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.Any(x => x.idfsVSSessionSummaryDiagnosis < 0))
                        {
                            var newRecordsPendingSave =
                               VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.Where(x => x.idfsVSSessionSummaryDiagnosis < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - DiseaseLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(DiseaseCount, pageSize, out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = pageSize - remainderDatabaseQuery > newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : pageSize - remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                remainderDatabaseQuery = 1;
                                pageSize = remainderNewRecords;
                                VectorSessionStateContainer.AggregateCollectionDiseaseList?.Clear();
                            }
                            else
                            {
                                VectorSessionStateContainer.AggregateCollectionDiseaseList?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                VectorSessionStateContainer.AggregateCollectionDiseaseList?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (VectorSessionStateContainer.AggregateCollectionDiseaseList != null)
                            VectorSessionStateContainer.AggregateCollectionDiseaseList = VectorSessionStateContainer.AggregateCollectionDiseaseList.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    DiseaseLastPage = page;
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Disease Grid

        #region Load Disease Drop Down

        protected async Task LoadDiseases(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = EIDSSConstants.HACodeList.VectorHACode,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = EIDSSConstants.UsingType.StandardCaseType,
                AdvancedSearchTerm = args.Filter
            };
            DiseaseList = await CrossCuttingClient.GetFilteredDiseaseList(request);

            await InvokeAsync(StateHasChanged);
        }

        #endregion Load Disease Drop Down

        #region Diagnosis Grid

        protected void OnDiseaseChange(object value)
        {
            if (value != null)
                IsDiseaseSelected = true;
        }

        protected async Task OnAddDiseaseClick()
        {
            AddButtonIsDisabled = true;

            var item = new USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel();
            NewDiseaseCount++;
            DiseaseCount = DiseaseDatabaseQueryCount + NewDiseaseCount;
            await Grid.InsertRow(item);
        }

        protected void OnCreateRow(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel item)
        {
            var disease = DiseaseList.Find(x => x.DiseaseID == item.DiseaseID);
            if (disease != null) item.DiseaseName = disease.DiseaseName;

            if (VectorSessionStateContainer.AggregateCollectionDiseaseList.Any())
            {
                int.TryParse(VectorSessionStateContainer.AggregateCollectionDiseaseList.Max(t => t.RowNumber).ToString(), out int maxRowNumber);
                maxRowNumber++;
                item.RowNumber = maxRowNumber;
            }
            else
            {
                item.RowNumber = 1;
            }

            item.RowAction = (int)RowActionTypeEnum.Insert;
            item.intRowStatus = (int)RowStatusTypeEnum.Active;
            item.idfsVSSessionSummaryDiagnosis = (VectorSessionStateContainer.AggregateCollectionDiseaseList.Count + 1) * -1;
            item.idfsVSSessionSummary = VectorSessionStateContainer.VectorSessionSummaryKey.GetValueOrDefault();

            VectorSessionStateContainer.AggregateCollectionDiseaseList.Add(item);

            TogglePendingSaveDisease(item, null);

            AddButtonIsDisabled = false;
        }

        protected void OnUpdateRow(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel item)
        {
            var disease = DiseaseList.Find(x => x.DiseaseID == item.DiseaseID);
            if (disease != null) item.DiseaseName = disease.DiseaseName;

            item.RowAction = (int)RowActionTypeEnum.Update;

            if (VectorSessionStateContainer.AggregateCollectionDiseaseList.Any(x => x.idfsVSSessionSummaryDiagnosis == item.idfsVSSessionSummaryDiagnosis))
            {
                int index = VectorSessionStateContainer.AggregateCollectionDiseaseList.IndexOf(item);
                VectorSessionStateContainer.AggregateCollectionDiseaseList[index] = item;

                TogglePendingSaveDisease(item, item);
            }

            AddButtonIsDisabled = false;
        }

        protected async Task OnEditDiseaseClick(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel item)
        {
            AddButtonIsDisabled = true;
            await Grid.EditRow(item);
        }

        protected async Task OnDeleteDiseaseClick(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel item)
        {
            if (item.idfsVSSessionSummaryDiagnosis <= 0)
            {
                VectorSessionStateContainer.AggregateCollectionDiseaseList.Remove(item);
                VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.Remove(item);
                NewDiseaseCount--;
            }
            else
            {
                var deletedRecord = item.ShallowCopy();
                deletedRecord.RowAction = (int)RowActionTypeEnum.Delete;
                deletedRecord.intRowStatus = (int)RowStatusTypeEnum.Inactive;
                VectorSessionStateContainer.AggregateCollectionDiseaseList.Remove(item);
                DiseaseCount--;

                TogglePendingSaveDisease(deletedRecord, item);
            }

            await Grid.Reload();
        }

        protected async Task OnSaveDiseaseClick(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel item)
        {
            await Grid.UpdateRow(item);
        }

        protected void OnCancelDiseaseEditClick(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel item)
        {
            Grid.CancelEditRow(item);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveDisease(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel record,
            USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel originalRecord)
        {
            VectorSessionStateContainer.PendingAggregateCollectionDiseaseList ??=
                new List<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>();

            if (VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.Any(x => x.idfsVSSessionSummaryDiagnosis == record.idfsVSSessionSummaryDiagnosis))
            {
                var index = VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingAggregateCollectionDiseaseList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.Add(record);
            }
        }

        #endregion Diagnosis Grid

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            // no validations so just set to true
            VectorSessionStateContainer.AggregateCollectionsDiseaseListValidIndicator = true;

            VectorSessionStateContainer.AggregateCollectionsDiseaseListModifiedIndicator =
                VectorSessionStateContainer.PendingAggregateCollectionDiseaseList != null
                && VectorSessionStateContainer.PendingAggregateCollectionDiseaseList.Any();

            return await Task.FromResult(VectorSessionStateContainer.AggregateCollectionsDiseaseListValidIndicator);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}