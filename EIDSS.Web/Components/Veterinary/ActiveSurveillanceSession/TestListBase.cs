using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class TestListBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ILogger<TestListBase> Logger { get; set; }

        [Inject]
        private IHttpClientFactory HttpClientFactory { get; set; }

        #endregion Dependencies

        #region Member Variables

        protected RadzenDataGrid<LaboratoryTestGetListViewModel> TestGrid;
        protected RadzenDataGrid<LaboratoryTestInterpretationGetListViewModel> InterpretationsGrid;
        protected List<LaboratoryTestGetListViewModel> SelectedTests;
        protected List<LaboratoryTestInterpretationGetListViewModel> SelectedInterpretations;
        protected bool IsLoading;
        protected int TestsCount;
        protected int InterpretationsCount;

        private int _testsNewRecordCount;
        private int _testsDatabaseQueryCount;
        private int _testsLastDatabasePage;
        private int _testsLastPage = 1;
        private int _previousTestsPageSize;
        private int _interpretationsNewRecordCount;
        private int _interpretationsDatabaseQueryCount;
        private int _interpretationsLastDatabasePage;
        private int _interpretationsLastPage = 1;
        private int _previousInterpretationsPageSize;
        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposed;
        private bool _shouldRender = true;

        #endregion Member Variables

        #region Constants

        private const string DefaultTestSortColumn = "ResultDate";
        private const string DefaultInterpretationSortColumn = "InterpretedDate";

        #endregion Constants

        #endregion Globals

        #region Methods

        #region Lifecyle Methods

        protected override void OnInitialized()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            base.OnInitialized();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);

                await JsRuntime.InvokeVoidAsync("VetSurveillanceTestsSection.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override bool ShouldRender()
        {
            return _shouldRender;
        }

        /// <summary>
        /// Cancel any background tasks
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }
                _disposed = true;
            }

            base.Dispose(disposing);
        }

        #endregion Lifecyle Methods

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
                var pageSize = 10;
                string sortColumn = DefaultTestSortColumn,
                    sortOrder = SortConstants.Descending;

                if (TestGrid.PageSize != 0)
                    pageSize = TestGrid.PageSize;

                if (_previousTestsPageSize != pageSize)
                    IsLoading = true;

                _previousTestsPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.Tests is not { Count: > 0 } ||
                        _testsLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
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

                        var request = new LaboratoryTestGetListRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder
                        };

                        StateContainer.Tests = await VeterinaryClient.GetActiveSurveillanceSessionTestsListAsync(request, _token);
                        if (page == 1)
                            _testsDatabaseQueryCount = StateContainer.Tests.Any(x => x.TestID > 0 || x.RowStatus is not (int)RowStatusTypeEnum.Inactive)
                                ? StateContainer.Tests.First(x => x.TestID > 0
                                    || x.RowStatus is not (int)RowStatusTypeEnum.Inactive).TotalRowCount
                                : 0;
                    }
                    else if (StateContainer.Tests != null)
                    {
                        _testsDatabaseQueryCount = StateContainer.Tests.Any(x => x.TestID > 0 || x.RowStatus is not (int)RowStatusTypeEnum.Inactive)
                            ? StateContainer.Tests.First(x => x.TestID > 0
                                || x.RowStatus is not (int)RowStatusTypeEnum.Inactive).TotalRowCount
                            : 0;
                    }
                    else
                    {
                        StateContainer.Tests = new List<LaboratoryTestGetListViewModel>();
                    }

                    if (StateContainer.Tests != null)
                        for (var index = 0; index < StateContainer.Tests.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.Tests[index].TestID < 0)
                            {
                                StateContainer.Tests.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveTests == null || index < 0 || StateContainer.Tests.Count == 0 ||
                                StateContainer.PendingSaveTests.All(x =>
                                    x.TestID != StateContainer.Tests[index].TestID)) continue;
                            {
                                if (StateContainer.PendingSaveTests
                                        .First(x => x.TestID == StateContainer.Tests[index].TestID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.Tests.RemoveAt(index);
                                    _testsDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.Tests[index] = StateContainer.PendingSaveTests.First(x =>
                                        x.TestID == StateContainer.Tests[index].TestID);
                                }
                            }
                        }

                    TestsCount = _testsDatabaseQueryCount + _testsNewRecordCount;

                    if (_testsNewRecordCount > 0)
                    {
                        _testsLastDatabasePage = Math.DivRem(_testsDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _testsLastDatabasePage == 0)
                            _testsLastDatabasePage += 1;

                        if (page >= _testsLastDatabasePage && StateContainer.PendingSaveTests != null &&
                            StateContainer.PendingSaveTests.Any(x => x.TestID < 0))
                        {
                            var newRecordsPendingSave =
                               StateContainer.PendingSaveTests.Where(x => x.TestID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _testsLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(TestsCount, pageSize, out var remainderNewRecords);

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
                                StateContainer.Tests?.Clear();
                            }
                            else
                            {
                                StateContainer.Tests?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.Tests?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (StateContainer.Tests != null)
                            StateContainer.Tests = StateContainer.Tests.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _testsLastPage = page;
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
        ///
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadTestInterpretationsGrid(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultInterpretationSortColumn,
                    sortOrder = SortConstants.Descending;

                if (InterpretationsGrid.PageSize != 0)
                    pageSize = InterpretationsGrid.PageSize;

                if (_previousInterpretationsPageSize != pageSize)
                    IsLoading = true;

                _previousInterpretationsPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.TestInterpretations is not { Count: > 0 } ||
                        _interpretationsLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
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

                        var request = new LaboratoryTestInterpretationGetListRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder
                        };

                        StateContainer.TestInterpretations = await VeterinaryClient.GetLaboratoryTestInterpretationList(request, _token);
                        if (page == 1)
                            _interpretationsDatabaseQueryCount = StateContainer.TestInterpretations.Any(x => x.TestInterpretationID > 0 || x.RowStatus is not (int)RowStatusTypeEnum.Inactive)
                                ? StateContainer.TestInterpretations.First(x => x.TestInterpretationID > 0
                                    || x.RowStatus is not (int)RowStatusTypeEnum.Inactive).TotalRowCount
                                : 0;
                    }
                    else if (StateContainer.TestInterpretations != null)
                    {
                        _interpretationsDatabaseQueryCount = StateContainer.TestInterpretations.Any(x => x.TestInterpretationID > 0 || x.RowStatus is not (int)RowStatusTypeEnum.Inactive)
                            ? StateContainer.TestInterpretations.First(x => x.TestInterpretationID > 0
                                || x.RowStatus is not (int)RowStatusTypeEnum.Inactive).TotalRowCount
                            : 0;
                    }
                    else
                    {
                        StateContainer.TestInterpretations = new List<LaboratoryTestInterpretationGetListViewModel>();
                    }

                    if (StateContainer.TestInterpretations != null)
                        for (var index = 0; index < StateContainer.TestInterpretations.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.TestInterpretations[index].TestInterpretationID < 0)
                            {
                                StateContainer.TestInterpretations.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveTestInterpretations == null || index < 0 || StateContainer.TestInterpretations.Count == 0 ||
                                StateContainer.PendingSaveTestInterpretations.All(x =>
                                    x.TestInterpretationID != StateContainer.TestInterpretations[index].TestInterpretationID)) continue;
                            {
                                if (StateContainer.PendingSaveTestInterpretations
                                        .First(x => x.TestInterpretationID == StateContainer.TestInterpretations[index].TestInterpretationID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.TestInterpretations.RemoveAt(index);
                                    _interpretationsDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.TestInterpretations[index] = StateContainer.PendingSaveTestInterpretations.First(x =>
                                        x.TestInterpretationID == StateContainer.TestInterpretations[index].TestInterpretationID);
                                }
                            }
                        }

                    InterpretationsCount = _interpretationsDatabaseQueryCount + _interpretationsNewRecordCount;

                    if (_interpretationsNewRecordCount > 0)
                    {
                        _interpretationsLastDatabasePage = Math.DivRem(_interpretationsDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _interpretationsLastDatabasePage == 0)
                            _interpretationsLastDatabasePage += 1;

                        if (page >= _interpretationsLastDatabasePage && StateContainer.PendingSaveTestInterpretations != null &&
                            StateContainer.PendingSaveTestInterpretations.Any(x => x.TestInterpretationID < 0))
                        {
                            var newRecordsPendingSave =
                               StateContainer.PendingSaveTestInterpretations.Where(x => x.TestInterpretationID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _interpretationsLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(InterpretationsCount, pageSize, out var remainderNewRecords);

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
                                StateContainer.TestInterpretations?.Clear();
                            }
                            else
                            {
                                StateContainer.TestInterpretations?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.TestInterpretations?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (StateContainer.TestInterpretations != null)
                            StateContainer.TestInterpretations = StateContainer.TestInterpretations.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _interpretationsLastPage = page;
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
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveLaboratoryTestInterpretations(LaboratoryTestInterpretationGetListViewModel record, LaboratoryTestInterpretationGetListViewModel originalRecord)
        {
            StateContainer.PendingSaveTestInterpretations ??= new List<LaboratoryTestInterpretationGetListViewModel>();

            if (StateContainer.PendingSaveTestInterpretations.Any(x => x.TestInterpretationID == record.TestInterpretationID))
            {
                var index = StateContainer.PendingSaveTestInterpretations.IndexOf(originalRecord);
                StateContainer.PendingSaveTestInterpretations[index] = record;
            }
            else
            {
                StateContainer.PendingSaveTestInterpretations.Add(record);
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveTests(LaboratoryTestGetListViewModel record, LaboratoryTestGetListViewModel originalRecord)
        {
            StateContainer.PendingSaveTests ??= new List<LaboratoryTestGetListViewModel>();

            if (StateContainer.PendingSaveTests.Any(x => x.TestID == record.TestID))
            {
                var index = StateContainer.PendingSaveTests.IndexOf(originalRecord);
                StateContainer.PendingSaveTests[index] = record;
            }
            else
            {
                StateContainer.PendingSaveTests.Add(record);
            }
        }

        #endregion Load Data

        #region Interpretation Events

        protected async Task OnAddInterpretationClick()
        {
            try
            {
                StateContainer.InterpretationDetail = new LaboratoryTestInterpretationGetListViewModel();

                var result = await DiagService.OpenAsync<TestInterpretationModal>(Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionInterpretationDetailsModalHeading), new Dictionary<string, object>() { },
                    options: new DialogOptions()
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is LaboratoryTestInterpretationGetListViewModel)
                {
                    if (StateContainer.TestInterpretations.Any(x => x.TestInterpretationID == (result as LaboratoryTestInterpretationGetListViewModel).TestInterpretationID))
                    {
                        var index = StateContainer.TestInterpretations.IndexOf(result as LaboratoryTestInterpretationGetListViewModel);
                        StateContainer.TestInterpretations[index] = result as LaboratoryTestInterpretationGetListViewModel;

                        TogglePendingSaveLaboratoryTestInterpretations(result as LaboratoryTestInterpretationGetListViewModel, null);
                    }

                    await InterpretationsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnEditInterpretationClick(LaboratoryTestInterpretationGetListViewModel item)
        {
            try
            {
                StateContainer.InterpretationDetail = item;
                StateContainer.InterpretationDetail.CanInterpretTestResultPermissionIndicator = _tokenService.GerUserPermissions(ClientLibrary.Enumerations.PagePermission.CanInterpretVetDiseaseReportSessionTestResult).Execute;
                StateContainer.InterpretationDetail.CanValidateTestResultPermissionIndicator = _tokenService.GerUserPermissions(ClientLibrary.Enumerations.PagePermission.CanValidateTestVetResultInterpretation).Execute;

                dynamic result = await DiagService.OpenAsync<TestInterpretationModal>(Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionInterpretationDetailsModalHeading), new Dictionary<string, object>() { },
                    options: new DialogOptions() { Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true, CloseDialogOnOverlayClick = true, ShowClose = true });

                if (result is LaboratoryTestInterpretationGetListViewModel)
                {
                    if (StateContainer.TestInterpretations.Any(x => x.TestInterpretationID == (result as LaboratoryTestInterpretationGetListViewModel).TestInterpretationID))
                    {
                        var index = StateContainer.TestInterpretations.IndexOf(item as LaboratoryTestInterpretationGetListViewModel);
                        StateContainer.TestInterpretations[index] = result as LaboratoryTestInterpretationGetListViewModel;

                        TogglePendingSaveLaboratoryTestInterpretations(result as LaboratoryTestInterpretationGetListViewModel, item as LaboratoryTestInterpretationGetListViewModel);
                    }

                    await InterpretationsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnDeleteInterpretationClick(LaboratoryTestInterpretationGetListViewModel item)
        {
            try
            {
                dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult)
                {
                    if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (StateContainer.TestInterpretations.Any(x => x.TestInterpretationID == item.TestInterpretationID))
                        {
                            if (item.TestInterpretationID <= 0)
                            {
                                StateContainer.TestInterpretations.Remove(item);
                                StateContainer.PendingSaveTestInterpretations.Remove(item);
                                _interpretationsNewRecordCount--;
                            }
                            else
                            {
                                result = item.ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                StateContainer.TestInterpretations.Remove(item);
                                InterpretationsCount--;

                                TogglePendingSaveLaboratoryTestInterpretations(result, item);
                            }
                        }

                        await InterpretationsGrid.Reload();

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

        protected async Task OnDeleteSelectedInterpretationsClick()
        {
            try
            {
                if (SelectedInterpretations is { Count: > 0 })
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            foreach (var item in SelectedInterpretations)
                            {
                                if (StateContainer.TestInterpretations.Any(x => x.TestInterpretationID == item.TestInterpretationID))
                                {
                                    if (item.TestInterpretationID <= 0)
                                    {
                                        StateContainer.TestInterpretations.Remove(item);
                                        StateContainer.PendingSaveTestInterpretations.Remove(item);
                                        _interpretationsNewRecordCount--;
                                    }
                                    else
                                    {
                                        result = item.ShallowCopy();
                                        result.RowAction = (int)RowActionTypeEnum.Delete;
                                        result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                        StateContainer.TestInterpretations.Remove(item);
                                        InterpretationsCount--;

                                        TogglePendingSaveLaboratoryTestInterpretations(result, item);
                                    }
                                }
                            }

                            await InterpretationsGrid.Reload();

                            DiagService.Close(result);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnInterpretTestClick(LaboratoryTestGetListViewModel item)
        {
            try
            {
                StateContainer.TestInterpretations ??= new List<LaboratoryTestInterpretationGetListViewModel>();

                var interpretation = StateContainer.TestInterpretations.FirstOrDefault(x => x.TestID == item.TestID);
                if (interpretation is not null)
                {
                    StateContainer.InterpretationDetail = interpretation;
                }
                else
                {
                    interpretation = new LaboratoryTestInterpretationGetListViewModel()
                    {
                        AnimalID = item.AnimalID,
                        DiseaseID = item.DiseaseID,
                        DiseaseName = item.DiseaseName,
                        EIDSSAnimalID = item.EIDSSAnimalID,
                        EIDSSFarmID = item.EIDSSFarmID,
                        EIDSSLaboratorySampleID = item.EIDSSLaboratorySampleID,
                        EIDSSLocalOrFieldSampleID = item.EIDSSLocalOrFieldSampleID,
                        FarmID = item.FarmID,
                        FarmMasterID = item.FarmMasterID,
                        SampleID = item.SampleID,
                        SampleTypeName = item.SampleTypeName,
                        Species = item.Species,
                        SpeciesID = item.SpeciesID,
                        SpeciesTypeName = item.SpeciesTypeName,
                        TestCategoryTypeID = item.TestCategoryTypeID,
                        TestCategoryTypeName = item.TestCategoryTypeName,
                        TestID = item.TestID,
                        TestNameTypeID = item.TestNameTypeID,
                        TestNameTypeName = item.TestNameTypeName,
                        TestResultTypeID = item.TestResultTypeID,
                        TestResultTypeName = item.TestResultTypeName
                    };

                    StateContainer.InterpretationDetail = interpretation;
                }

                StateContainer.InterpretationDetail.CanInterpretTestResultPermissionIndicator = _tokenService.GerUserPermissions(ClientLibrary.Enumerations.PagePermission.CanInterpretVetDiseaseReportSessionTestResult).Execute;
                StateContainer.InterpretationDetail.CanValidateTestResultPermissionIndicator = _tokenService.GerUserPermissions(ClientLibrary.Enumerations.PagePermission.CanValidateTestVetResultInterpretation).Execute;

                var result = await DiagService.OpenAsync<TestInterpretationModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.TestTestResultDetailsModalHeading),
                    new Dictionary<string, object> { },
                    new DialogOptions
                    {
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result is LaboratoryTestInterpretationGetListViewModel model)
                {
                    StateContainer.TestInterpretations.Add(model);

                    _interpretationsNewRecordCount += 1;

                    TogglePendingSaveLaboratoryTestInterpretations(model, null);

                    await InterpretationsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnLinkDiseaseReportClick(LaboratoryTestInterpretationGetListViewModel item)
        {
            try
            {
                _shouldRender = false;

                // set the disease report created flag for this interpretation and save it
                if (StateContainer.TestInterpretations.Any(x => x.TestInterpretationID == item.TestInterpretationID))
                {
                    item.ReportSessionCreatedIndicator = true;
                    var index = StateContainer.TestInterpretations.IndexOf(item);
                    var original = StateContainer.TestInterpretations[index];
                    StateContainer.TestInterpretations[index] = original;

                    TogglePendingSaveLaboratoryTestInterpretations(original, item);
                }

                // validate session and save before jumping to disease report
                await JsRuntime.InvokeVoidAsync("validateSurveillanceSession", _token);

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                StateContainer.PendingSaveEvents ??= new List<EventSaveRequestModel>();
                if (StateContainer.SessionKey <= 0)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Convert.ToInt64(StateContainer.SiteID)
                        ? SystemEventLogTypes.NewVeterinaryActiveSurveillanceSessionWasCreatedAtYourSite
                        : SystemEventLogTypes.NewVeterinaryActiveSurveillanceSessionWasCreatedAtAnotherSite;
                    StateContainer.PendingSaveEvents.Add(await CreateEvent(StateContainer.SessionKey.GetValueOrDefault(),
                            null, eventTypeId, Convert.ToInt64(StateContainer.SiteID), null)
                        .ConfigureAwait(false));
                }

                var response = await SaveSurveillanceSession();

                if (response is { SessionKey: > 0 })
                {
                    var reportCategoryTypeId = StateContainer.ReportTypeID == ASSpeciesType.Livestock ? (long)CaseTypeEnum.Livestock : (long)CaseTypeEnum.Avian;
                    var path = $"Veterinary/VeterinaryDiseaseReport/Details" +
                               $"?reportTypeId={CaseReportType.Active}" +
                               $"&farmId={item.FarmMasterID}" +
                               $"&diseaseReportId={null}" +
                               $"&diseaseId={item.DiseaseID}" +
                               $"&isLinkedSurveillanceSession={true}" +
                               $"&sessionKey={response.SessionKey}" +
                               $"&sessionId={response.SessionID}" +
                               $"&reportCategoryTypeId={reportCategoryTypeId}" +
                               $"&sampleId={item.SampleID}";

                    var uri = $"{NavManager.BaseUri}{path}";

                    NavManager.NavigateTo(uri, true);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Interpretation Events

        #region Add Test Button Click Event

        protected async Task OnAddTestClick()
        {
            try
            {
                StateContainer.LaboratoryTestDetail = new LaboratoryTestGetListViewModel();

                dynamic result = await DiagService.OpenAsync<TestModal>(Localizer.GetString(HeadingResourceKeyConstants.TestDetailsModalHeading), new Dictionary<string, object>() { },
                    options: new DialogOptions()
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is LaboratoryTestGetListViewModel)
                {
                    _testsNewRecordCount += 1;

                    StateContainer.Tests.Add(result as LaboratoryTestGetListViewModel);

                    TogglePendingSaveTests(result as LaboratoryTestGetListViewModel, null);

                    await TestGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnPrintTestClick()
        {
            try
            {
                ReportViewModel reportModel = new();
                // common parameters
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                reportModel.AddParameter("UserFullName", authenticatedUser.UserName);
                reportModel.AddParameter("UserOrganization", authenticatedUser.OrganizationFullName);

                // specific parameters
                reportModel.AddParameter("ObjID", StateContainer.SessionKey.ToString());

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionTestsHeading),
                    new Dictionary<string, object> { { "ReportName", "ActiveSurveillanceSessionLabTests" }, { "Parameters", reportModel.Parameters } },
                    new DialogOptions
                    {
                        Style = ReportSessionTypeConstants.HumanDiseaseReport,
                        Left = "150",
                        Resizable = true,
                        Draggable = false,
                        Width = "1150px"
                    });
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
        protected async Task OnEditTestClick(LaboratoryTestGetListViewModel item)
        {
            try
            {
                StateContainer.LaboratoryTestDetail = item;

                dynamic result = await DiagService.OpenAsync<TestModal>(Localizer.GetString(HeadingResourceKeyConstants.TestDetailsModalHeading), new Dictionary<string, object>() { },
                    options: new DialogOptions()
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is LaboratoryTestGetListViewModel)
                {
                    if (StateContainer.Tests.Any(x => x.TestID == (result as LaboratoryTestGetListViewModel).TestID))
                    {
                        int index = StateContainer.Tests.IndexOf(item as LaboratoryTestGetListViewModel);
                        StateContainer.Tests[index] = result as LaboratoryTestGetListViewModel;

                        TogglePendingSaveTests(result as LaboratoryTestGetListViewModel, item as LaboratoryTestGetListViewModel);
                    }

                    await TestGrid.Reload();
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

        protected async Task OnDeleteTestClick(LaboratoryTestGetListViewModel item)
        {
            try
            {
                dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult)
                {
                    if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (StateContainer.Tests.Any(x => x.TestID == item.TestID))
                        {
                            if (item.TestID <= 0)
                            {
                                StateContainer.Tests.Remove(item);
                                StateContainer.PendingSaveTests.Remove(item);
                                _testsNewRecordCount--;
                            }
                            else
                            {
                                result = item.ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                StateContainer.Tests.Remove(item);
                                TestsCount--;

                                TogglePendingSaveTests(result, item);
                            }
                        }

                        await TestGrid.Reload();

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

        #region Delete Selected Tests

        protected async Task DeleteSelectedTestsClick()
        {
            try
            {
                if (SelectedTests is { Count: > 0 })
                {
                    dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            foreach (var item in SelectedTests)
                            {
                                if (StateContainer.Tests.Any(x => x.TestID == item.TestID))
                                {
                                    if (item.TestID <= 0)
                                    {
                                        StateContainer.Tests.Remove(item);
                                        StateContainer.PendingSaveTests.Remove(item);
                                        _testsNewRecordCount--;
                                    }
                                    else
                                    {
                                        result = item.ShallowCopy();
                                        result.RowAction = (int)RowActionTypeEnum.Delete;
                                        result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                        StateContainer.Tests.Remove(item);
                                        TestsCount--;

                                        TogglePendingSaveTests(result, item);
                                    }
                                }
                            }

                            SelectedTests.Clear();
                            await TestGrid.Reload();
                        }
                    }

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Delete Selected Tests

        #region Edit Test Intrepretation Button Click Event

        /// <summary>
        ///
        /// </summary>
        /// <param name="TestInterpretation"></param>
        protected async Task OnEditLaboratoryTestInterpretationClick(object TestInterpretation)
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<TestInterpretationModal>(Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionInterpretationDetailsModalHeading), new Dictionary<string, object>(),
                    options: new DialogOptions()
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is LaboratoryTestInterpretationGetListViewModel)
                {
                    if (StateContainer.TestInterpretations.Any(x => x.TestInterpretationID == (result as LaboratoryTestInterpretationGetListViewModel).TestInterpretationID))
                    {
                        int index = StateContainer.TestInterpretations.IndexOf(TestInterpretation as LaboratoryTestInterpretationGetListViewModel);
                        StateContainer.TestInterpretations[index] = result as LaboratoryTestInterpretationGetListViewModel;

                        TogglePendingSaveLaboratoryTestInterpretations(result as LaboratoryTestInterpretationGetListViewModel, TestInterpretation as LaboratoryTestInterpretationGetListViewModel);
                    }

                    await InterpretationsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Edit Test Intrepretation Button Click Event

        #region Selected Interpretation Change Event

        protected void OnTestInterpretationSelectionChange(LaboratoryTestInterpretationGetListViewModel item)
        {
            SelectedInterpretations ??= new List<LaboratoryTestInterpretationGetListViewModel>();

            if (SelectedInterpretations.Contains(item))
            {
                SelectedInterpretations.Remove(item);
            }
            else
            {
                SelectedInterpretations.Add(item);
            }
        }

        #endregion Selected Interpretation Change Event

        #region Selected Test Change Event

        protected void OnTestSelectionChange(LaboratoryTestGetListViewModel item)
        {
            SelectedTests ??= new List<LaboratoryTestGetListViewModel>();

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
            var validIndicator = ValidateTestsSection();

            return validIndicator;
        }

        #endregion Validation Methods

        #endregion Methods
    }
}