#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class SamplesListBase : VectorBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SamplesListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private int _sampleDatabaseQueryCount;
        private int _sampleLastDatabasePage;
        private int _sampleNewRecordCount;
        private int _samplesLastPage;

        #endregion Member Variables

        #region Properties

        protected bool IsLoading { get; set; }
        protected int Count { get; set; }
        protected int PreviousPageSize { get; set; }
        protected RadzenDataGrid<VectorSampleGetListViewModel> VectorSampleGrid { get; set; }

        #endregion Properties

        #region Constants

        private const string DefaultSortColumn = "CollectionDate";

        #endregion Constants

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            // wire up the state container change event
            VectorSessionStateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);

                await JsRuntime.InvokeVoidAsync("DetailedCollectionSamples.SetDotNetReference", _token,
                        lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();

                if (VectorSessionStateContainer != null)
                    VectorSessionStateContainer.OnChange -=
                        async property => await OnStateContainerChangeAsync(property);
            }

            base.Dispose(disposing);
        }

        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property is "SelectedVectorTab") await VectorSampleGrid.Reload();
        }

        #endregion State Container Events

        #region Load Data Methods

        protected async Task LoadVectorSampleGrid(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (VectorSampleGrid.PageSize != 0)
                    pageSize = VectorSampleGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                var page = args.Skip == null ? 1 : ((int) args.Skip + args.Top.GetValueOrDefault()) / pageSize;

                if (VectorSessionStateContainer.DetailedCollectionsSamplesList is not {Count: > 0}
                    || _samplesLastPage !=
                    (args.Skip == null ? 1 : (int) args.Skip + args.Top.GetValueOrDefault() / pageSize))
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
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

                    var request = new USP_VCTS_SAMPLE_GetListRequestModels
                    {
                        idfMaterial = null,
                        idfVector = VectorSessionStateContainer.VectorDetailedCollectionKey.GetValueOrDefault(),
                        LangID = GetCurrentLanguage()
                    };

                    VectorSessionStateContainer.DetailedCollectionsSamplesList =
                        await VectorClient.GetVectorSamplesAsync(request, _token);
                    if (page == 1)
                        _sampleDatabaseQueryCount = !VectorSessionStateContainer.DetailedCollectionsSamplesList.Any()
                            ? 0
                            : VectorSessionStateContainer.DetailedCollectionsSamplesList.First().TotalRowCount;
                }
                else if (VectorSessionStateContainer.DetailedCollectionsSamplesList != null)
                {
                    _sampleDatabaseQueryCount = VectorSessionStateContainer.DetailedCollectionsSamplesList.All(x =>
                        x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.SampleID < 0)
                        ? 0
                        : VectorSessionStateContainer.DetailedCollectionsSamplesList.First(x => x.SampleID > 0)
                            .TotalRowCount;
                }
                else
                {
                    VectorSessionStateContainer.DetailedCollectionsSamplesList =
                        new List<VectorSampleGetListViewModel>();
                }

                // remove or match up pending items that did not come from the database call
                if (VectorSessionStateContainer.DetailedCollectionsSamplesList != null)
                    for (var index = 0;
                         index < VectorSessionStateContainer.DetailedCollectionsSamplesList.Count;
                         index++)
                    {
                        // Remove any added unsaved records; will be added back at the end.
                        if (VectorSessionStateContainer.DetailedCollectionsSamplesList[index].SampleID < 0)
                        {
                            VectorSessionStateContainer.DetailedCollectionsSamplesList.RemoveAt(index);
                            index--;
                        }

                        if (VectorSessionStateContainer.PendingDetailedCollectionsSamplesList == null || index < 0 ||
                            VectorSessionStateContainer.DetailedCollectionsSamplesList.Count == 0 ||
                            VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.All(x =>
                                x.SampleID != VectorSessionStateContainer.DetailedCollectionsSamplesList[index]
                                    .SampleID)) continue;
                        {
                            if (VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.First(x =>
                                        x.SampleID == VectorSessionStateContainer.DetailedCollectionsSamplesList[index]
                                            .SampleID)
                                    .RowStatus == (int) RowStatusTypeEnum.Inactive)
                            {
                                VectorSessionStateContainer.DetailedCollectionsSamplesList.RemoveAt(index);
                                _sampleDatabaseQueryCount--;
                                index--;
                            }
                            else
                            {
                                VectorSessionStateContainer.DetailedCollectionsSamplesList[index] =
                                    VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.First(x =>
                                        x.SampleID == VectorSessionStateContainer.DetailedCollectionsSamplesList[index]
                                            .SampleID);
                            }
                        }
                    }

                Count = _sampleDatabaseQueryCount + _sampleNewRecordCount;

                if (_sampleNewRecordCount > 0)
                {
                    _sampleLastDatabasePage =
                        Math.DivRem(_sampleDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0 || _sampleLastDatabasePage == 0)
                        _sampleLastDatabasePage += 1;

                    if (page >= _sampleLastDatabasePage &&
                        VectorSessionStateContainer.PendingDetailedCollectionsSamplesList != null &&
                        VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.Any(x => x.SampleID < 0))
                    {
                        var newRecordsPendingSave =
                            VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.Where(x => x.SampleID < 0)
                                .ToList();
                        var counter = 0;
                        var pendingSavePage = page - _sampleLastDatabasePage;
                        var quotientNewRecords = Math.DivRem(Count, pageSize, out var remainderNewRecords);

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
                            VectorSessionStateContainer.DetailedCollectionsSamplesList?.Clear();
                        }
                        else
                        {
                            VectorSessionStateContainer.DetailedCollectionsSamplesList?.Clear();
                        }

                        while (counter < pageSize)
                        {
                            VectorSessionStateContainer.DetailedCollectionsSamplesList?.Add(pendingSavePage == 0
                                ? newRecordsPendingSave[counter]
                                : newRecordsPendingSave[
                                    pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                            counter += 1;
                        }
                    }

                    if (VectorSessionStateContainer.DetailedCollectionsSamplesList != null)
                        VectorSessionStateContainer.DetailedCollectionsSamplesList = VectorSessionStateContainer
                            .DetailedCollectionsSamplesList.AsQueryable()
                            .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                }

                _samplesLastPage = page;

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsLoading = false;
            }
        }

        #endregion Load Data Methods

        #region Edit Sample Events

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveSamples(VectorSampleGetListViewModel record,
            VectorSampleGetListViewModel originalRecord)
        {
            VectorSessionStateContainer.PendingDetailedCollectionsSamplesList ??=
                new List<VectorSampleGetListViewModel>();

            if (VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.Any(
                    x => x.SampleID == record.SampleID))
            {
                var index = VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingDetailedCollectionsSamplesList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.Add(record);
            }
        }

        protected async Task OnEditSampleClick(VectorSampleGetListViewModel sample)
        {
            try
            {
                VectorSessionStateContainer.SampleDetail = sample;
                var result = await DiagService.OpenAsync<SamplesModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.VectorDetailedCollectionSamplesHeading),
                    new Dictionary<string, object>(),
                    new DialogOptions
                    {
                        ShowTitle = true,
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result != null)
                {
                    TogglePendingSaveSamples(sample, sample);
                    await VectorSampleGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }

        #endregion Edit Sample Events

        #region Add Sample Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddSampleClick()
        {
            try
            {
                VectorSessionStateContainer.DetailedCollectionsSamplesList ??= new List<VectorSampleGetListViewModel>();

                VectorSessionStateContainer.SampleDetail = new VectorSampleGetListViewModel
                {
                    // set the defaults
                    CollectedByOrganizationID = VectorSessionStateContainer.DetailCollectedByInstitutionID
                };

                if (VectorSessionStateContainer.DetailCollectedByInstitutionID is not null &&
                    VectorSessionStateContainer.Organizations is not null)
                    VectorSessionStateContainer.SampleDetail.CollectedByOrganizationName =
                        VectorSessionStateContainer.Organizations.FirstOrDefault(x =>
                            x.idfOffice == VectorSessionStateContainer.DetailCollectedByInstitutionID)?.name;


                var result = await DiagService.OpenAsync<SamplesModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionSampleDetailsModalHeading),
                    new Dictionary<string, object>(),
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result is VectorSampleGetListViewModel model)
                {
                    _sampleNewRecordCount += 1;

                    VectorSessionStateContainer.DetailedCollectionsSamplesList.Add(model);

                    TogglePendingSaveSamples(model, null);

                    await VectorSampleGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Add Sample Event

        #region Delete Sample Events

        protected async Task OnDeleteSampleClick(VectorSampleGetListViewModel item)
        {
            try
            {
                if (ValidateSampleHasTest(item))
                {
                    await ShowInformationalDialog(
                        MessageResourceKeyConstants.UnableToDeleteBecauseOfChildRecordsMessage, null);
                }
                else
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (VectorSessionStateContainer.DetailedCollectionsSamplesList.Any(x =>
                                    x.SampleID == item.SampleID))
                            {
                                if (item.SampleID <= 0)
                                {
                                    VectorSessionStateContainer.DetailedCollectionsSamplesList.Remove(item);
                                    VectorSessionStateContainer.PendingDetailedCollectionsSamplesList.Remove(item);
                                    _sampleNewRecordCount--;
                                }
                                else
                                {
                                    result = item.ShallowCopy();
                                    result.RowAction = (int) RowActionTypeEnum.Delete;
                                    result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                    VectorSessionStateContainer.DetailedCollectionsSamplesList.Remove(item);
                                    Count--;

                                    TogglePendingSaveSamples(result, item);
                                }
                            }

                            await VectorSampleGrid.Reload();

                            DiagService.Close(result);
                        }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Delete Sample Events

        #region Validation Methods

        private bool ValidateSampleHasTest(VectorSampleGetListViewModel sample)
        {
            if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList == null) return false;
            return VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Any(x =>
                x.SampleID == sample.SampleID && x.RowStatus == 0);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            return await Task.FromResult(true);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}