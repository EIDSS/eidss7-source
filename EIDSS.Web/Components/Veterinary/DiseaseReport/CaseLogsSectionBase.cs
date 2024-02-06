#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class CaseLogsSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CaseLogsSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<CaseLogGetListViewModel> CaseLogsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private int _databaseQueryCount;
        private int _newRecordCount;
        private int _lastDatabasePage;
        private int _lastPage = 1;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "LogDate";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public CaseLogsSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected CaseLogsSectionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            _disposedValue = true;
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                IsLoading = true;

                await JsRuntime.InvokeVoidAsync("CaseLogsSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadCaseLogData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (CaseLogsGrid.PageSize != 0)
                    pageSize = CaseLogsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.CaseLogs is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
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

                        Model.CaseLogs =
                            await GetCaseLogs(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                                .ConfigureAwait(false);
                        if (page == 1)
                            _databaseQueryCount = !Model.CaseLogs.Any() ? 0 : Model.CaseLogs.First().TotalRowCount;
                    }
                    else if (Model.CaseLogs != null)
                    {
                        _databaseQueryCount = Model.CaseLogs.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.DiseaseReportLogID < 0)
                            ? 0
                            : Model.CaseLogs.First(x => x.DiseaseReportLogID > 0).TotalRowCount;
                    }

                    if (Model.CaseLogs != null)
                        for (var index = 0; index < Model.CaseLogs.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.CaseLogs[index].DiseaseReportLogID < 0)
                            {
                                Model.CaseLogs.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveCaseLogs == null || index < 0 || Model.CaseLogs.Count == 0 ||
                                Model.PendingSaveCaseLogs.All(x =>
                                    x.DiseaseReportLogID != Model.CaseLogs[index].DiseaseReportLogID)) continue;
                            {
                                if (Model.PendingSaveCaseLogs
                                        .First(x => x.DiseaseReportLogID == Model.CaseLogs[index].DiseaseReportLogID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.CaseLogs.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.CaseLogs[index] = Model.PendingSaveCaseLogs.First(x =>
                                        x.DiseaseReportLogID == Model.CaseLogs[index].DiseaseReportLogID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveCaseLogs != null &&
                            Model.PendingSaveCaseLogs.Any(x => x.DiseaseReportLogID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveCaseLogs.Where(x => x.DiseaseReportLogID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _lastDatabasePage;
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
                                Model.CaseLogs?.Clear();
                            }
                            else
                            {
                                Model.CaseLogs?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.CaseLogs?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.CaseLogs != null)
                            Model.CaseLogs = Model.CaseLogs.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _lastPage = page;
                }

                IsLoading = false;
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
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveCaseLogs(CaseLogGetListViewModel record, CaseLogGetListViewModel originalRecord)
        {
            Model.PendingSaveCaseLogs ??= new List<CaseLogGetListViewModel>();

            if (Model.PendingSaveCaseLogs.Any(x => x.DiseaseReportLogID == record.DiseaseReportLogID))
            {
                var index = Model.PendingSaveCaseLogs.IndexOf(originalRecord);
                Model.PendingSaveCaseLogs[index] = record;
            }
            else
            {
                Model.PendingSaveCaseLogs.Add(record);
            }
        }

        #endregion

        #region Add Case Log Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddCaseLogClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<CaseLog>(
                    Localizer.GetString(HeadingResourceKeyConstants.CaseLogDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {
                            "Model",
                            new CaseLogGetListViewModel
                            {
                                LogDate = DateTime.Now, EnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                                LogStatusTypeID = (long) CaseLogStatusTypeEnum.Open
                            }
                        },
                        {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is CaseLogGetListViewModel model)
                {
                    _newRecordCount += 1;

                    Model.CaseLogs.Add(model);

                    TogglePendingSaveCaseLogs(model, null);

                    await CaseLogsGrid.Reload();
                }
                else
                {
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Case Log Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="caseLog"></param>
        protected async Task OnEditCaseLogClick(object caseLog)
        {
            try
            {
                var result = await DiagService.OpenAsync<CaseLog>(
                    Localizer.GetString(HeadingResourceKeyConstants.CaseLogDetailsModalHeading),
                    new Dictionary<string, object>
                        {{"Model", ((CaseLogGetListViewModel) caseLog).ShallowCopy()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is CaseLogGetListViewModel model)
                {
                    if (Model.CaseLogs.Any(x =>
                            x.DiseaseReportLogID == ((CaseLogGetListViewModel) result).DiseaseReportLogID))
                    {
                        var index = Model.CaseLogs.IndexOf((CaseLogGetListViewModel) caseLog);
                        Model.CaseLogs[index] = model;

                        TogglePendingSaveCaseLogs(model, (CaseLogGetListViewModel) caseLog);
                    }

                    await CaseLogsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Case Log Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="caseLog"></param>
        protected async Task OnDeleteCaseLogClick(object caseLog)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.CaseLogs.Any(x =>
                                x.DiseaseReportLogID == ((CaseLogGetListViewModel) caseLog).DiseaseReportLogID))
                        {
                            if (((CaseLogGetListViewModel) caseLog).DiseaseReportLogID <= 0)
                            {
                                Model.CaseLogs.Remove((CaseLogGetListViewModel) caseLog);
                                Model.PendingSaveCaseLogs.Remove((CaseLogGetListViewModel) caseLog);
                                _newRecordCount--;
                            }
                            else
                            {
                                result = ((CaseLogGetListViewModel) caseLog).ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                Model.CaseLogs.Remove((CaseLogGetListViewModel) caseLog);
                                Count--;

                                TogglePendingSaveCaseLogs(result, (CaseLogGetListViewModel) caseLog);
                            }
                        }

                        await CaseLogsGrid.Reload().ConfigureAwait(false);

                        DiagService.Close(result);
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.CaseLogs = null;
            CaseLogsGrid.Reload();
        }

        #endregion

        #endregion
    }
}