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
    public class VaccinationsSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<VaccinationsSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<VaccinationGetListViewModel> VaccinationsGrid;
        public int Count;
        private int PreviousPageSize { get; set; }
        public string TypeResourceKey { get; set; }
        public string RouteResourceKey { get; set; }
        public string LotNumberResourceKey { get; set; }
        public string ManufacturerResourceKey { get; set; }
        public string CommentsResourceKey { get; set; }

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

        private const string DefaultSortColumn = "VaccinationDate";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public VaccinationsSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected VaccinationsSectionBase() : base(CancellationToken.None)
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

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                TypeResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalTypeFieldLabel;
                RouteResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalRouteFieldLabel;
                LotNumberResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalLotNumberFieldLabel;
                ManufacturerResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalManufacturerFieldLabel;
                CommentsResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalCommentsFieldLabel;
            }
            else
            {
                TypeResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalTypeFieldLabel;
                RouteResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalRouteFieldLabel;
                LotNumberResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalLotNumberFieldLabel;
                ManufacturerResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalManufacturerFieldLabel;
                CommentsResourceKey = FieldLabelResourceKeyConstants.VaccinationDetailsModalCommentsFieldLabel;
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
        // ~VaccinationsSectionBase()
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

                await JsRuntime.InvokeVoidAsync("VaccinationsSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadVaccinationData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (VaccinationsGrid.PageSize != 0)
                    pageSize = VaccinationsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.Vaccinations is null ||
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

                        Model.Vaccinations =
                            await GetVaccinations(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                                .ConfigureAwait(false);
                        if (page == 1)
                            _databaseQueryCount = !Model.Vaccinations.Any() ? 0 : Model.Vaccinations.First().TotalRowCount;
                    }
                    else if (Model.Vaccinations != null)
                    {
                        _databaseQueryCount = Model.Vaccinations.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.VaccinationID < 0)
                            ? 0
                            : Model.Vaccinations.First(x => x.VaccinationID > 0).TotalRowCount;
                    }

                    if (Model.Vaccinations != null)
                        for (var index = 0; index < Model.Vaccinations.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.Vaccinations[index].VaccinationID < 0)
                            {
                                Model.Vaccinations.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveVaccinations == null || index < 0 || Model.Vaccinations.Count == 0 ||
                                Model.PendingSaveVaccinations.All(x =>
                                    x.VaccinationID != Model.Vaccinations[index].VaccinationID)) continue;
                            {
                                if (Model.PendingSaveVaccinations
                                        .First(x => x.VaccinationID == Model.Vaccinations[index].VaccinationID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.Vaccinations.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.Vaccinations[index] = Model.PendingSaveVaccinations.First(x =>
                                        x.VaccinationID == Model.Vaccinations[index].VaccinationID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveVaccinations != null &&
                            Model.PendingSaveVaccinations.Any(x => x.VaccinationID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveVaccinations.Where(x => x.VaccinationID < 0).ToList();
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
                                Model.Vaccinations?.Clear();
                            }
                            else
                            {
                                Model.Vaccinations?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.Vaccinations?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.Vaccinations != null)
                            Model.Vaccinations = Model.Vaccinations.AsQueryable()
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
        protected void TogglePendingSaveVaccinations(VaccinationGetListViewModel record,
            VaccinationGetListViewModel originalRecord)
        {
            Model.PendingSaveVaccinations ??= new List<VaccinationGetListViewModel>();

            if (Model.PendingSaveVaccinations.Any(x => x.VaccinationID == record.VaccinationID))
            {
                var index = Model.PendingSaveVaccinations.IndexOf(originalRecord);
                Model.PendingSaveVaccinations[index] = record;
            }
            else
            {
                Model.PendingSaveVaccinations.Add(record);
            }
        }

        #endregion

        #region Add Vaccination Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddVaccinationClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<Vaccination>(
                    Localizer.GetString(HeadingResourceKeyConstants.VaccinationDetailsModalHeading),
                    new Dictionary<string, object>
                        {{"Model", new VaccinationGetListViewModel()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is VaccinationGetListViewModel model)
                {
                    _newRecordCount += 1;

                    TogglePendingSaveVaccinations(model, null);

                    await VaccinationsGrid.Reload().ConfigureAwait(false);
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

        #region Edit Vaccination Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="vaccination"></param>
        protected async Task OnEditVaccinationClick(object vaccination)
        {
            try
            {
                var result = await DiagService.OpenAsync<Vaccination>(
                    Localizer.GetString(HeadingResourceKeyConstants.VaccinationDetailsModalHeading),
                    new Dictionary<string, object>
                    {
                        {"Model", ((VaccinationGetListViewModel) vaccination).ShallowCopy()}, {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is VaccinationGetListViewModel model)
                {
                    if (Model.Vaccinations.Any(x =>
                            x.VaccinationID == ((VaccinationGetListViewModel) result).VaccinationID))
                    {
                        var index = Model.Vaccinations.IndexOf((VaccinationGetListViewModel) vaccination);
                        Model.Vaccinations[index] = model;

                        TogglePendingSaveVaccinations(model, (VaccinationGetListViewModel) vaccination);
                    }

                    await VaccinationsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Vaccination Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="vaccination"></param>
        protected async Task OnDeleteVaccinationClick(object vaccination)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.Vaccinations.Any(x =>
                                x.VaccinationID == ((VaccinationGetListViewModel) vaccination).VaccinationID))
                        {
                            if (((VaccinationGetListViewModel) vaccination).VaccinationID <= 0)
                            {
                                Model.Vaccinations.Remove((VaccinationGetListViewModel) vaccination);
                                Model.PendingSaveVaccinations.Remove((VaccinationGetListViewModel) vaccination);
                                _newRecordCount--;
                            }
                            else
                            {
                                result = ((VaccinationGetListViewModel) vaccination).ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                Model.Vaccinations.Remove((VaccinationGetListViewModel) vaccination);

                                TogglePendingSaveVaccinations(result, (VaccinationGetListViewModel) vaccination);
                            }
                        }

                        await VaccinationsGrid.Reload().ConfigureAwait(false);

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
            Model.Vaccinations = null;
            VaccinationsGrid.Reload();
        }

        #endregion

        #endregion
    }
}