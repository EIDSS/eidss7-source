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
    public class PensideTestsSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<PensideTestsSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<PensideTestGetListViewModel> PensideTestsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        public bool AvianReportTypeIndicator { get; set; }
        public string SectionHeadingResourceKey { get; set; }
        public string DetailsHeadingResourceKey { get; set; }
        public string TestNameColumnHeadingResourceKey { get; set; }
        public string FieldSampleIdColumnHeadingResourceKey { get; set; }
        public string SampleTypeColumnHeadingResourceKey { get; set; }
        public string SpeciesColumnHeadingResourceKey { get; set; }
        public string AnimalIdColumnHeadingResourceKey { get; set; }
        public string ResultColumnHeadingResourceKey { get; set; }

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

        private const string DefaultSortColumn = "PensideTestNameTypeName";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public PensideTestsSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected PensideTestsSectionBase() : base(CancellationToken.None)
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

            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                AvianReportTypeIndicator = true;
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportPensideTestsHeading);
                DetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportPensideTestDetailsModalHeading);
                TestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsTestNameColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsFieldSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsSampleTypeColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsSpeciesColumnHeading);
                ResultColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportPensideTestsResultColumnHeading);
            }
            else
            {
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportPensideTestsHeading);
                DetailsHeadingResourceKey =
                    Localizer.GetString(
                        HeadingResourceKeyConstants.LivestockDiseaseReportPensideTestDetailsModalHeading);
                TestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsTestNameColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsFieldSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsSampleTypeColumnHeading);
                AnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsAnimalIDColumnHeading);
                ResultColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportPensideTestsResultColumnHeading);
            }

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

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~PensideTestsSectionBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
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

                await JsRuntime
                    .InvokeVoidAsync("PensideTestsSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this)).ConfigureAwait(false);
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadPensideTestData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (PensideTestsGrid.PageSize != 0)
                    pageSize = PensideTestsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.PensideTests is null ||
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

                        Model.PensideTests =
                            await GetPensideTests(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                                .ConfigureAwait(false);
                        if (page == 1)
                            _databaseQueryCount = !Model.PensideTests.Any() ? 0 : Model.PensideTests.First().TotalRowCount;
                    }
                    else if (Model.PensideTests != null)
                    {
                        _databaseQueryCount = Model.PensideTests.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.PensideTestID < 0)
                            ? 0
                            : Model.PensideTests.First(x => x.PensideTestID > 0).TotalRowCount;
                    }

                    if (Model.PensideTests != null)
                        for (var index = 0; index < Model.PensideTests.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.PensideTests[index].PensideTestID < 0)
                            {
                                Model.PensideTests.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSavePensideTests == null || index < 0 || Model.PensideTests.Count == 0 ||
                                Model.PendingSavePensideTests.All(x =>
                                    x.PensideTestID != Model.PensideTests[index].PensideTestID)) continue;
                            {
                                if (Model.PendingSavePensideTests
                                        .First(x => x.PensideTestID == Model.PensideTests[index].PensideTestID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.PensideTests.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.PensideTests[index] = Model.PendingSavePensideTests.First(x =>
                                        x.PensideTestID == Model.PensideTests[index].PensideTestID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSavePensideTests != null &&
                            Model.PendingSavePensideTests.Any(x => x.PensideTestID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSavePensideTests.Where(x => x.PensideTestID < 0).ToList();
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
                                Model.PensideTests?.Clear();
                            }
                            else
                            {
                                Model.PensideTests?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.PensideTests?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.PensideTests != null)
                            Model.PensideTests = Model.PensideTests.AsQueryable()
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
        protected void TogglePendingSavePensideTests(PensideTestGetListViewModel record,
            PensideTestGetListViewModel originalRecord)
        {
            Model.PendingSavePensideTests ??= new List<PensideTestGetListViewModel>();

            if (Model.PendingSavePensideTests.Any(x => x.PensideTestID == record.PensideTestID))
            {
                var index = Model.PendingSavePensideTests.IndexOf(originalRecord);
                Model.PendingSavePensideTests[index] = record;
            }
            else
            {
                Model.PendingSavePensideTests.Add(record);
            }
        }

        #endregion

        #region Add Penside Test Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddPensideTestClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<PensideTest>(Localizer.GetString(DetailsHeadingResourceKey),
                    new Dictionary<string, object>
                        {{"Model", new PensideTestGetListViewModel()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is PensideTestGetListViewModel model)
                {
                    _newRecordCount += 1;

                    TogglePendingSavePensideTests(model, null);

                    await PensideTestsGrid.Reload().ConfigureAwait(false);
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

        #region Edit Penside Test Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="pensideTest"></param>
        protected async Task OnEditPensideTestClick(object pensideTest)
        {
            try
            {
                var result = await DiagService.OpenAsync<PensideTest>(Localizer.GetString(DetailsHeadingResourceKey),
                    new Dictionary<string, object>
                    {
                        {"Model", ((PensideTestGetListViewModel) pensideTest).ShallowCopy()}, {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is PensideTestGetListViewModel model)
                {
                    if (Model.PensideTests.Any(x =>
                            x.PensideTestID == ((PensideTestGetListViewModel) result).PensideTestID))
                    {
                        var index = Model.PensideTests.IndexOf((PensideTestGetListViewModel) pensideTest);
                        Model.PensideTests[index] = model;

                        TogglePendingSavePensideTests(model, (PensideTestGetListViewModel) pensideTest);
                    }

                    await PensideTestsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Penside Test Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="pensideTest"></param>
        protected async Task OnDeletePensideTestClick(object pensideTest)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.PensideTests.Any(x =>
                                x.PensideTestID == ((PensideTestGetListViewModel) pensideTest).PensideTestID))
                        {
                            if (((PensideTestGetListViewModel) pensideTest).PensideTestID <= 0)
                            {
                                Model.PensideTests.Remove((PensideTestGetListViewModel) pensideTest);
                                Model.PendingSavePensideTests.Remove((PensideTestGetListViewModel) pensideTest);
                                _newRecordCount--;
                            }
                            else
                            {
                                result = ((PensideTestGetListViewModel) pensideTest).ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                Model.PensideTests.Remove((PensideTestGetListViewModel) pensideTest);

                                TogglePendingSavePensideTests(result, (PensideTestGetListViewModel) pensideTest);
                            }
                        }

                        await PensideTestsGrid.Reload().ConfigureAwait(false);

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
            Model.PensideTests = null;
            PensideTestsGrid.Reload();
        }

        #endregion

        #endregion
    }
}