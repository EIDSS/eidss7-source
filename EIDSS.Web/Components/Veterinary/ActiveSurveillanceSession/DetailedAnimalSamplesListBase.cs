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
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.ViewModels;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.EntityFrameworkCore.ChangeTracking.Internal;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DetailedAnimalSamplesListBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<DetailedAnimalSamplesListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private List<SampleGetListViewModel> _selectedSamples;
        private int _animalSampleDatabaseQueryCount;
        private int _animalSampleDatabaseAnimalQueryCount;
        private int _animalSampleLastDatabasePage;
        private int _animalSampleNewRecordCount;
        private int _animalSamplesLastPage;

        #endregion Member Variables

        #region Properties

        protected bool IsLoading { get; set; }
        protected int Count { get; set; }
        protected int PreviousPageSize { get; set; }
        protected RadzenDataGrid<SampleGetListViewModel> AnimalSampleGrid { get; set; }
        protected RadzenNumeric<long?> TotalNumberControl { get; set; }
        protected RadzenNumeric<int> TotalNumberOfAnimalsSampledControl { get; set; }
        protected RadzenNumeric<int> TotalNumberOfSamplesControl { get; set; }
        protected bool AddSampleButtonDisabled { get; set; }
        protected bool DeleteSampleButtonDisabled { get; set; }
        protected bool CopySampleButtonDisabled { get; set; }
        protected bool PrintSampleButtonDisabled { get; set; }

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

            _selectedSamples = new List<SampleGetListViewModel>();

            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected override Task OnAfterRenderAsync(bool firstRender)
        {
            SetSampleButtonStates();

            return base.OnAfterRenderAsync(firstRender);
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
            if (property is "Farms" or "PendingSaveFarms")
            {
                SetSampleButtonStates();
                await InvokeAsync(StateHasChanged);
            }
            else if (property is "Tests")
            {
                StateContainer.AnimalSamples?.ForEach(x =>
                {
                    x.TestsCount = StateContainer.Tests is { Count: > 0 } ? StateContainer.Tests.Count(t => t.SampleID == x.SampleID) : 0;
                });
                await AnimalSampleGrid.Reload().ConfigureAwait(false);
            }
        }

        #endregion Lifecycle Methods

        #region Load Data Methods

        protected async Task LoadAnimalSampleGrid(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (AnimalSampleGrid.PageSize != 0)
                    pageSize = AnimalSampleGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.AnimalSamples is not { Count: > 0 } ||
                        _animalSamplesLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
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

                        var request = new SampleGetListRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                            SortColumn = sortColumn,
                            SortOrder = sortOrder,
                            Page = page,
                            PageSize = pageSize
                        };
                        StateContainer.AnimalSamples = await VeterinaryClient.GetActiveSurveillanceSessionSamplesListAsync(request, _token);
                        if (page == 1)
                        {
                            _animalSampleDatabaseQueryCount =
                                !StateContainer.AnimalSamples.Any()
                                    ? 0
                                    : StateContainer.AnimalSamples.First().TotalRowCount;

                            _animalSampleDatabaseAnimalQueryCount = !StateContainer.AnimalSamples.Any()
                                ? 0
                                : StateContainer.AnimalSamples.First().TotalAnimalsSampled;
                        }

                        await GetSampleDiseases().ConfigureAwait(false);
                    }
                    else if (StateContainer.AnimalSamples != null)
                    {
                        _animalSampleDatabaseQueryCount = StateContainer.AnimalSamples.All(x =>
                            x.RowStatus == (int)RowStatusTypeEnum.Inactive || x.SampleID < 0)
                            ? 0
                            : StateContainer.AnimalSamples.First(x => x.SampleID > 0).TotalRowCount;

                        _animalSampleDatabaseAnimalQueryCount = !StateContainer.AnimalSamples.Any()
                            ? 0
                            : StateContainer.AnimalSamples.First().TotalAnimalsSampled;
                    }
                    else
                    {
                        StateContainer.AnimalSamples = new List<SampleGetListViewModel>();
                    }

                    if (StateContainer.AnimalSamples != null)
                    {
                        for (var index = 0; index < StateContainer.AnimalSamples.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.AnimalSamples[index].SampleID < 0)
                            {
                                StateContainer.AnimalSamples.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveAnimalSamples == null || index < 0 || StateContainer.AnimalSamples.Count == 0 ||
                                StateContainer.PendingSaveAnimalSamples.All(x =>
                                    x.SampleID != StateContainer.AnimalSamples[index].SampleID)) continue;
                            {
                                if (StateContainer.PendingSaveAnimalSamples
                                        .First(x => x.SampleID == StateContainer.AnimalSamples[index].SampleID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.AnimalSamples.RemoveAt(index);
                                    _animalSampleDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.AnimalSamples[index] = StateContainer.PendingSaveAnimalSamples.First(x =>
                                        x.SampleID == StateContainer.AnimalSamples[index].SampleID);
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

                        if (page >= _animalSampleLastDatabasePage && StateContainer.PendingSaveAnimalSamples != null &&
                            StateContainer.PendingSaveAnimalSamples.Any(x => x.SampleID < 0))
                        {
                            var counter = 0;
                            var offset = 0;

                            var newRecordsPendingSave =
                                StateContainer.PendingSaveAnimalSamples.Where(x => x.SampleID < 0).ToList();
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
                                offset = newRecordsPendingSave.Count - remainderNewRecords;
                                StateContainer.AnimalSamples?.Clear();
                            }
                            else
                            {
                                offset = newRecordsPendingSave.Count - (pageSize * (page - 1));
                                StateContainer.AnimalSamples?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.AnimalSamples?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[counter + offset]);

                                counter += 1;
                            }
                        }
                    }

                    if (StateContainer.AnimalSamples != null)
                    {
                        // total samples
                        var inactiveSamples = StateContainer.PendingSaveAnimalSamples?.Count(x =>
                            x.RowStatus is (int)RowStatusTypeEnum.Inactive);
                        StateContainer.TotalNumberOfSamples = _animalSampleDatabaseQueryCount + _animalSampleNewRecordCount - inactiveSamples.GetValueOrDefault();

                        // animals sampled
                        var newSamplesWithAnimals =
                            StateContainer.PendingSaveAnimalSamples?.DistinctBy(x => x.EIDSSAnimalID).Count(x =>
                                !string.IsNullOrEmpty(x.EIDSSAnimalID));
                        var inactiveSamplesWithAnimals =
                            StateContainer.PendingSaveAnimalSamples?.DistinctBy(x => x.EIDSSAnimalID).Count(x =>
                                !string.IsNullOrEmpty(x.EIDSSAnimalID) && x.RowStatus is (int)RowStatusTypeEnum.Inactive);
                        StateContainer.TotalNumberOfAnimalsSampled = _animalSampleDatabaseAnimalQueryCount + newSamplesWithAnimals.GetValueOrDefault() - inactiveSamplesWithAnimals.GetValueOrDefault();
                    }

                    if (StateContainer.AnimalSamples != null)
                        StateContainer.AnimalSamples = StateContainer.AnimalSamples.AsQueryable()
                            .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();

                    _animalSamplesLastPage = page;
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task GetSampleDiseases()
        {
            if (StateContainer.AnimalSampleToDiseases is null or { Count: 0 })
            {
                var request = new VeterinaryActiveSurveillanceSessionSampleDiseaseRequestModel()
                {
                    LanguageID = GetCurrentLanguage(),
                    MonitoringSessionID = StateContainer.SessionKey,
                    SampleID = null
                };
                StateContainer.AnimalSampleToDiseases =
                    await VeterinaryClient.GetActiveSurveillanceSessionSampleDiseaseListAsync(request, _token);
            }
        }

        #endregion Load Data Methods

        #region Edit Sample Events

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAnimalSamples(SampleGetListViewModel record, SampleGetListViewModel originalRecord)
        {
            StateContainer.PendingSaveAnimalSamples ??= new List<SampleGetListViewModel>();

            if (StateContainer.PendingSaveAnimalSamples.Any(x => x.SampleID == record.SampleID))
            {
                var index = StateContainer.PendingSaveAnimalSamples.IndexOf(originalRecord);
                StateContainer.PendingSaveAnimalSamples[index] = record;
            }
            else
            {
                StateContainer.PendingSaveAnimalSamples.Add(record);
            }
        }

        protected async Task OnEditSampleClick(SampleGetListViewModel sample)
        {
            try
            {
                StateContainer.AnimalSampleDetail = sample;
                StateContainer.AnimalSampleDetail.SelectedDiseases = new List<long>();
                if (StateContainer.AnimalSampleToDiseases is not null)
                {
                    sample.SelectedDiseases = StateContainer.AnimalSampleToDiseases
                        .Where(x => x.SampleID == sample.SampleID).Select(d => d.DiseaseID).ToList();
                }

                dynamic result = await DiagService.OpenAsync<DetailedAnimalSampleModal>(Localizer.GetString(HeadingResourceKeyConstants.VeterinarySessionSampleDetailsModalHeading),
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
                    if (result is SampleGetListViewModel sampleResult)
                    {
                        var editedSample = StateContainer.AnimalSamples.Find(s => s.SampleID == sampleResult.SampleID);
                        editedSample = sampleResult;
                        TogglePendingSaveAnimalSamples(editedSample, sampleResult);
                    }

                    await AnimalSampleGrid.Reload();
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
                StateContainer.AnimalSampleDetail = new SampleGetListViewModel
                {
                    SelectedDiseases = new List<long>()
                };

                var result = await DiagService.OpenAsync<DetailedAnimalSampleModal>(
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

                if (result is SampleGetListViewModel model)
                {
                    _animalSampleNewRecordCount += 1;

                    StateContainer.AnimalSamples.Add(model);

                    TogglePendingSaveAnimalSamples(model, null);

                    await AnimalSampleGrid.Reload().ConfigureAwait(false);
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

        protected async Task OnPrintSampleClick()
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

        protected async Task OnDeleteSelectedSampleClick()
        {
            try
            {
                if (_selectedSamples is { Count: > 0 })
                {
                    dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            foreach (var item in _selectedSamples)
                            {
                                if (item.SampleID <= 0)
                                {
                                    StateContainer.AnimalSamples.Remove(item);
                                    StateContainer.PendingSaveAnimalSamples.Remove(item);
                                    _animalSampleNewRecordCount--;
                                }
                                else
                                {
                                    result = item.ShallowCopy();
                                    result.RowAction = (int)RowActionTypeEnum.Delete;
                                    result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                    StateContainer.AnimalSamples.Remove(item);
                                    Count--;

                                    TogglePendingSaveAnimalSamples(result, item);
                                }
                            }

                            _selectedSamples.Clear();
                            await AnimalSampleGrid.Reload();
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

        protected async Task OnDeleteSampleClick(SampleGetListViewModel item)
        {
            try
            {
                dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (StateContainer.AnimalSamples.Any(x => x.SampleID == item.SampleID))
                        {
                            if (item.SampleID <= 0)
                            {
                                StateContainer.AnimalSamples.Remove(item);
                                StateContainer.PendingSaveAnimalSamples.Remove(item);
                                _animalSampleNewRecordCount--;
                            }
                            else
                            {
                                result = item.ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                StateContainer.AnimalSamples.Remove(item);
                                Count--;

                                TogglePendingSaveAnimalSamples(result, item);
                            }
                        }

                        if (_selectedSamples != null && _selectedSamples.All(x => x.SampleID == item.SampleID))
                        {
                            _selectedSamples.Remove(item);
                        }

                        await AnimalSampleGrid.Reload();

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

        #region Record Selection Events

        /// <summary>
        ///
        /// </summary>
        /// <returns></returns>
        protected bool IsHeaderRecordSelected()
        {
            try
            {
                if (StateContainer.AnimalSamples is null)
                    return false;

                if (_selectedSamples != null && _selectedSamples.Count > 0)
                {
                    foreach (SampleGetListViewModel item in StateContainer.AnimalSamples)
                    {
                        if (_selectedSamples.Any(x => x.SampleID == item.SampleID))
                            return true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return false;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="value"></param>
        protected void OnHeaderRecordSelectionChange(bool? value)
        {
            try
            {
                if (value == false)
                {
                    SampleGetListViewModel selected;
                    foreach (SampleGetListViewModel item in StateContainer.AnimalSamples)
                    {
                        if (_selectedSamples.Any(x => x.SampleID == item.SampleID))
                        {
                            selected = _selectedSamples.First(x => x.SampleID == item.SampleID);

                            _selectedSamples.Remove(selected);
                        }
                    }
                }
                else
                {
                    foreach (SampleGetListViewModel item in StateContainer.AnimalSamples)
                    {
                        _selectedSamples.Add(item);
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
        ///
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        protected bool IsRecordSelected(SampleGetListViewModel item)
        {
            try
            {
                if (_selectedSamples != null && _selectedSamples.Any(x => x.SampleID == item.SampleID))
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
        ///
        /// </summary>
        /// <param name="value"></param>
        /// <param name="item"></param>
        protected void OnRecordSelectionChange(bool? value, SampleGetListViewModel item)
        {
            try
            {
                if (value == false)
                {
                    item = _selectedSamples.First(x => x.SampleID == item.SampleID);

                    _selectedSamples.Remove(item);
                }
                else
                {
                    _selectedSamples.Add(item);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Record Selection Events

        #region Copy Samples Events

        /// <summary>
        /// Copies selected sample items to new sample items
        /// </summary>
        /// <returns></returns>
        protected async Task OnCopySelectedSampleClick()
        {
            if (_selectedSamples is { Count: > 0 })
            {
                for (var i = 0; i < StateContainer.TotalNumber; i++)
                {
                    foreach (var item in _selectedSamples)
                    {
                        var selectedDiseaseList = StateContainer.AnimalSampleToDiseases?.Where(x => x.SampleID == item.SampleID).Select(d => d.DiseaseID).ToList();

                        var copiedSample = new SampleGetListViewModel()
                        {
                            SampleID = (StateContainer.PendingSaveAnimalSamples != null ? (StateContainer.PendingSaveAnimalSamples.Count(x => x.SampleID <= 0) + 1) * -1 : -1),
                            FarmID = item.FarmID,
                            FarmMasterID = item.FarmMasterID,
                            EIDSSFarmID = item.EIDSSFarmID,
                            SpeciesID = item.SpeciesID,
                            Species = item.Species,
                            SelectedDiseases = selectedDiseaseList,
                            DiseaseNames = item.DiseaseNames,
                            EIDSSLaboratoryOrLocalFieldSampleID = item.EIDSSLaboratoryOrLocalFieldSampleID,
                            EIDSSLaboratorySampleID = item.EIDSSLaboratorySampleID,
                            EIDSSLocalOrFieldSampleID = "(" +
                                                        Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)
                                                        + " " +
                                                        ((StateContainer.PendingSaveAnimalSamples?.Count(x => x.SampleID <= 0) ?? 0) + 1).ToString("0#") + ")",
                            AnimalName = item.AnimalName,
                            AnimalAgeTypeID = item.AnimalAgeTypeID,
                            AnimalAgeTypeName = item.AnimalAgeTypeName,
                            AnimalColor = item.AnimalColor,
                            AnimalGenderTypeID = item.AnimalGenderTypeID,
                            SampleTypeID = item.SampleTypeID,
                            SampleTypeName = item.SampleTypeName,
                            CollectionDate = item.CollectionDate,
                            SentToOrganizationID = item.SentToOrganizationID,
                            SentToOrganizationName = item.SentToOrganizationName,
                            MonitoringSessionID = StateContainer.SessionKey,
                            SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                            SpeciesTypeID = item.SpeciesTypeID,
                            SpeciesTypeName = item.SpeciesTypeName,
                            Comments = item.Comments,
                            RowAction = (int)RowActionTypeEnum.Insert,
                            RowStatus = (int)RowStatusTypeEnum.Active
                        };

                        if (StateContainer.ReportTypeID == ASSpeciesType.Livestock)
                        {
                            copiedSample.AnimalID = ((StateContainer.PendingSaveAnimalSamples?.Count(x => x.SampleID <= 0 && !string.IsNullOrEmpty(x.EIDSSAnimalID)) ?? 0) + 1) * -1;
                            copiedSample.EIDSSAnimalID = "(" +
                                Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)
                                + " " +
                                ((StateContainer.PendingSaveAnimalSamples?.Count(x => x.SampleID <= 0 && !string.IsNullOrEmpty(x.EIDSSAnimalID)) ?? 0) + 1).ToString("0#") + ")";
                        }

                        StateContainer.AnimalSamples?.Add(copiedSample);
                        _animalSampleNewRecordCount++;

                        // create the records for selected diseases
                        BuildSampleToDiseaseList(copiedSample);

                        TogglePendingSaveAnimalSamples(copiedSample, null);
                    }
                }
            }

            await AnimalSampleGrid.Reload().ConfigureAwait(false);
        }

        private void BuildSampleToDiseaseList(SampleGetListViewModel sample)
        {
            StateContainer.AnimalSampleToDiseases ??= new List<SampleToDiseaseGetListViewModel>();
            if (sample.SelectedDiseases is null) return;
            foreach (var diseaseId in sample.SelectedDiseases)
            {
                var sampleToDisease = StateContainer.AnimalSampleToDiseases.FirstOrDefault(x =>
                    x.SampleID == sample.SampleID
                    && x.DiseaseID == diseaseId);

                if (sampleToDisease is null)
                {
                    // new sample to disease record
                    sampleToDisease = new SampleToDiseaseGetListViewModel()
                    {
                        MonitoringSessionToMaterialID =
                            (StateContainer.AnimalSampleToDiseases.Count + 1) * -1,
                        MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault(),
                        SampleID = sample.SampleID,
                        SampleTypeID = sample.SampleTypeID,
                        DiseaseID = diseaseId,
                        DiseaseName = StateContainer.DiseaseSpeciesSamples.FirstOrDefault(x => x.DiseaseID == diseaseId)?.DiseaseName,
                        RowStatus = (int)RowStatusTypeEnum.Active,
                        RowAction = (int)RowActionTypeEnum.Insert
                    };

                    StateContainer.AnimalSampleToDiseases.Add(sampleToDisease);
                    TogglePendingSaveAnimalSampleToDiseases(sampleToDisease, null);
                }
                else
                {
                    // update existing record
                    var clonedRecord = sampleToDisease.ShallowCopy();
                    clonedRecord.SampleID = sample.SampleID;
                    clonedRecord.SampleTypeID = sample.SampleTypeID;
                    clonedRecord.DiseaseID = diseaseId;
                    clonedRecord.DiseaseName = sampleToDisease.DiseaseName;
                    clonedRecord.RowAction = (int)RowActionTypeEnum.Update;

                    var index = StateContainer.AnimalSampleToDiseases.IndexOf(sampleToDisease);
                    StateContainer.AnimalSampleToDiseases[index] = clonedRecord;
                    TogglePendingSaveAnimalSampleToDiseases(clonedRecord, sampleToDisease);
                }
            }

            // find all the diseases for this sample that were unselected
            // and mark them for soft delete
            var selectedItems = sample.SelectedDiseases.ToList();
            var unselectedItems = StateContainer.AnimalSampleToDiseases.Where(x => !selectedItems.Contains(x.DiseaseID)
                && x.SampleID == sample.SampleID
                && x.SampleTypeID == sample.SampleTypeID).ToList();
            foreach (var item in unselectedItems)
            {
                var record = item.ShallowCopy();
                record.RowAction = (int)RowActionTypeEnum.Update;
                record.RowStatus = (int)RowStatusTypeEnum.Inactive;

                StateContainer.AnimalSampleToDiseases.Remove(item);
                TogglePendingSaveAnimalSampleToDiseases(record, item);
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveAnimalSampleToDiseases(SampleToDiseaseGetListViewModel record, SampleToDiseaseGetListViewModel originalRecord)
        {
            StateContainer.PendingSaveAnimalSampleToDiseases ??= new List<SampleToDiseaseGetListViewModel>();

            if (StateContainer.PendingSaveAnimalSampleToDiseases.Any(x => x.MonitoringSessionToMaterialID == record.MonitoringSessionToMaterialID))
            {
                var index = StateContainer.PendingSaveAnimalSampleToDiseases.IndexOf(originalRecord);
                StateContainer.PendingSaveAnimalSampleToDiseases[index] = record;
            }
            else
            {
                StateContainer.PendingSaveAnimalSampleToDiseases.Add(record);
            }
        }

        #endregion Copy Samples Events

        #region Set Sample Button States

        private void SetSampleButtonStates()
        {
            // if the report is not saved, don't enable the print button
            PrintSampleButtonDisabled = StateContainer.SessionKey <= 0;

            // if there are no farms, don't allow sample edits
            if (StateContainer.Farms == null || StateContainer.Farms.Count == 0)
            {
                AddSampleButtonDisabled = true;
                DeleteSampleButtonDisabled = true;
                CopySampleButtonDisabled = true;
            }
            else
            {
                AddSampleButtonDisabled = false;
                DeleteSampleButtonDisabled = false;
                CopySampleButtonDisabled = false;
            }
        }

        #endregion Set Sample Button States

        #endregion Methods
    }
}