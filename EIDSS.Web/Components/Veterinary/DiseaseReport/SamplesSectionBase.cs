#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
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
    public class SamplesSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SamplesSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<SampleGetListViewModel> SamplesGrid { get; set; }
        protected RadzenDataGrid<SampleGetListViewModel> AliquotsAndDerivativesGrid { get; set; }
        public IList<SampleGetListViewModel> AliquotsAndDerivatives { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        public string SectionHeadingResourceKey { get; set; }
        public string DetailsHeadingResourceKey { get; set; }
        public string ImportSamplesTestResultsResourceKey { get; set; }
        public string LabSampleIdColumnHeadingResourceKey { get; set; }
        public string SampleTypeColumnHeadingResourceKey { get; set; }
        public string FieldSampleIdColumnHeadingResourceKey { get; set; }
        public string AnimalIdColumnHeadingResourceKey { get; set; }
        public string SpeciesColumnHeadingResourceKey { get; set; }
        public string BirdStatusColumnHeadingResourceKey { get; set; }
        public string CollectionDateColumnHeadingResourceKey { get; set; }
        public string SentDateColumnHeadingResourceKey { get; set; }
        public string SentToOrganizationColumnHeadingResourceKey { get; set; }
        public string AccessionDateFieldLabelResourceKey { get; set; }
        public string SampleConditionReceivedFieldLabelResourceKey { get; set; }
        public string CommentFieldLabelResourceKey { get; set; }
        public string CollectedByInstitutionFieldLabelResourceKey { get; set; }
        public string CollectedByOfficerFieldLabelResourceKey { get; set; }
        public string AdditionalTestsRequestedAndSampleNotesFieldLabelResourceKey { get; set; }
        public string AliquotAndDerivativeLabSampleIdColumnHeadingResourceKey { get; set; }
        public string AliquotAndDerivativeStatusColumnHeadingResourceKey { get; set; }
        public string AliquotAndDerivativeLabColumnHeadingResourceKey { get; set; }
        public string AliquotAndDerivativeFunctionalAreaColumnHeadingResourceKey { get; set; }

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

        private const string DefaultSortColumn = "EIDSSLaboratorySampleID";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public SamplesSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected SamplesSectionBase() : base(CancellationToken.None)
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
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportSamplesHeading);
                DetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportSampleDetailsModalHeading);
                ImportSamplesTestResultsResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .AvianDiseaseReportImportSamplesTestResultsModalImportSamplesTestResultsHeading);
                LabSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesLabSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSampleTypeColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesFieldSampleIDColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSpeciesColumnHeading);
                BirdStatusColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesBirdStatusColumnHeading);
                CollectionDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesCollectionDateColumnHeading);
                SentDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSentDateColumnHeading);
                SentToOrganizationColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesSentToOrganizationColumnHeading);

                AccessionDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSamplesAccessionDateFieldLabel;
                SampleConditionReceivedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSamplesSampleConditionReceivedFieldLabel;
                CommentFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportSamplesCommentFieldLabel;
                CollectedByInstitutionFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSamplesCollectedByInsitutionFieldLabel;
                CollectedByOfficerFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSamplesCollectedByOfficerFieldLabel;
                AdditionalTestsRequestedAndSampleNotesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportSamplesAdditionalTestRequestedAndSampleNotesFieldLabel;

                AliquotAndDerivativeLabSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportSamplesAliquotsDerivativesLabSampleIDColumnHeading);
                AliquotAndDerivativeStatusColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportSamplesAliquotsDerivativesStatusColumnHeading);
                AliquotAndDerivativeLabColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportSamplesAliquotsDerivativesLabAbbreviatedNameColumnHeading);
                AliquotAndDerivativeFunctionalAreaColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportSamplesAliquotsDerivativesFunctionalAreaColumnHeading);
            }
            else
            {
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportSamplesHeading);
                DetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportSampleDetailsModalHeading);
                ImportSamplesTestResultsResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .LivestockDiseaseReportImportSamplesTestResultsModalImportSamplesTestResultsHeading);
                LabSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesLabSampleIDColumnHeading);
                SampleTypeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSampleTypeColumnHeading);
                FieldSampleIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesFieldSampleIDColumnHeading);
                AnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesAnimalIDColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSpeciesColumnHeading);
                CollectionDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesCollectionDateColumnHeading);
                SentDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSentDateColumnHeading);
                SentToOrganizationColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesSentToOrganizationColumnHeading);

                AccessionDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSamplesAccessionDateFieldLabel;
                SampleConditionReceivedFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSamplesSampleConditionReceivedFieldLabel;
                CommentFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportSamplesCommentFieldLabel;
                CollectedByInstitutionFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSamplesCollectedByInsitutionFieldLabel;
                CollectedByOfficerFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSamplesCollectedByOfficerFieldLabel;
                AdditionalTestsRequestedAndSampleNotesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportSamplesAdditionalTestRequestedAndSampleNotesFieldLabel;

                AliquotAndDerivativeLabSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportSamplesAliquotsDerivativesLabSampleIDColumnHeading);
                AliquotAndDerivativeStatusColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportSamplesAliquotsDerivativesStatusColumnHeading);
                AliquotAndDerivativeLabColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportSamplesAliquotsDerivativesLabAbbreviatedNameColumnHeading);
                AliquotAndDerivativeFunctionalAreaColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportSamplesAliquotsDerivativesFunctionalAreaColumnHeading);
            }

            // get linked surveillance session
            // samples if any
            LoadSurveillanceData();

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
        ///     Free up managed and unmanaged resources.
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

                await JsRuntime.InvokeVoidAsync("SamplesSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);
            }
        }

        #endregion

        #region Surveillance Linked Report

        private void LoadSurveillanceData()
        {
            if (Model.SessionModel == null) return;
            Model.PendingSaveSamples ??= new List<SampleGetListViewModel>();
            Model.SessionModel.Samples.ForEach(s =>
            {
                s.SampleID = (Model.PendingSaveSamples.Count + 1) * -1;
                s.MonitoringSessionID = null;
                s.RowAction = (int) RowActionTypeEnum.Insert;
                s.RowStatus = (int) RowStatusTypeEnum.Active;
                _newRecordCount++;
                Model.PendingSaveSamples.Add(s);
            });
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task LoadSampleData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (SamplesGrid.PageSize != 0)
                    pageSize = SamplesGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.Samples is null ||
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

                        Model.Samples = await GetSamples(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                            .ConfigureAwait(false);
                        if (page == 1)
                            _databaseQueryCount = !Model.Samples.Any() ? 0 : Model.Samples.First().TotalRowCount;
                    }
                    else if (Model.Samples != null)
                    {
                        _databaseQueryCount = Model.Samples.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.SampleID < 0)
                            ? 0
                            : Model.Samples.First(x => x.SampleID > 0).TotalRowCount;

                        // Subtract out any samples de-linked from the disease report.
                        _databaseQueryCount -= Model.PendingSaveSamples.Count(x =>
                            x.VeterinaryDiseaseReportID == null && x.RowAction == (int) RowActionTypeEnum.Update);
                    }

                    if (Model.Samples != null)
                        for (var index = 0; index < Model.Samples.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.Samples[index].SampleID < 0 || Model.Samples[index].ImportIndicator)
                            {
                                Model.Samples.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveSamples == null || index < 0 || Model.Samples.Count == 0 ||
                                Model.PendingSaveSamples.All(x => x.SampleID != Model.Samples[index].SampleID))
                                continue;
                            {
                                if (Model.PendingSaveSamples.First(x => x.SampleID == Model.Samples[index].SampleID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.Samples.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.Samples[index] = Model.PendingSaveSamples.First(x =>
                                        x.SampleID == Model.Samples[index].SampleID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveSamples != null &&
                            Model.PendingSaveSamples.Any(x => x.SampleID < 0 || x.ImportIndicator))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveSamples.Where(x => x.SampleID < 0 || x.ImportIndicator).ToList();
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
                                Model.Samples?.Clear();
                            }
                            else
                            {
                                Model.Samples?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.Samples?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.Samples != null)
                            Model.Samples = Model.Samples.AsQueryable()
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
        protected void TogglePendingSaveSamples(SampleGetListViewModel record, SampleGetListViewModel originalRecord)
        {
            Model.PendingSaveSamples ??= new List<SampleGetListViewModel>();

            if (Model.PendingSaveSamples.Any(x => x.SampleID == record.SampleID) && originalRecord is not null)
            {
                var index = Model.PendingSaveSamples.ToList().FindIndex(x => x.SampleID == originalRecord.SampleID);
                Model.PendingSaveSamples[index] = record;
            }
            else
            {
                Model.PendingSaveSamples.Add(record);
            }
        }

        /// <summary>
        ///     Get the aliquots and derivatives for the current root/parent sample.
        /// </summary>
        /// <param name="sample"></param>
        /// <returns></returns>
        public async Task OnSamplesRowExpand(SampleGetListViewModel sample)
        {
            try
            {
                var request = new SampleGetListRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    RootSampleID = sample.SampleID,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "EIDSSLaboratorySampleID",
                    SortOrder = SortConstants.Descending
                };
                AliquotsAndDerivatives = await VeterinaryClient.GetSampleList(request, _token).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Sample Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddSampleClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<Sample>(Localizer.GetString(DetailsHeadingResourceKey),
                    new Dictionary<string, object> {{"Model", new SampleGetListViewModel()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true, ShowClose = true
                    });

                if (result is SampleGetListViewModel model)
                {
                    _newRecordCount += 1;

                    TogglePendingSaveSamples(model, null);

                    await SamplesGrid.Reload().ConfigureAwait(false);
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

        #region Import Sample Button Click Event

        /// <summary>
        /// </summary>
        protected async Task OnImportSampleClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<ImportSamples>(
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportSamplesHeading),
                    new Dictionary<string, object> {{"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true, Draggable = false, Resizable = true, ShowClose = true
                    });

                if (result is SampleGetListViewModel model)
                {
                    _newRecordCount += 1;

                    Model?.Samples.Add(model);

                    TogglePendingSaveSamples(model, null);

                    await SamplesGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Sample Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        protected async Task OnEditSampleClick(object sample)
        {
            try
            {
                var result = await DiagService.OpenAsync<Sample>(Localizer.GetString(DetailsHeadingResourceKey),
                    new Dictionary<string, object>
                    {
                        {"Model", ((SampleGetListViewModel) sample).ShallowCopy()}, {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result is SampleGetListViewModel model)
                {
                    if (Model.Samples.Any(x => x.SampleID == ((SampleGetListViewModel) result).SampleID))
                    {
                        var index = Model.Samples.IndexOf((SampleGetListViewModel) sample);
                        Model.Samples[index] = model;

                        TogglePendingSaveSamples(model, (SampleGetListViewModel) sample);
                    }

                    await SamplesGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Sample Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="sample"></param>
        protected async Task OnDeleteSampleClick(object sample)
        {
            try
            {
                if (CanDeleteSampleRecord(((SampleGetListViewModel) sample).SampleID))
                {
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (Model.Samples.Any(x => x.SampleID == ((SampleGetListViewModel) sample).SampleID))
                            {
                                if (((SampleGetListViewModel) sample).SampleID <= 0)
                                {
                                    Model.Samples.Remove((SampleGetListViewModel) sample);
                                    Model.PendingSaveSamples.Remove((SampleGetListViewModel) sample);
                                    _newRecordCount--;
                                }
                                else
                                {
                                    result = ((SampleGetListViewModel) sample).ShallowCopy();

                                    // Check if need to de-link the sample from the disease report.
                                    if (result.MonitoringSessionID is not null ||
                                        result.LabModuleSourceIndicator == 1)
                                    {
                                        result.VeterinaryDiseaseReportID = null;
                                        result.RowAction = (int) RowActionTypeEnum.Update;
                                    }
                                    else
                                    {
                                        result.RowAction = (int) RowActionTypeEnum.Delete;
                                        result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                    }

                                    Model.Samples.Remove((SampleGetListViewModel) sample);

                                    TogglePendingSaveSamples(result, (SampleGetListViewModel) sample);
                                }
                            }

                            await SamplesGrid.Reload();

                            DiagService.Close(result);
                        }
                }
                else
                {
                    await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage, null)
                        .ConfigureAwait(false);

                    DiagService.Close();
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
        /// <param name="sampleId"></param>
        /// <returns></returns>
        private bool CanDeleteSampleRecord(long sampleId)
        {
            var canDelete = true;

            StateHasChanged();

            if (Model.PensideTests is not null)
                canDelete = !Model.PensideTests.Any(x =>
                    x.SampleID == sampleId && x.RowStatus == (int) RowStatusTypeEnum.Active);

            if (canDelete && Model.LaboratoryTests is not null)
                canDelete = !Model.LaboratoryTests.Any(x =>
                    x.SampleID == sampleId && x.RowStatus == (int) RowStatusTypeEnum.Active);

            return canDelete;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.Samples = null;
            SamplesGrid.Reload();
        }

        #endregion

        #endregion
    }
}