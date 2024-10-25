using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.ViewModels;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DetailedAnimalSamplesAggregateListBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<DetailedAnimalSamplesAggregateListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private int _animalSampleDatabaseQueryCount;
        private int _animalSampleLastDatabasePage;
        private int _animalSampleNewRecordCount;
        private int _animalSamplesLastPage;

        #endregion Member Variables

        #region Properties

        protected bool IsLoading { get; set; }
        protected int Count { get; set; }
        protected int PreviousPageSize { get; set; }
        protected RadzenDataGrid<VeterinaryActiveSurveillanceSessionAggregateViewModel> AnimalSampleAggregateGrid { get; set; }
        protected bool AddSampleButtonDisabled { get; set; }
        protected bool PrintSampleButtonDisabled { get; set; }
        private IList<VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel> AggregateDiseases { get; set; }

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
            _source = new();
            _token = _source.Token;

            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            await SetSampleButtonStates();

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            try
            {
                _source?.Cancel();
                _source?.Dispose();

                StateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
            }
            catch (Exception)
            {
                throw;
            }
        }

        private async Task OnStateContainerChangeAsync(string property)
        {
            switch (property)
            {
                case "FarmsAggregate" or "PendingSaveFarmsAggregate":
                    await SetSampleButtonStates();
                    await InvokeAsync(StateHasChanged).ConfigureAwait(false);
                    break;

                case "SelectedAggregateFarmID":
                    await AnimalSampleAggregateGrid.Reload().ConfigureAwait(false);
                    break;
            }
            if (property is "FarmsAggregate" or "PendingSaveFarmsAggregate")
            {
                await SetSampleButtonStates();
                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion Lifecycle Methods

        #region Load Data Methods

        protected async Task LoadAnimalSampleAggregateGrid(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.SessionKey != null)
                {
                    int page,
                        pageSize = 10;
                    string sortColumn = DefaultSortColumn,
                           sortOrder = SortConstants.Descending;

                    if (AnimalSampleAggregateGrid.PageSize != 0)
                        pageSize = AnimalSampleAggregateGrid.PageSize;

                    if (PreviousPageSize != pageSize)
                        IsLoading = true;

                    PreviousPageSize = pageSize;

                    page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.AnimalSamplesAggregate is null || _animalSampleLastDatabasePage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top / pageSize)))
                    {
                        IsLoading = true;
                    }

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

                        if (StateContainer.AggregateRecords is { Count: > 0 })
                        {
                            // get just the aggregate records that have samples, not the farm only records
                            StateContainer.AnimalSamplesAggregate = StateContainer.AggregateRecords.ToList();
                        }
                        else
                        {
                            var aggregateRequest = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel()
                            {
                                MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                                LanguageID = GetCurrentLanguage()
                            };

                            StateContainer.AggregateRecords = await VeterinaryClient.GetActiveSurveillanceSessionAggregateInfoListAsync(aggregateRequest, _token);
                            StateContainer.AggregateRecords = StateContainer.AggregateRecords.Where(x => x.RowStatus == 0).ToList();

                            await GetAggregateDiseases().ConfigureAwait(false);

                            StateContainer.AnimalSamplesAggregate = StateContainer.AggregateRecords.ToList();
                        }

                        _animalSampleDatabaseQueryCount = StateContainer.AnimalSamplesAggregate.All(x => x.RowStatus == (int)RowStatusTypeEnum.Inactive || x.MonitoringSessionSummaryID < 0)
                        ? 0
                        : StateContainer.AnimalSamplesAggregate.Count(x => x.MonitoringSessionSummaryID > 0);
                    }
                    else if (StateContainer.AnimalSamplesAggregate != null)
                    {
                        _animalSampleDatabaseQueryCount = !StateContainer.AnimalSamplesAggregate.Any() ? 0 : StateContainer.AnimalSamplesAggregate.First().TotalRowCount;
                    }

                    // remove or match up pending items that did not come from the database call
                    if (StateContainer.AnimalSamplesAggregate != null)
                    {
                        for (var index = 0; index < StateContainer.AnimalSamplesAggregate.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.AnimalSamplesAggregate[index].MonitoringSessionSummaryID < 0)
                            {
                                StateContainer.AnimalSamplesAggregate.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveAnimalSamplesAggregate == null || index < 0 || StateContainer.AnimalSamplesAggregate.Count == 0 || StateContainer.PendingSaveAnimalSamplesAggregate.All(x =>
                                    x.MonitoringSessionSummaryID != StateContainer.AnimalSamplesAggregate[index].MonitoringSessionSummaryID)) continue;
                            {
                                if (StateContainer.PendingSaveAnimalSamplesAggregate.First(x => x.MonitoringSessionSummaryID == StateContainer.AnimalSamplesAggregate[index].MonitoringSessionSummaryID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.AnimalSamplesAggregate.RemoveAt(index);
                                    _animalSampleDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.AnimalSamplesAggregate[index] = StateContainer.PendingSaveAnimalSamplesAggregate.First(x =>
                                        x.MonitoringSessionSummaryID == StateContainer.AnimalSamplesAggregate[index].MonitoringSessionSummaryID);
                                }
                            }
                        }
                    }

                    Count = _animalSampleDatabaseQueryCount + _animalSampleNewRecordCount;

                    if (_animalSampleNewRecordCount > 0)
                    {
                        _animalSampleLastDatabasePage = Math.DivRem(_animalSampleDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _animalSampleLastDatabasePage == 0)
                            _animalSampleLastDatabasePage += 1;

                        if (page >= _animalSampleLastDatabasePage && StateContainer.PendingSaveAnimalSamplesAggregate != null &&
                            StateContainer.PendingSaveAnimalSamplesAggregate.Any(x => x.MonitoringSessionSummaryID < 0))
                        {
                            var newRecordsPendingSave =
                                StateContainer.PendingSaveAnimalSamplesAggregate.Where(x => x.MonitoringSessionSummaryID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _animalSampleLastDatabasePage;
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
                                StateContainer.AnimalSamples?.Clear();
                            }
                            else
                            {
                                StateContainer.AnimalSamplesAggregate?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.AnimalSamplesAggregate?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (StateContainer.AnimalSamplesAggregate != null)
                            StateContainer.AnimalSamplesAggregate = StateContainer.AnimalSamplesAggregate.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _animalSamplesLastPage = page;
                }

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

        private async Task GetAggregateDiseases()
        {
            if (StateContainer.AggregateRecords is { Count: > 0 })
            {
                foreach (var record in StateContainer.AggregateRecords)
                {
                    var aggregateRequest = new VeterinaryActiveSurveillanceSessionAggregateNonPagedRequestModel()
                    {
                        MonitoringSessionSummaryID = record.MonitoringSessionSummaryID,
                        LanguageID = GetCurrentLanguage()
                    };
                    var result = await VeterinaryClient.GetActiveSurveillanceSessionAggregateDiseaseListAsync(aggregateRequest, _token);
                    if (result is { Count: > 0 })
                    {
                        record.SelectedDiseases = result.Select(disease => disease.DiseaseID);
                    }
                }
            }
        }

        #endregion Load Data Methods

        #region Edit Sample Events

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAnimalSamplesAggregate(VeterinaryActiveSurveillanceSessionAggregateViewModel record, VeterinaryActiveSurveillanceSessionAggregateViewModel originalRecord)
        {
            int index;

            if (StateContainer.PendingSaveAnimalSamplesAggregate == null)
                StateContainer.PendingSaveAnimalSamplesAggregate = new List<VeterinaryActiveSurveillanceSessionAggregateViewModel>();

            if (StateContainer.PendingSaveAnimalSamplesAggregate.Any(x => x.MonitoringSessionSummaryID == record.MonitoringSessionSummaryID))
            {
                index = StateContainer.PendingSaveAnimalSamplesAggregate.IndexOf(originalRecord);
                StateContainer.PendingSaveAnimalSamplesAggregate[index] = record;
            }
            else
            {
                StateContainer.PendingSaveAnimalSamplesAggregate.Add(record);
            }
        }

        protected async Task OnEditAggregateSampleClick(VeterinaryActiveSurveillanceSessionAggregateViewModel sample)
        {
            try
            {
                StateContainer.AnimalSampleDetailAggregate = sample;
                dynamic result = await DiagService.OpenAsync<DetailedAnimalSampleAggregateModal>(Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionSampleDetailsModalHeading),
                    new Dictionary<string, object>() { },
                     options: new DialogOptions()
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
                    // edit the animal samples aggregate lists
                    var sampleResult = result as SampleGetListViewModel;
                    var editedSample = StateContainer.AnimalSamplesAggregate.Find(s => s.MonitoringSessionSummaryID == sample.MonitoringSessionSummaryID);
                    editedSample = sample;
                    TogglePendingSaveAnimalSamplesAggregate(editedSample, sample);

                    await AnimalSampleAggregateGrid.Reload();
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
        protected async Task OnAddAggregateSampleClick()
        {
            try
            {
                StateContainer.AnimalSampleDetailAggregate = new VeterinaryActiveSurveillanceSessionAggregateViewModel();

                var result = await DiagService.OpenAsync<DetailedAnimalSampleAggregateModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionSampleDetailsModalHeading),
                    new Dictionary<string, object> { },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result is VeterinaryActiveSurveillanceSessionAggregateViewModel model)
                {
                    _animalSampleNewRecordCount += 1;

                    StateContainer.AnimalSamplesAggregate ??= new List<VeterinaryActiveSurveillanceSessionAggregateViewModel>();

                    StateContainer.AnimalSamplesAggregate.Add(result as VeterinaryActiveSurveillanceSessionAggregateViewModel);

                    TogglePendingSaveAnimalSamplesAggregate(model, null);

                    await AnimalSampleAggregateGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Add Sample Event

        #region Print Samples

        protected async Task OnPrintAggregateSampleClick()
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
                reportModel.AddParameter("idfCase", StateContainer.SessionKey.ToString());

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionDetailedInformationDetailedAnimalsAndSamplesHeading),
                    new Dictionary<string, object> { { "ReportName", "ActiveSurveillanceSessionListOfSamples" }, { "Parameters", reportModel.Parameters } },
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

        #endregion Print Samples

        #region Delete Sample Events

        protected async Task OnDeleteAggregateSampleClick(VeterinaryActiveSurveillanceSessionAggregateViewModel item)
        {
            try
            {
                dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult)
                {
                    if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (StateContainer.AnimalSamplesAggregate.Any(x => x.MonitoringSessionSummaryID == item.MonitoringSessionSummaryID))
                        {
                            if (item.MonitoringSessionSummaryID <= 0)
                            {
                                StateContainer.AnimalSamplesAggregate.Remove(item);
                                StateContainer.PendingSaveAnimalSamplesAggregate.Remove(item);
                                _animalSampleNewRecordCount--;
                            }
                            else
                            {
                                result = item.ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                StateContainer.AnimalSamplesAggregate.Remove(item);
                                Count--;

                                TogglePendingSaveAnimalSamplesAggregate(result, item);
                            }
                        }

                        await AnimalSampleAggregateGrid.Reload();

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

        #region Set Sample Button States

        private async Task SetSampleButtonStates()
        {
            // if the report is not saved, don't enable the print button
            PrintSampleButtonDisabled = StateContainer.SessionKey <= 0;

            // if there are no aggregate farms, don't allow edits
            if ((StateContainer.FarmsAggregate == null 
                 || StateContainer.FarmsAggregate.Count == 0))
            {
                AddSampleButtonDisabled = true;
            }
            else
            {
                AddSampleButtonDisabled = false;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Set Sample Button States

        #endregion Methods
    }
}