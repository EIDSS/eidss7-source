#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class BatchesBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<BatchesBase> Logger { get; set; }
        [Inject] private ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback<int> SearchEvent { get; set; }
        [Parameter] public EventCallback<int> ClearSearchEvent { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public EventCallback SetMyFavoriteEvent { get; set; }
        [Parameter] public EventCallback BatchEvent { get; set; }

        #endregion

        #region Properties

        protected RadzenDataGrid<BatchesGetListViewModel> BatchesGrid { get; set; }
        protected RadzenDataGrid<TestingGetListViewModel> TestsGrid { get; set; }
        public int Count { get; set; }
        private AdvancedSearchGetRequestModel AdvancedSearchCriteria { get; set; } = new();
        private bool IsAdvancedSearch { get; set; }
        private bool IsSearchPerformed { get; set; }
        public bool IsLoading { get; set; }
        public bool IsTestsLoading { get; set; }
        protected IList<BatchesGetListViewModel> Batches { get; set; }
        private bool IsReload { get; set; }
        protected SearchComponent Search { get; set; }

        public bool IsSelected
        {
            get
            {
                _isSelected = false;
                if (LaboratoryService.Batches != null)
                    _isSelected = Batches.Any(i =>
                        LaboratoryService.SelectedBatches != null && LaboratoryService.SelectedBatches.Contains(i));

                return _isSelected;
            }
        }

        #endregion

        #region Constants

        private const string ScrollToTopJs = "scrollToTop";

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;
        private bool _isSelected;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public BatchesBase(CancellationToken token) : base(token)
        {
            _token = token;
        }

        /// <summary>
        /// </summary>
        protected BatchesBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                _logger = Logger;

                authenticatedUser = _tokenService.GetAuthenticatedUser();
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);

                if (_userPermissions.Read)
                {
                    await BrowserStorage.GetAsync<string>(LaboratorySearchStorageConstants.BatchesSearchString);

                    if (LaboratoryService.Batches == null)
                    {
                        IsLoading = true;
                    }
                    else if (LaboratoryService.TabChangeIndicator)
                    {
                        LaboratoryService.TabChangeIndicator = false;

                        if (LaboratoryService.SearchBatches != null)
                        {
                            IsSearchPerformed = true;
                            IsAdvancedSearch = true;
                            Search.AdvancedSearchPerformedIndicator = true;
                        }
                    }
                }

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    if (_userPermissions.Read)
                    {
                        LaboratoryService.SelectedBatches = new List<BatchesGetListViewModel>();
                        LaboratoryService.SelectedBatchTests = new List<TestingGetListViewModel>();
                    }
                    else
                        await InsufficientPermissions();

                    await GetTestResultTypes();
                    await GetTestCategoryTypes();
                }

                await base.OnAfterRenderAsync(firstRender);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
        }

        /// <summary>
        ///     Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task LoadBatchesData(LoadDataArgs args)
        {
            try
            {
                if (_userPermissions.Read)
                {
                    var pageSize = 100;
                    string sortColumn,
                        sortOrder;

                    if (BatchesGrid.PageSize != 0)
                        pageSize = BatchesGrid.PageSize;

                    args.Top ??= 0;

                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "EIDSSBatchTestID";
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First().Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First().SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    if (LaboratoryService.SearchBatches is null && LaboratoryService.Batches is null)
                        IsLoading = true;

                    if (IsLoading && IsSearchPerformed == false && IsReload == false)
                    {
                        if (IsAdvancedSearch)
                        {
                            var indicatorResult = await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                                .LaboratoryBatchesAdvancedSearchPerformedIndicatorKey);

                            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
                            if (searchPerformedIndicator)
                            {
                                var searchModelResult = await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                                    SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchModelKey);

                                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                                if (searchModel != null) AdvancedSearchCriteria = searchModel;

                                if (AdvancedSearchCriteria.SampleStatusTypeList != null &&
                                    AdvancedSearchCriteria.SampleStatusTypeList.Any(x => x == 0))
                                {
                                    // Un-accessioned goes in the accession indicator list parameter.
                                    AdvancedSearchCriteria.AccessionIndicatorList =
                                        AdvancedSearchCriteria.SampleStatusTypeList.First(x => x == 0)
                                            .ToString();

                                    var sampleStatusTypes =
                                        AdvancedSearchCriteria.SampleStatusTypeList.ToList();
                                    sampleStatusTypes.Remove(sampleStatusTypes.First(x => x == 0));
                                    AdvancedSearchCriteria.SampleStatusTypeList = sampleStatusTypes;

                                    AdvancedSearchCriteria.SampleStatusTypes =
                                        sampleStatusTypes.Count == 0
                                            ? null
                                            : Join(",", AdvancedSearchCriteria.SampleStatusTypeList);
                                }
                            }

                            var request = new AdvancedSearchGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                AccessionIndicatorList = AdvancedSearchCriteria.AccessionIndicatorList,
                                DateFrom = AdvancedSearchCriteria.DateFrom,
                                DateTo = AdvancedSearchCriteria.DateTo,
                                DiseaseID = AdvancedSearchCriteria.DiseaseID,
                                EIDSSLaboratorySampleID = AdvancedSearchCriteria.EIDSSLaboratorySampleID,
                                EIDSSLocalOrFieldSampleID = AdvancedSearchCriteria.EIDSSLocalOrFieldSampleID,
                                EIDSSReportSessionOrCampaignID = AdvancedSearchCriteria.EIDSSReportSessionOrCampaignID,
                                EIDSSTransferID = AdvancedSearchCriteria.EIDSSTransferID,
                                FarmOwnerName = AdvancedSearchCriteria.FarmOwnerName,
                                PatientName = AdvancedSearchCriteria.PatientName,
                                ReportOrSessionTypeID = AdvancedSearchCriteria.ReportOrSessionTypeID,
                                ResultsReceivedFromOrganizationID =
                                    AdvancedSearchCriteria.ResultsReceivedFromOrganizationID,
                                SampleStatusTypeList = AdvancedSearchCriteria.SampleStatusTypeList,
                                SampleStatusTypes = AdvancedSearchCriteria.SampleStatusTypes,
                                SampleTypeID = AdvancedSearchCriteria.SampleTypeID,
                                SentToOrganizationSiteID = AdvancedSearchCriteria.SentToOrganizationSiteID,
                                SpeciesTypeID = AdvancedSearchCriteria.SpeciesTypeID,
                                SurveillanceTypeID = AdvancedSearchCriteria.SurveillanceTypeID,
                                TestNameTypeID = AdvancedSearchCriteria.TestNameTypeID,
                                TestResultDateFrom = AdvancedSearchCriteria.TestResultDateFrom,
                                TestResultDateTo = AdvancedSearchCriteria.TestResultDateTo,
                                TestResultTypeID = AdvancedSearchCriteria.TestResultTypeID,
                                TestStatusTypeID = AdvancedSearchCriteria.TestStatusTypeID,
                                TransferredToOrganizationID = AdvancedSearchCriteria.TransferredToOrganizationID,
                                FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                      (long) SiteTypes.ThirdLevel,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                            };

                            LaboratoryService.SearchBatches =
                                await LaboratoryClient.GetBatchesAdvancedSearchList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                if (LaboratoryService.SearchBatches.Count == 0)
                                    await SearchEvent.InvokeAsync(0);
                                else
                                    await SearchEvent.InvokeAsync(LaboratoryService.SearchBatches[0].TotalRowCount);

                                ApplyPendingSaveRecordsToSearchList();

                                Batches = LaboratoryService.SearchBatches.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                            }
                        }
                        else
                        {
                            var request = new BatchesGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                Page = 1,
                                PageSize = MaxValue - 1,
                                SortColumn = sortColumn,
                                SortOrder = sortOrder,
                                UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                UserOrganizationID = authenticatedUser.OfficeId,
                                UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                            };

                            LaboratoryService.Batches = await LaboratoryClient.GetBatchesList(request, _token);
                            if (_source.IsCancellationRequested == false)
                            {
                                ApplyPendingSaveRecordsToDefaultList();

                                Batches = LaboratoryService.Batches.Take(pageSize).ToList();
                            }
                        }

                        Count = Batches.Count == 0 ? 0 : Batches.First().TotalRowCount;
                    }
                    else
                    {
                        if (LaboratoryService.SearchBatches == null)
                        {
                            if (LaboratoryService.Batches != null)
                            {
                                ApplyDefaultListSort(sortColumn, sortOrder);

                                ApplyPendingSaveRecordsToDefaultList();

                                Batches = LaboratoryService.Batches.Skip((page - 1) * pageSize).Take(pageSize)
                                    .ToList();
                                Count =
                                    (LaboratoryService.Batches ?? new List<BatchesGetListViewModel>()).Any()
                                        ? (LaboratoryService.Batches ?? new List<BatchesGetListViewModel>()).First()
                                        .TotalRowCount
                                        : Count;
                            }
                        }
                        else
                        {
                            ApplySearchListSort(sortColumn, sortOrder);

                            ApplyPendingSaveRecordsToSearchList();

                            Batches = LaboratoryService.SearchBatches.Skip((page - 1) * pageSize).Take(pageSize)
                                .ToList();
                            Count =
                                (LaboratoryService.SearchBatches ?? new List<BatchesGetListViewModel>()).Any()
                                    ? (LaboratoryService.SearchBatches ?? new List<BatchesGetListViewModel>()).First()
                                    .TotalRowCount
                                    : Count;
                        }
                    }
                }

                if (Batches != null)
                    foreach (var t in Batches)
                        t.Tests ??= new List<TestingGetListViewModel>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);

                //Catch timeout exception
                if (ex.Message.Contains("Timeout"))
                {
                    if (_source?.IsCancellationRequested == false) _source?.Cancel();
                    await ShowNarrowSearchCriteriaDialog();
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                IsLoading = false;
                IsReload = false;
                IsSearchPerformed = false;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        private void ApplyDefaultListSort(string sortColumn, string sortOrder)
        {
            if (sortColumn is null) return;
            if (sortOrder == SortConstants.Ascending)
                LaboratoryService.Batches = sortColumn switch
                {
                    "EIDSSBatchTestID" => LaboratoryService.Batches.OrderBy(x => x.EIDSSBatchTestID)
                        .ToList(),
                    "BatchStatusTypeName" => LaboratoryService.Batches.OrderBy(x => x.BatchStatusTypeName)
                        .ToList(),
                    _ => LaboratoryService.Batches
                };
            else
                LaboratoryService.Batches = sortColumn switch
                {
                    "EIDSSBatchTestID" => LaboratoryService.Batches.OrderByDescending(x => x.EIDSSBatchTestID)
                        .ToList(),
                    "BatchStatusTypeName" => LaboratoryService.Batches.OrderByDescending(x => x.BatchStatusTypeName)
                        .ToList(),
                    _ => LaboratoryService.Batches
                };
        }

        /// <summary>
        /// </summary>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        private void ApplySearchListSort(string sortColumn, string sortOrder)
        {
            if (sortColumn is null) return;
            if (sortOrder == SortConstants.Ascending)
                LaboratoryService.SearchBatches = sortColumn switch
                {
                    "EIDSSBatchTestID" => LaboratoryService.SearchBatches.OrderBy(x => x.EIDSSBatchTestID)
                        .ToList(),
                    "BatchStatusTypeName" => LaboratoryService.SearchBatches.OrderBy(x => x.BatchStatusTypeName)
                        .ToList(),
                    _ => LaboratoryService.SearchBatches
                };
            else
                LaboratoryService.SearchBatches = sortColumn switch
                {
                    "EIDSSBatchTestID" => LaboratoryService.SearchBatches.OrderByDescending(x => x.EIDSSBatchTestID)
                        .ToList(),
                    "BatchStatusTypeName" => LaboratoryService.SearchBatches
                        .OrderByDescending(x => x.BatchStatusTypeName)
                        .ToList(),
                    _ => LaboratoryService.SearchBatches
                };
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToDefaultList()
        {
            if (LaboratoryService.PendingSaveBatches == null || !LaboratoryService.PendingSaveBatches.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveBatches)
                if (LaboratoryService.Batches != null &&
                    LaboratoryService.Batches.All(x => x.BatchTestID != t.BatchTestID))
                {
                    LaboratoryService.Batches?.Add(t);
                }
                else
                {
                    if (LaboratoryService.Batches == null) continue;
                    var recordIndex = LaboratoryService.Batches.ToList().FindIndex(x => x.BatchTestID == t.BatchTestID);
                    if (recordIndex >= 0)
                        LaboratoryService.Batches[recordIndex] = t;
                }

            if (LaboratoryService.Batches != null)
                LaboratoryService.Batches =
                    LaboratoryService.Batches.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        private void ApplyPendingSaveRecordsToSearchList()
        {
            if (LaboratoryService.PendingSaveBatches == null || !LaboratoryService.PendingSaveBatches.Any()) return;
            foreach (var t in LaboratoryService.PendingSaveBatches)
                if (LaboratoryService.SearchBatches != null &&
                    LaboratoryService.SearchBatches.All(x => x.BatchTestID != t.BatchTestID))
                {
                    LaboratoryService.SearchBatches?.Add(t);
                }
                else
                {
                    if (LaboratoryService.SearchBatches == null) continue;
                    var recordIndex = LaboratoryService.SearchBatches.ToList()
                        .FindIndex(x => x.BatchTestID == t.BatchTestID);
                    if (recordIndex >= 0)
                        LaboratoryService.SearchBatches[recordIndex] = t;
                }

            if (LaboratoryService.SearchBatches != null)
                LaboratoryService.SearchBatches =
                    LaboratoryService.SearchBatches.OrderByDescending(x => x.RowAction).ToList();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task SortPendingSave()
        {
            await BatchesGrid.Reload();
            await BatchesGrid.FirstPage();
            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
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
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.SearchReturnedTooManyResultsMessage)
                }
            };
            var dialogOptions = new DialogOptions
            {
                ShowTitle = false,
                ShowClose = false
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Empty, dialogParams, dialogOptions);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                //search timed out, narrow search criteria
                _source?.Cancel();
                _source = new CancellationTokenSource();
                _token = _source.Token;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        protected void OnRowRender(RowRenderEventArgs<BatchesGetListViewModel> record)
        {
            try
            {
                var cssClass = record.Data.RowAction switch
                {
                    (int) RowActionTypeEnum.Insert => LaboratoryModuleCSSClassConstants.SavePending,
                    (int) RowActionTypeEnum.Update => LaboratoryModuleCSSClassConstants.SavePending,
                    _ => LaboratoryModuleCSSClassConstants.NoSavePending
                };

                record.Attributes.Add("class", cssClass);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        protected void OnCellRender(DataGridCellRenderEventArgs<BatchesGetListViewModel> record)
        {
            try
            {
                var style = Empty;

                style += LaboratoryModuleCSSClassConstants.AccessionedCell;

                record.Attributes.Add("style", style);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="batch"></param>
        /// <returns></returns>
        protected async Task OnEditBatch(BatchesGetListViewModel batch)
        {
            try
            {
                if (LaboratoryService.Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests == null ||
                    !LaboratoryService.Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests.Any())
                    await GetTestsByBatchTestId(batch);

                var result = await DiagService.OpenAsync<CreateBatch>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryBatchResultsDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {
                            "SelectedTests",
                            LaboratoryService.Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests
                        },
                        {"LaboratoryModuleAction", (int) LaboratoryModuleActions.EditBatch},
                        {"Batch", batch}
                    },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.CreateBatchDialog,
                        CloseDialogOnOverlayClick = false,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await BatchEvent.InvokeAsync();

                    await OnRefreshBatches();
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
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (Batches is null)
                    return false;

                if (LaboratoryService.SelectedBatches is {Count: > 0})
                    if (Batches.Any(item =>
                            LaboratoryService.SelectedBatches.Any(x => x.BatchTestID == item.BatchTestID)))
                        return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="batch"></param>
        /// <returns></returns>
        protected bool IsTestHeaderRecordSelected(BatchesGetListViewModel batch)
        {
            try
            {
                if (Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests is null)
                    return false;

                if (LaboratoryService.SelectedBatchTests is {Count: > 0})
                    if (Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests.Any(item =>
                            LaboratoryService.SelectedBatchTests.Any(x => x.TestID == item.TestID)))
                        return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected async Task HeaderRecordSelectionChange(bool? value)
        {
            try
            {
                LaboratoryService.SelectedBatches ??= new List<BatchesGetListViewModel>();

                if (value == false)
                    foreach (var item in Batches)
                    {
                        if (LaboratoryService.SelectedBatches.All(x => x.BatchTestID != item.BatchTestID)) continue;
                        {
                            var selected =
                                LaboratoryService.SelectedBatches.First(x => x.BatchTestID == item.BatchTestID);
                            LaboratoryService.SelectedBatches.Remove(selected);
                        }
                    }
                else
                {
                    IsLoading = true;
                    foreach (var item in Batches)
                    {
                        LaboratoryService.SelectedBatches.Add(item);

                        if (item.Tests is not null && item.Tests.Any()) continue;
                        var tests = await GetTestsByBatchTestId(item);
                        if (LaboratoryService.SelectedBatches.Any(x => x.BatchTestID == item.BatchTestID))
                            LaboratoryService.SelectedBatches.First(x => x.BatchTestID == item.BatchTestID).Tests =
                                tests;
                    }
                    IsLoading = false;
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
        /// <param name="value"></param>
        /// <param name="batch"></param>
        protected void TestHeaderRecordSelectionChange(bool? value, BatchesGetListViewModel batch)
        {
            try
            {
                if (value == false)
                    foreach (var test in Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests.Where(test =>
                                 LaboratoryService.SelectedBatchTests.Any(x => x.TestID == test.TestID)))
                        LaboratoryService.SelectedBatchTests.Remove(test);
                else
                    foreach (var item in Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests)
                        LaboratoryService.SelectedBatchTests.Add(item);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsRecordSelected(BatchesGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedBatches != null &&
                    LaboratoryService.SelectedBatches.Any(x => x.BatchTestID == item.BatchTestID))
                    return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsTestRecordSelected(TestingGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.SelectedBatchTests != null &&
                    LaboratoryService.SelectedBatchTests.Any(x => x.TestID == item.TestID))
                    return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected async Task RecordSelectionChange(bool? value, BatchesGetListViewModel item)
        {
            try
            {
                LaboratoryService.SelectedBatches ??= new List<BatchesGetListViewModel>();

                if (value == false)
                {
                    item = LaboratoryService.SelectedBatches.First(x => x.BatchTestID == item.BatchTestID);

                    LaboratoryService.SelectedBatches.Remove(item);
                }
                else
                {
                    LaboratoryService.SelectedBatches.Add(item);

                    if (item.Tests is null || !item.Tests.Any())
                    {
                        var tests = await GetTestsByBatchTestId(item);

                        LaboratoryService.SelectedBatches.First(x => x.BatchTestID == item.BatchTestID).Tests = tests;
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
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected void TestRecordSelectionChange(bool? value, TestingGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = LaboratoryService.SelectedBatchTests.First(x => x.TestID == item.TestID);

                    LaboratoryService.SelectedBatchTests.Remove(item);
                }
                else
                {
                    LaboratoryService.SelectedBatchTests.Add(item);
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
        /// <param name="record"></param>
        protected void OnTestRowRender(RowRenderEventArgs<TestingGetListViewModel> record)
        {
            try
            {
                var cssClass = Empty;

                if (record.Data.ActionPerformedIndicator)
                    cssClass = record.Data.RowAction switch
                    {
                        (int) RowActionTypeEnum.Update => LaboratoryModuleCSSClassConstants.SavePending,
                        _ => LaboratoryModuleCSSClassConstants.NoSavePending
                    };

                record.Attributes.Add("class", cssClass);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="batch"></param>
        /// <returns></returns>
        public async Task OnRowExpand(BatchesGetListViewModel batch)
        {
            try
            {
                IsTestsLoading = true;
                await GetTestsByBatchTestId(batch);
                await GetTestResultTypes();
                await GetTestCategoryTypes();
                IsTestsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        protected override void OnAfterRender(bool firstRender)
        {
            if (firstRender)
                if (Batches != null)
                {
                    BatchesGrid.ExpandRow(Batches.FirstOrDefault());
                    StateHasChanged();
                }

            base.OnAfterRender(firstRender);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRefreshBatches()
        {
            IsReload = true;

            LaboratoryService.SelectedBatches ??= new List<BatchesGetListViewModel>();

            LaboratoryService.SelectedBatches.Clear();

            await BatchesGrid.FirstPage(true);

            await JsRuntime.InvokeVoidAsync(ScrollToTopJs, _token);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnReloadBatches()
        {
            try
            {
                IsLoading = true;

                await SaveEvent.InvokeAsync();

                await BatchesGrid.Reload();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="batch"></param>
        /// <returns></returns>
        private async Task<List<TestingGetListViewModel>> GetTestsByBatchTestId(BatchesGetListViewModel batch)
        {
            try
            {
                if (batch.Tests is not null && batch.Tests.Any()) return new List<TestingGetListViewModel>();
                var request = new TestingGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "EIDSSLaboratorySampleID",
                    SortOrder = SortConstants.Descending,
                    BatchTestID = batch.BatchTestID,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                    UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    UserOrganizationID = authenticatedUser.OfficeId,
                    UserSiteID = Convert.ToInt64(authenticatedUser.SiteId)
                };
                Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests =
                    await LaboratoryClient.GetTestingList(request, _token);

                for (var index = 0;
                     index < Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests.Count;
                     index++)
                    if (LaboratoryService.PendingSaveTesting != null &&
                        LaboratoryService.PendingSaveTesting.Any(x =>
                            x.TestID == Batches.First(y => y.BatchTestID == batch.BatchTestID)
                                .Tests[index].TestID))
                        Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests[index] =
                            LaboratoryService.PendingSaveTesting.First(x =>
                                x.TestID == Batches.First(y => y.BatchTestID == batch.BatchTestID)
                                    .Tests[index].TestID);

                return Batches.First(x => x.BatchTestID == batch.BatchTestID).Tests;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnTestStatusDropDownChange(TestingGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests is null ||
                    LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests
                        .All(x => x.TestID != item.TestID))
                    if (item.BatchTestID != null)
                        await GetTestsByBatchTestId(new BatchesGetListViewModel
                            {BatchTestID = (long) item.BatchTestID});

                if (LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests != null)
                {
                    var test = LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests
                        .First(x => x.TestID == item.TestID);

                    switch (item.TestStatusTypeID)
                    {
                        case (long) TestStatusTypeEnum.InProgress:
                            test.ResultDate = null;
                            test.ResultEnteredByOrganizationID = null;
                            test.ResultEnteredByPersonID = null;
                            test.ResultEnteredByPersonName = null;
                            test.TestResultTypeID = null;
                            break;

                        case (long) TestStatusTypeEnum.Preliminary:
                            test.ResultDate = item.ResultDate ?? DateTime.Now;
                            test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                            test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                            test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                             (IsNullOrEmpty(authenticatedUser.FirstName)
                                                                 ? ""
                                                                 : ", " + authenticatedUser.FirstName);
                            test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                                x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).IdfsBaseReference;
                            break;
                    }

                    test.ActionPerformedIndicator = true;

                    TogglePendingSaveTesting(test);

                    await SortPendingSave();
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
        /// <param name="item"></param>
        protected async Task OnTestResultDropDownChange(TestingGetListViewModel item)
        {
            try
            {
                if (LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests is null ||
                    LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests
                        .All(x => x.TestID != item.TestID))
                    if (item.BatchTestID != null)
                        await GetTestsByBatchTestId(new BatchesGetListViewModel
                            {BatchTestID = (long) item.BatchTestID});

                if (LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests != null)
                {
                    var test = LaboratoryService.Batches.First(x => x.BatchTestID == item.BatchTestID).Tests
                        .First(x => x.TestID == item.TestID);

                    if (item.TestResultTypeID is null)
                    {
                        test.ResultDate = null;
                        test.ResultEnteredByOrganizationID = null;
                        test.ResultEnteredByPersonID = null;
                        test.ResultEnteredByPersonName = null;
                        test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                            x.IdfsBaseReference == (long) TestStatusTypeEnum.InProgress).IdfsBaseReference;
                        test.TestResultTypeID = null;
                    }
                    else
                    {
                        test.ResultDate = item.ResultDate ?? DateTime.Now;
                        test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                        test.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                        test.ResultEnteredByPersonName = authenticatedUser.LastName +
                                                         (IsNullOrEmpty(authenticatedUser.FirstName)
                                                             ? ""
                                                             : ", " + authenticatedUser.FirstName);
                        test.TestStatusTypeID = LaboratoryService.TestStatusTypes.First(x =>
                            x.IdfsBaseReference == (long) TestStatusTypeEnum.Preliminary).IdfsBaseReference;
                        test.TestResultTypeID = item.TestResultTypeID;
                    }

                    test.ActionPerformedIndicator = true;

                    TogglePendingSaveTesting(test);

                    await SortPendingSave();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Test Event

        /// <summary>
        /// </summary>
        /// <param name="test"></param>
        /// <returns></returns>
        protected async Task OnEditTest(TestingGetListViewModel test)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryDetails>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Tab", LaboratoryTabEnum.Testing}, {"SampleId", test.SampleID}, {"TestId", test.TestID},
                        {"DiseaseId", test.DiseaseID.ToString()}
                    },
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                if (result is DialogReturnResult)
                    await OnRefreshBatches();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Search Events

        /// <summary>
        ///     LUC13 - Search for a Sample - Advanced Search
        /// </summary>
        /// <param name="simpleSearchString"></param>
        /// <returns></returns>
        protected async Task OnSimpleSearch(string simpleSearchString)
        {
            try
            {
                var result = await DiagService.OpenAsync<AddSampleToBatch>(
                    Localizer.GetString(HeadingResourceKeyConstants.BatchesAddSampleToBatchHeading),
                    new Dictionary<string, object>
                    {
                        {"SearchString", simpleSearchString},
                        {"Batch", LaboratoryService.SelectedBatches.FirstOrDefault()}
                    },
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    DiagService.Close(result);

                    LaboratoryService.Batches ??= new List<BatchesGetListViewModel>();
                    LaboratoryService.SelectedBatches ??= new List<BatchesGetListViewModel>();
                    if (LaboratoryService.SelectedBatches.Any())
                        if (LaboratoryService.Batches
                                .First(x => x.BatchTestID == LaboratoryService.SelectedBatches.First().BatchTestID)
                                .Tests is null || !LaboratoryService.Batches
                                .First(x => x.BatchTestID == LaboratoryService.SelectedBatches.First().BatchTestID)
                                .Tests.Any())
                            await GetTestsByBatchTestId(LaboratoryService.Batches
                                .First(x => x.BatchTestID == LaboratoryService.SelectedBatches.First().BatchTestID));

                    LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();
                    foreach (var test in LaboratoryService.PendingSaveTesting)
                    {
                        test.ActionPerformedIndicator = true;
                        LaboratoryService.Batches.First(x => x.BatchTestID == test.BatchTestID).Tests.Add(test);
                        LaboratoryService.Batches.First(x => x.BatchTestID == test.BatchTestID).RowAction =
                            (int) RowActionTypeEnum.Update;
                    }

                    await SaveEvent.InvokeAsync();

                    LaboratoryService.SelectedBatches.Clear();

                    if (TestsGrid != null)
                        await TestsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        ///     LUC13 - Search for a Sample - Advanced Search
        /// </summary>
        /// <param name="searchCriteria"></param>
        /// <returns></returns>
        protected async Task OnAdvancedSearch(AdvancedSearchGetRequestModel searchCriteria)
        {
            IsLoading = true;
            IsAdvancedSearch = true;
            AdvancedSearchCriteria = searchCriteria;

            await BatchesGrid.FirstPage(true);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearSearch()
        {
            IsAdvancedSearch = false;
            AdvancedSearchCriteria = new AdvancedSearchGetRequestModel();
            LaboratoryService.SearchBatches = null;

            await BatchesGrid.FirstPage(true);
            await ClearSearchEvent.InvokeAsync(Count);
        }

        #endregion

        #region Set My Favorite Event

        /// <summary>
        /// </summary>
        /// <param name="batchTest"></param>
        /// <returns></returns>
        protected async Task OnSetMyFavorite(TestingGetListViewModel batchTest)
        {
            try
            {
                await SetMyFavorite(batchTest.SampleID, null, null);
                await SetMyFavoriteEvent.InvokeAsync();

                LaboratoryService.SelectedBatches ??= new List<BatchesGetListViewModel>();
                LaboratoryService.SelectedBatches.Clear();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Validate Test Result Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnValidateTestResult()
        {
            await BatchesGrid.Reload();
            await SortPendingSave();
        }

        #endregion

        #endregion
    }
}