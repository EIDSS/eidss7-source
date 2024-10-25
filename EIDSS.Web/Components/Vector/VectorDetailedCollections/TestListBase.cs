#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using EIDSS.Web.Extensions;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class TestListBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<TestListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Properties

        protected RadzenDataGrid<FieldTestGetListViewModel> TestListGrid { get; set; }
        protected List<FieldTestGetListViewModel> SelectedTests { get; set; }
        protected bool IsLoading { get; set; }
        protected int FieldTestsCount { get; set; } = 1;
        private int FieldTestsDatabaseQueryCount { get; set; }
        private int FieldTestsNewRecordCount { get; set; }
        private int FieldTestsLastDatabasePage { get; set; }
        private static int FieldTestsLastPage => 1;

        #endregion Properties

        #region Constants

        private const string DefaultTestSortColumn = "ResultDate";

        #endregion Constants

        #endregion Globals

        #region Methods

        #region Lifecyle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
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

                await JsRuntime.InvokeVoidAsync("DetailedCollectionFieldTest.SetDotNetReference", _token, lDotNetReference)
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

                VectorSessionStateContainer.OnChange -= async property => await OnStateContainerChangeAsync(property);
            }

            base.Dispose(disposing);
        }

        #endregion Lifecyle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "SelectedVectorTab" && VectorSessionStateContainer.SelectedVectorTab == (int)VectorTabs.DetailedCollectionsTab)
            {
                await TestListGrid.Reload();
            }
        }

        #endregion State Container Events

        #region Load Data

        /// <summary>
        ///
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadTestGrid(LoadDataArgs args)
        {
            try
            {
                string sortColumn = DefaultTestSortColumn,
                        sortOrder = SortConstants.Descending;

                var pageSize = TestListGrid.PageSize != 0 ? TestListGrid.PageSize : 10;
                var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList is null
                    || !VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Any())
                {
                    IsLoading = true;
                }

                if (FieldTestsLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = DefaultTestSortColumn;
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.FirstOrDefault().Property;
                        sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue ? args.Sorts.FirstOrDefault().SortOrder.Value.ToString() : SortConstants.Descending;
                    }

                    var request = new USP_VCTS_FIELDTEST_GetListRequestModel
                    {
                        idfVector = VectorSessionStateContainer.VectorDetailedCollectionKey.GetValueOrDefault(),
                        LangID = GetCurrentLanguage()
                    };

                    VectorSessionStateContainer.DetailedCollectionsFieldTestsList = await VectorClient.GetVectorSessionFieldTestsAsync(request, _token);
                    FieldTestsDatabaseQueryCount = !VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Any()
                        ? 0
                        : VectorSessionStateContainer.DetailedCollectionsFieldTestsList.First().TotalRowCount;
                }
                else if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList != null)
                {
                    FieldTestsDatabaseQueryCount = !VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Any()
                        ? 0
                        : VectorSessionStateContainer.DetailedCollectionsFieldTestsList.First().TotalRowCount;
                }

                // remove or match up pending items that did not come from the database call
                if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList != null)
                {
                    for (var index = 0; index < VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Count; index++)
                    {
                        // Remove any added unsaved records; will be added back at the end.
                        if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList[index].TestID < 0)
                        {
                            VectorSessionStateContainer.DetailedCollectionsFieldTestsList.RemoveAt(index);
                            index--;
                        }

                        if (VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList == null || index < 0 || VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Count == 0 || VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.All(x =>
                                x.TestID != VectorSessionStateContainer.DetailedCollectionsFieldTestsList[index].TestID)) continue;
                        {
                            if (VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.First(x => x.TestID == VectorSessionStateContainer.DetailedCollectionsFieldTestsList[index].TestID)
                                    .RowStatus == (int)RowStatusTypeEnum.Inactive)
                            {
                                VectorSessionStateContainer.DetailedCollectionsFieldTestsList.RemoveAt(index);
                                FieldTestsDatabaseQueryCount--;
                                index--;
                            }
                            else
                            {
                                VectorSessionStateContainer.DetailedCollectionsFieldTestsList[index] = VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.First(x =>
                                    x.TestID == VectorSessionStateContainer.DetailedCollectionsFieldTestsList[index].TestID);
                            }
                        }
                    }
                }

                FieldTestsCount = FieldTestsDatabaseQueryCount + FieldTestsNewRecordCount;

                if (FieldTestsNewRecordCount > 0)
                {
                    FieldTestsLastDatabasePage = Math.DivRem(FieldTestsDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0 || FieldTestsLastDatabasePage == 0)
                        FieldTestsLastDatabasePage += 1;

                    if (page >= FieldTestsLastDatabasePage && VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList != null &&
                        VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.Any(x => x.TestID < 0))
                    {
                        var newRecordsPendingSave =
                            VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.Where(x => x.TestID < 0).ToList();
                        var counter = 0;
                        var pendingSavePage = page - FieldTestsLastDatabasePage;
                        var quotientNewRecords = Math.DivRem(FieldTestsCount, pageSize, out var remainderNewRecords);

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
                            VectorSessionStateContainer.DetailedCollectionsFieldTestsList?.Clear();
                        }
                        else
                        {
                            VectorSessionStateContainer.DetailedCollectionsFieldTestsList?.Clear();
                        }

                        while (counter < pageSize)
                        {
                            VectorSessionStateContainer.DetailedCollectionsFieldTestsList?.Add(pendingSavePage == 0
                                ? newRecordsPendingSave[counter]
                                : newRecordsPendingSave[
                                    pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                            counter += 1;
                        }
                    }

                    if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList != null)
                        VectorSessionStateContainer.DetailedCollectionsFieldTestsList =
                            VectorSessionStateContainer.DetailedCollectionsFieldTestsList.AsQueryable()
                            .OrderBy(sortColumn,
                                     sortOrder == SortConstants.Ascending).ToList();
                }

                FieldTestsLastDatabasePage = page;

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

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveTests(FieldTestGetListViewModel record, FieldTestGetListViewModel originalRecord)
        {
            VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList ??= new List<FieldTestGetListViewModel>();

            if (VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.Any(x => x.TestID == record.TestID))
            {
                var index = VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.IndexOf(originalRecord);
                VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList[index] = record;
            }
            else
            {
                VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.Add(record);
            }
        }

        #endregion Load Data

        #region Add Test Button Click Event

        protected async Task OnAddTestClick()
        {
            try
            {
                VectorSessionStateContainer.FieldTestDetail = new FieldTestGetListViewModel();

                var result = await DiagService.OpenAsync<TestModal>(Localizer.GetString(HeadingResourceKeyConstants.TestDetailsModalHeading), new Dictionary<string, object>(),
                    options: new DialogOptions { Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true, CloseDialogOnOverlayClick = true, ShowClose = true });

                if (result is FieldTestGetListViewModel model)
                {
                    FieldTestsNewRecordCount += 1;

                    VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Add(model);

                    TogglePendingSaveTests(model, null);

                    await TestListGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Add Test Button Click Event

        #region Edit Test Button Click Event

        /// <summary>
        ///
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnEditTestClick(FieldTestGetListViewModel item)
        {
            try
            {
                VectorSessionStateContainer.FieldTestDetail = item;

                var result = await DiagService.OpenAsync<TestModal>(Localizer.GetString(HeadingResourceKeyConstants.TestDetailsModalHeading), new Dictionary<string, object>(),
                    options: new DialogOptions { Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true, CloseDialogOnOverlayClick = true, ShowClose = true });

                if (result != null)
                {
                    TogglePendingSaveTests(item, item);
                    await TestListGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Edit Test Button Click Event

        #region Delete Test Button Click Event

        protected async Task OnDeleteTestClick(FieldTestGetListViewModel item)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Any(x => x.TestID == item.TestID))
                        {
                            if (item.TestID <= 0)
                            {
                                VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Remove(item);
                                VectorSessionStateContainer.PendingDetailedCollectionsFieldTestsList.Remove(item);
                                FieldTestsNewRecordCount--;
                            }
                            else
                            {
                                result = item.ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Remove(item);
                                FieldTestsCount--;

                                TogglePendingSaveTests(result, item);
                            }
                        }

                        await TestListGrid.Reload();

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

        #endregion Delete Test Button Click Event

        #region Selected Test Change Event

        protected void OnTestSelectionChange(FieldTestGetListViewModel item)
        {
            SelectedTests ??= new List<FieldTestGetListViewModel>();

            if (SelectedTests.Contains(item))
            {
                SelectedTests.Remove(item);
            }
            else
            {
                SelectedTests.Add(item);
            }
        }

        #endregion Selected Test Change Event

        #region Validation Methods

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