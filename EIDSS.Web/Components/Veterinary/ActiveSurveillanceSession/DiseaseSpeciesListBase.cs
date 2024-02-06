using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.Extensions.Localization;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DiseaseSpeciesListBase : SurveillanceSessionBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        protected IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected IBaseReferenceClient BaseReferenceClient { get; set; }

        [Inject]
        private ILogger<DiseaseSpeciesListBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        protected bool IsLoading;
        protected bool EditIsDisabled;
        protected bool DeleteIsDisabled;
        protected bool AddButtonIsDisabled;
        protected int DiseaseSpeciesLastPage;
        protected int PreviousPageSize;
        protected RadzenDataGrid<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel> SessionDiseaseSpeciesSampleGrid;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #region Constants

        private const string DefaultSortColumn = "DiseaseName";

        #endregion Constants

        #endregion Globals

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // reset the cancellation token
            _source = new();
            _token = _source.Token;

            StateContainer.OnCampaignLinked += async () => await OnCampaignLinked();

            await base.OnInitializedAsync();
        }

        protected override Task OnAfterRenderAsync(bool firstRender)
        {
            // do not allow edit of disease / species / samples
            if (!StateContainer.ActiveSurveillanceSessionPermissions.Write
                || StateContainer.HasLinkedCampaign)
            {
                EditIsDisabled = true;
                AddButtonIsDisabled = true;
            }
            else
            {
                EditIsDisabled = false;
                AddButtonIsDisabled = false;
            }

            if (StateContainer.SessionKey is > 0)
            {
                EditIsDisabled = true;
            }

            // do not allow delete of disease / species / samples
            if ((StateContainer.AnimalSamples is { Count: > 0 }
             || StateContainer.AnimalSamplesAggregate is { Count: > 0 })
             || StateContainer.HasLinkedCampaign)
            {
                if (!DeleteIsDisabled)
                {
                    DeleteIsDisabled = true;
                    SessionDiseaseSpeciesSampleGrid.Reload();
                }
            }
            else
            {
                if (DeleteIsDisabled)
                {
                    DeleteIsDisabled = false;
                    SessionDiseaseSpeciesSampleGrid.Reload();
                }
            }
            return base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            StateContainer.OnCampaignLinked -= async () => await OnCampaignLinked();
        }

        private async Task OnCampaignLinked()
        {
            if (SessionDiseaseSpeciesSampleGrid is not null)
                await SessionDiseaseSpeciesSampleGrid.Reload();
        }

        protected async Task OnAddDiseaseSpeciesSampleClick()
        {
            var item = new VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel();
            StateContainer.DiseaseSpeciesNewRecordCount++;
            StateContainer.DiseaseSpeciesCount = StateContainer.DiseaseSpeciesDatabaseQueryCount + StateContainer.DiseaseSpeciesNewRecordCount;
            await SessionDiseaseSpeciesSampleGrid.InsertRow(item);
        }

        protected async Task OnCreateRow(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            if (StateContainer.DiseaseSpeciesSamples.Any(x => x.DiseaseID == item.DiseaseID
                                                              && x.SampleTypeID == item.SampleTypeID
                                                              && x.SpeciesTypeID == item.SpeciesTypeID
                                                              && x.MonitoringSessionToDiseaseID != item.MonitoringSessionToDiseaseID))
            {
                StateContainer.DiseaseSpeciesNewRecordCount--;
                StateContainer.DiseaseSpeciesCount = StateContainer.DiseaseSpeciesDatabaseQueryCount + StateContainer.DiseaseSpeciesNewRecordCount;
                await ShowInvalidDiseaseSpeciesSampleDialog(item);
            }
            else
            {
                var disease = StateContainer.Diseases.Find(x => x.DiseaseID == item.DiseaseID);
                if (disease != null)
                {
                    item.DiseaseName = disease.DiseaseName;
                    item.DiseaseUsingType = disease.UsingType;
                }

                var speciesName = StateContainer.Species.Find(x => x.idfsBaseReference == item.SpeciesTypeID);
                if (speciesName != null) item.SpeciesTypeName = speciesName.strName;

                var sampleTypeName = StateContainer.SampleTypes.Find(x => x.idfsSampleType == item.SampleTypeID);
                if (sampleTypeName != null) item.SampleTypeName = sampleTypeName.strSampleType;

                if (StateContainer.DiseaseSpeciesSamples.Any())
                {
                    int.TryParse(StateContainer.DiseaseSpeciesSamples.Max(t => t.RowNumber).ToString(), out int maxRowNumber);
                    maxRowNumber++;
                    item.RowNumber = maxRowNumber;
                }
                else
                {
                    item.RowNumber = 1;
                }

                item.RowAction = (int)RowActionTypeEnum.Insert;
                item.RowStatus = (int)RowStatusTypeEnum.Active;
                item.MonitoringSessionToDiseaseID = (StateContainer.DiseaseSpeciesSamples.Count + 1) * -1;

                StateContainer.DiseaseSpeciesSamples.Add(item);

                if (StateContainer.DiseaseSpeciesSamples is not null)
                {
                    StateContainer.DiseaseString = String.Empty;
                    foreach (var dss in StateContainer.DiseaseSpeciesSamples)
                    {
                        var separator = !string.IsNullOrEmpty(StateContainer.DiseaseString) ? ", " : string.Empty;
                        StateContainer.DiseaseString += $"{separator}{dss.DiseaseName}";
                    }
                }

                TogglePendingSaveDiseaseSpecies(item, null);
            }
        }

        protected async Task OnUpdateRow(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            if (StateContainer.DiseaseSpeciesSamples.Any(x => x.DiseaseID == item.DiseaseID
                                                              && x.SampleTypeID == item.SampleTypeID
                                                              && x.SpeciesTypeID == item.SpeciesTypeID
                                                              && x.MonitoringSessionToDiseaseID != item.MonitoringSessionToDiseaseID))
            {
                await ShowInvalidDiseaseSpeciesSampleDialog(item);
            }
            else
            {
                var disease = StateContainer.Diseases.Find(x => x.DiseaseID == item.DiseaseID);
                if (disease != null)
                {
                    item.DiseaseName = disease.DiseaseName;
                    item.DiseaseUsingType = disease.UsingType;
                }

                var speciesName = StateContainer.Species.Find(x => x.idfsBaseReference == item.SpeciesTypeID);
                if (speciesName != null) item.SpeciesTypeName = speciesName.strName;

                var sampleTypeName = StateContainer.SampleTypes.Find(x => x.idfsSampleType == item.SampleTypeID);
                if (sampleTypeName != null) item.SampleTypeName = sampleTypeName.strSampleType;

                item.RowAction = (int)RowActionTypeEnum.Update;

                if (StateContainer.DiseaseSpeciesSamples.Any(x =>
                        x.MonitoringSessionToDiseaseID == item.MonitoringSessionToDiseaseID))
                {
                    int index = StateContainer.DiseaseSpeciesSamples.IndexOf(item);
                    StateContainer.DiseaseSpeciesSamples[index] = item;

                    StateContainer.DiseaseString = String.Empty;
                    foreach (var dss in StateContainer.DiseaseSpeciesSamples)
                    {
                        var separator = !string.IsNullOrEmpty(StateContainer.DiseaseString) ? ", " : string.Empty;
                        StateContainer.DiseaseString += $"{separator}{dss.DiseaseName}";
                    }

                    TogglePendingSaveDiseaseSpecies(item, item);
                }
            }
        }

        protected async Task OnEditDiseaseSpeciesClick(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            await SessionDiseaseSpeciesSampleGrid.EditRow(item);
        }

        protected async Task OnDeleteDiseaseSpeciesClick(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);
            if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                if (item.MonitoringSessionToDiseaseID <= 0)
                {
                    StateContainer.DiseaseSpeciesSamples.Remove(item);
                    if (StateContainer.PendingSaveDiseaseSpeciesSamples != null && StateContainer.PendingSaveDiseaseSpeciesSamples.Count > 0)
                    {
                        StateContainer.PendingSaveDiseaseSpeciesSamples.Remove(item);
                    }
                    StateContainer.DiseaseSpeciesNewRecordCount--;
                }
                else
                {
                    var deletedRecord = item.ShallowCopy();
                    deletedRecord.RowAction = (int)RowActionTypeEnum.Delete;
                    deletedRecord.RowStatus = (int)RowStatusTypeEnum.Inactive;
                    StateContainer.DiseaseSpeciesSamples.Remove(item);
                    StateContainer.DiseaseSpeciesCount--;

                    TogglePendingSaveDiseaseSpecies(deletedRecord, item);
                }

                await SessionDiseaseSpeciesSampleGrid.Reload();
            }
            else
            {
                DiagService.Close();
            }
        }

        protected async Task OnSaveDiseaseSpeciesClick(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            await SessionDiseaseSpeciesSampleGrid.UpdateRow(item);
        }

        protected void OnCancelDiseaseSpeciesEditClick(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            SessionDiseaseSpeciesSampleGrid.CancelEditRow(item);
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveDiseaseSpecies(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel record,
            VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel originalRecord)
        {
            StateContainer.PendingSaveDiseaseSpeciesSamples ??=
                new List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>();

            if (StateContainer.PendingSaveDiseaseSpeciesSamples.Any(x => x.MonitoringSessionToDiseaseID == record.MonitoringSessionToDiseaseID))
            {
                var index = StateContainer.PendingSaveDiseaseSpeciesSamples.IndexOf(originalRecord);
                StateContainer.PendingSaveDiseaseSpeciesSamples[index] = record;
            }
            else
            {
                StateContainer.PendingSaveDiseaseSpeciesSamples.Add(record);
            }
        }

        private async Task ShowInvalidDiseaseSpeciesSampleDialog(VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel item)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                { "DialogName", "CampaignInvalid" },
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DuplicateRecordsAreNotAllowedMessage) }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                SessionDiseaseSpeciesSampleGrid.CancelEditRow(item);
            }
        }

        protected async Task LoadDiseaseSpeciesSampleGrid(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (SessionDiseaseSpeciesSampleGrid.PageSize != 0)
                    pageSize = SessionDiseaseSpeciesSampleGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.DiseaseSpeciesSamples is null ||
                        DiseaseSpeciesLastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
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

                        var request = new VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel()
                        {
                            LanguageID = GetCurrentLanguage(),
                            MonitoringSessionID = StateContainer.SessionKey.GetValueOrDefault()
                        };
                        StateContainer.DiseaseSpeciesSamples =
                            await VeterinaryClient.GetActiveSurveillanceSessionDiseaseSpeciesListAsync(request, _token)
                                .ConfigureAwait(false);
                        if (page == 1)
                            StateContainer.DiseaseSpeciesDatabaseQueryCount = !StateContainer.DiseaseSpeciesSamples.Any() ? 0 : StateContainer.DiseaseSpeciesSamples.First().RecordCount;
                    }
                    else if (StateContainer.DiseaseSpeciesSamples != null)
                    {
                        StateContainer.DiseaseSpeciesDatabaseQueryCount = StateContainer.DiseaseSpeciesSamples.All(x =>
                            x.RowStatus == (int)RowStatusTypeEnum.Inactive || x.MonitoringSessionToDiseaseID < 0)
                            ? 0
                            : StateContainer.DiseaseSpeciesSamples.First(x => x.MonitoringSessionToDiseaseID > 0).RecordCount;
                    }

                    if (StateContainer.DiseaseSpeciesSamples != null)
                        for (var index = 0; index < StateContainer.DiseaseSpeciesSamples.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (StateContainer.DiseaseSpeciesSamples[index].MonitoringSessionToDiseaseID < 0)
                            {
                                StateContainer.DiseaseSpeciesSamples.RemoveAt(index);
                                index--;
                            }

                            if (StateContainer.PendingSaveDiseaseSpeciesSamples == null || index < 0 || StateContainer.DiseaseSpeciesSamples.Count == 0 ||
                                StateContainer.PendingSaveDiseaseSpeciesSamples.All(x =>
                                    x.MonitoringSessionToDiseaseID != StateContainer.DiseaseSpeciesSamples[index].MonitoringSessionToDiseaseID)) continue;
                            {
                                if (StateContainer.PendingSaveDiseaseSpeciesSamples
                                        .First(x => x.MonitoringSessionToDiseaseID == StateContainer.DiseaseSpeciesSamples[index].MonitoringSessionToDiseaseID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.DiseaseSpeciesSamples.RemoveAt(index);
                                    StateContainer.DiseaseSpeciesDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    StateContainer.DiseaseSpeciesSamples[index] = StateContainer.PendingSaveDiseaseSpeciesSamples.First(x =>
                                        x.MonitoringSessionToDiseaseID == StateContainer.DiseaseSpeciesSamples[index].MonitoringSessionToDiseaseID);
                                }
                            }
                        }

                    StateContainer.DiseaseSpeciesCount = StateContainer.DiseaseSpeciesDatabaseQueryCount + StateContainer.DiseaseSpeciesNewRecordCount;

                    if (StateContainer.DiseaseSpeciesNewRecordCount > 0)
                    {
                        StateContainer.DiseaseSpeciesLastDatabasePage = Math.DivRem(StateContainer.DiseaseSpeciesDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || StateContainer.DiseaseSpeciesLastDatabasePage == 0)
                            StateContainer.DiseaseSpeciesLastDatabasePage += 1;

                        if (page >= StateContainer.DiseaseSpeciesLastDatabasePage && StateContainer.PendingSaveDiseaseSpeciesSamples != null &&
                            StateContainer.PendingSaveDiseaseSpeciesSamples.Any(x => x.MonitoringSessionToDiseaseID < 0))
                        {
                            var newRecordsPendingSave =
                               StateContainer.PendingSaveDiseaseSpeciesSamples.Where(x => x.MonitoringSessionToDiseaseID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - StateContainer.DiseaseSpeciesLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(StateContainer.DiseaseSpeciesCount, pageSize, out var remainderNewRecords);

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
                                StateContainer.DiseaseSpeciesSamples?.Clear();
                            }
                            else
                            {
                                StateContainer.DiseaseSpeciesSamples?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                StateContainer.DiseaseSpeciesSamples?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (StateContainer.DiseaseSpeciesSamples != null)
                            StateContainer.DiseaseSpeciesSamples = StateContainer.DiseaseSpeciesSamples.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    DiseaseSpeciesLastPage = page;
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnDiseaseChange(object diseaseID)
        {
            await GetSampleTypesByDiseaseAsync(new LoadDataArgs(), Convert.ToInt64(diseaseID));
        }

        protected async Task GetDiseasesAsync(LoadDataArgs args)
        {
            var request = new FilteredDiseaseRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                AccessoryCode = StateContainer.HACode ?? EIDSSConstants.HACodeList.LiveStockAndAvian,
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                UsingType = null,
                AdvancedSearchTerm = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
            };
            StateContainer.Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request);

            // there is a linked campaign so filter the diseases
            if (StateContainer.CampaignDiseaseIDs.Count > 0)
            {
                StateContainer.HasLinkedCampaign = true;
                var filteredDiseases = StateContainer.Diseases.Where(d =>
                                        (StateContainer.CampaignDiseaseIDs.Any(c => c.Value == d.DiseaseID)));
                StateContainer.Diseases = filteredDiseases.ToList();
            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSpeciesAsync(LoadDataArgs args)
        {
            var request = new BaseReferenceAdvancedListRequestModel()
            {
                advancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter,
                intHACode = StateContainer.HACode ?? EIDSSConstants.HACodeList.LiveStockAndAvian,
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 99999,
                ReferenceTypeName = EIDSSConstants.BaseReferenceConstants.SpeciesList,
                SortColumn = "intOrder",
                SortOrder = "asc"
            };
            StateContainer.Species = await CrossCuttingClient.GetBaseReferenceAdvanceList(request);

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetSampleTypesByDiseaseAsync(LoadDataArgs args, long? diseaseId)
        {
            var request = new DiseaseSampleTypeByDiseaseRequestModel()
            {
                idfsDiagnosis = diseaseId.GetValueOrDefault(),
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 99999,
                SortOrder = "asc",
                SortColumn = "intOrder"
            };
            StateContainer.SampleTypes = await ConfigurationClient.GetDiseaseSampleTypeByDiseasePaged(request);

            // filter by filter criteria
            if (!string.IsNullOrEmpty(args.Filter))
            {
                StateContainer.SampleTypes = StateContainer.SampleTypes?.Where(s => s.strSampleType.StartsWith(args.Filter)).ToList();
            }

            await InvokeAsync(StateHasChanged);
        }
    }
}