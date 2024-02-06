#region Usings

using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Veterinary;
using EIDSS.Web.Components.Veterinary.DiseaseReport;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case.Veterinary
{
    public class ClinicalInformationSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ClinicalInformationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Case { get; set; }
        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsClinicalInformationLoading { get; set; }
        public bool IsAnimalsLoading { get; set; }
        protected FlexForm.FlexForm ClinicalInvestigation { get; set; }
        public IEnumerable<FarmInventoryGetListViewModel> Species { get; set; }
        public long? SpeciesId { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> CopiedAnswers { get; set; }
        public bool IsReview { get; set; }

        protected RadzenDataGrid<FarmInventoryGetListViewModel> ClinicalInvestigationsGrid { get; set; }
        protected RadzenDataGrid<AnimalGetListViewModel> AnimalsGrid { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        public IEnumerable<BaseReferenceViewModel> StatusTypes { get; set; }

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

        private const string DefaultSortColumn = "EIDSSAnimalID";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public ClinicalInformationSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected ClinicalInformationSectionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            await LoadClinicalInvestigationData();

            await base.OnInitializedAsync();
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
                IsClinicalInformationLoading = true;
                IsAnimalsLoading = true;

                await JsRuntime.InvokeVoidAsync("ClinicalInformationSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));

                await GetStatusTypes(new LoadDataArgs());

                await LoadClinicalInvestigationData();
                await LoadAnimalData(new LoadDataArgs());

                if (IsReview)
                {
                    ClinicalInvestigation?.Render();
                }
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task LoadClinicalInvestigationData()
        {
            if (Model.FarmInventory is null || Model.FarmInventory.Count == 0)
            {
                IsClinicalInformationLoading = true;

                Model.FarmInventory = await GetFarmInventory(Model.DiseaseReportID, Model.FarmMasterID, Model.FarmID);

                foreach (var farmInventoryItem in Model.FarmInventory)
                {
                    if (farmInventoryItem.RecordType != RecordTypeConstants.Species) continue;

                    if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest is not null) continue;
                    FlexFormQuestionnaireGetRequestModel request = new()
                    {
                        idfObservation = farmInventoryItem.ObservationID,
                        idfsDiagnosis = Model.DiseaseID,
                        idfsFormType = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (long) FlexibleFormTypeEnum.AvianSpeciesClinicalInvestigation
                            : (long) FlexibleFormTypeEnum.LivestockSpeciesClinicalInvestigation,
                        LangID = GetCurrentLanguage()
                    };
                    farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest = request;
                }

                if (Model.FarmInventory.Any(x => x.RecordType == RecordTypeConstants.Species))
                    Species = Model.FarmInventory.Where(x => x.RecordType == RecordTypeConstants.Species);
                if (Model.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Species) == 1)
                    SpeciesId = Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species).SpeciesID;
            }

            IsClinicalInformationLoading = false;
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task LoadAnimalData(LoadDataArgs args)
        {
            try
            {
                AnimalsGrid ??= new RadzenDataGrid<AnimalGetListViewModel>();

                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (AnimalsGrid.PageSize != 0)
                    pageSize = AnimalsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsAnimalsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.Animals is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        IsAnimalsLoading = true;

                    if (IsAnimalsLoading || !IsNullOrEmpty(args.OrderBy))
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

                        Model.Animals = await GetAnimals(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                            .ConfigureAwait(false);
                        _databaseQueryCount = !Model.Animals.Any() ? 0 : Model.Animals.First().TotalRowCount;
                    }
                    else if (Model.Animals != null)
                    {
                        _databaseQueryCount = Model.Animals.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.AnimalID < 0)
                            ? 0
                            : Model.Animals.First(x => x.AnimalID > 0).TotalRowCount;
                    }

                    if (Model.Animals != null)
                        for (var index = 0; index < Model.Animals.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.Animals[index].AnimalID < 0)
                            {
                                Model.Animals.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveAnimals == null || index < 0 || Model.Animals.Count == 0 ||
                                Model.PendingSaveAnimals.All(x =>
                                    x.AnimalID != Model.Animals[index].AnimalID)) continue;
                            {
                                if (Model.PendingSaveAnimals.First(x => x.AnimalID == Model.Animals[index].AnimalID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.Animals.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.Animals[index] = Model.PendingSaveAnimals.First(x =>
                                        x.AnimalID == Model.Animals[index].AnimalID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newRecordCount;

                    if (_newRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PendingSaveAnimals != null &&
                            Model.PendingSaveAnimals.Any(x => x.AnimalID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveAnimals.Where(x => x.AnimalID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _lastDatabasePage;
                            var quotientNewRecords = Math.DivRem(Count, pageSize, out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = remainderDatabaseQuery < newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                pageSize = remainderNewRecords;
                                Model.Animals?.Clear();
                            }
                            else
                            {
                                Model.Animals?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.Animals?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.Animals != null)
                            Model.Animals = Model.Animals.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _lastPage = page;
                }

                IsAnimalsLoading = false;
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
        protected void TogglePendingSaveAnimals(AnimalGetListViewModel record, AnimalGetListViewModel originalRecord)
        {
            Model.PendingSaveAnimals ??= new List<AnimalGetListViewModel>();

            if (Model.PendingSaveAnimals.Any(x => x.AnimalID == record.AnimalID))
            {
                var index = Model.PendingSaveAnimals.IndexOf(originalRecord);
                Model.PendingSaveAnimals[index] = record;
            }
            else
            {
                Model.PendingSaveAnimals.Add(record);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="species"></param>
        protected void OnRowExpand(FarmInventoryGetListViewModel species)
        {
            try
            {
                ClinicalInvestigation ??= new FlexForm.FlexForm();
                ClinicalInvestigation.FlexFormClient = FlexFormClient;
                //ClinicalInvestigation.SetRequestParameter(species.SpeciesClinicalInvestigationFlexFormRequest);

                SpeciesId = species.SpeciesID;

                ClinicalInvestigation.SetFormDisabled(IsReview);

                ClinicalInvestigation.Render();

                StateHasChanged();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSpecies(LoadDataArgs args)
        {
            Species = Model.FarmInventory.Where(x =>
                x.RecordType == RecordTypeConstants.Species && x.RowStatus == (int) RowStatusTypeEnum.Active);

            if (!IsNullOrEmpty(args.Filter))
                Species =
                    Model.FarmInventory.Where(c =>
                        c.Species is not null &&
                        c.Species.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetStatusTypes(LoadDataArgs args)
        {
            try
            {
                StatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.OutbreakCaseStatus, HACodeList.AllHACode);

                if (!IsNullOrEmpty(args.Filter))
                    StatusTypes = StatusTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Species Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnSpeciesTypeChange(object value)
        {
            try
            {
                if (value is not null)
                {
                    var inventory = value as FarmInventoryGetListViewModel;

                    Model.FarmInventory.First(x => inventory != null && x.RecordID == inventory.RecordID)
                        .SpeciesTypeName = inventory is
                    {
                        SpeciesTypeID: null
                    }
                        ? null
                        : SpeciesTypes.First(x => inventory != null && x.IdfsBaseReference == inventory.SpeciesTypeID)
                            .Name;
                }

                await ValidateSection().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Status Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnStatusTypeChange(object value)
        {
            try
            {
                if (value is not null)
                {
                    var inventory = value as FarmInventoryGetListViewModel;

                    Model.FarmInventory.First(x => inventory != null && x.RecordID == inventory.RecordID)
                        .OutbreakCaseStatusTypeID = inventory is {OutbreakCaseStatusTypeID: null}
                        ? null
                        : StatusTypes.First(x => inventory != null && x.IdfsBaseReference == inventory.OutbreakCaseStatusTypeID)
                            .IdfsBaseReference;
                    Model.FarmInventory.First(x => inventory != null && x.RecordID == inventory.RecordID)
                        .OutbreakCaseStatusTypeName = inventory is {OutbreakCaseStatusTypeID: null}
                        ? null
                        : StatusTypes.First(x => inventory != null && x.IdfsBaseReference == inventory.OutbreakCaseStatusTypeID)
                            .Name;
                }

                await ValidateSection().ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Copy Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCopyClick()
        {
            await ClinicalInvestigation.CollectAnswers();
            ClinicalInvestigation.Render();

            CopiedAnswers = ClinicalInvestigation.Answers;
        }

        #endregion

        #region Paste Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected void OnPasteClick()
        {
            Model.FarmInventory.First(x => x.SpeciesID == SpeciesId).SpeciesClinicalInvestigationFlexFormAnswers =
                CopiedAnswers;

            ClinicalInvestigation.Answers = Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                .SpeciesClinicalInvestigationFlexFormAnswers;
            ClinicalInvestigation.Render();
        }

        #endregion

        #region Clear Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected void OnClearClick()
        {
            ClinicalInvestigation.ClearForm();
        }

        #endregion

        #region Add Animal Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddAnimalClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<Animal>(
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportAnimalDetailsModalHeading),
                    new Dictionary<string, object> {{"Model", new AnimalGetListViewModel()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result is AnimalGetListViewModel model)
                {
                    _newRecordCount += 1;

                    TogglePendingSaveAnimals(model, null);

                    await AnimalsGrid.Reload().ConfigureAwait(false);
                }
                else
                {
                    IsAnimalsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Animal Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="animal"></param>
        protected async Task OnEditAnimalClick(object animal)
        {
            try
            {
                if (((AnimalGetListViewModel)animal).ClinicalSignsIndicator == (long)YesNoUnknownEnum.Yes &&
                    ((AnimalGetListViewModel)animal).ClinicalSignsFlexFormRequest is { idfsFormTemplate: { } })
                {
                    var idfsFormTemplate = ((AnimalGetListViewModel)animal).ClinicalSignsFlexFormRequest
                        .idfsFormTemplate;
                    if (idfsFormTemplate != null)
                    {
                        FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                        {
                            Answers = ((AnimalGetListViewModel)animal).ClinicalSignsObservationParameters,
                            idfsFormTemplate = (long)idfsFormTemplate,
                            idfObservation = ((AnimalGetListViewModel)animal).ClinicalSignsFlexFormRequest.idfObservation,
                            User = ((AnimalGetListViewModel)animal).ClinicalSignsFlexFormRequest.User
                        };
                        var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                        ((AnimalGetListViewModel)animal).ClinicalSignsFlexFormRequest.idfObservation =
                            flexFormResponse.idfObservation;
                        ((AnimalGetListViewModel)animal).ObservationID = flexFormResponse.idfObservation;

                        await InvokeAsync(StateHasChanged);

                        ((AnimalGetListViewModel)animal).ObservationID = flexFormResponse.idfObservation;
                    }
                }

                var result = await DiagService.OpenAsync<Animal>(
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportAnimalDetailsModalHeading),
                    new Dictionary<string, object>
                        {{"Model", ((AnimalGetListViewModel) animal).ShallowCopy()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true
                    });

                if (result is AnimalGetListViewModel model)
                {
                    if (Model.Animals.Any(x =>
                            x.AnimalID == ((AnimalGetListViewModel) result).AnimalID))
                    {
                        var index = Model.Animals.IndexOf((AnimalGetListViewModel) animal);
                        Model.Animals[index] = model;

                        TogglePendingSaveAnimals(model, (AnimalGetListViewModel) animal);
                    }

                    await AnimalsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Animal Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="animal"></param>
        protected async Task OnDeleteAnimalClick(object animal)
        {
            try
            {
                if (await CanDeleteAnimalRecord(((AnimalGetListViewModel) animal).AnimalID))
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (Model.Animals.Any(x => x.AnimalID == ((AnimalGetListViewModel) animal).AnimalID))
                            {
                                if (((AnimalGetListViewModel) animal).AnimalID <= 0)
                                {
                                    Model.Animals.Remove((AnimalGetListViewModel) animal);
                                    Model.PendingSaveAnimals.Remove((AnimalGetListViewModel) animal);
                                    _newRecordCount--;
                                }
                                else
                                {
                                    result = ((AnimalGetListViewModel) animal).ShallowCopy();
                                    result.RowAction = (int) RowActionTypeEnum.Delete;
                                    result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                    Model.Animals.Remove((AnimalGetListViewModel) animal);

                                    TogglePendingSaveAnimals(result, (AnimalGetListViewModel) animal);
                                }
                            }

                            await AnimalsGrid.Reload().ConfigureAwait(false);

                            DiagService.Close(result);
                        }
                }
                else
                {
                    await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage, null);

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
        /// <param name="animalId"></param>
        /// <returns></returns>
        private async Task<bool> CanDeleteAnimalRecord(long animalId)
        {
            await InvokeAsync(StateHasChanged);

            return !Model.Samples.Any(x => x.AnimalID == animalId && x.RowStatus == (int) RowStatusTypeEnum.Active);
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            Model.AnimalsSectionValidIndicator = true;

            if (!Model.AnimalsSectionValidIndicator)
                return Model.AnimalsSectionValidIndicator = true;

            foreach (var farmInventoryItem in Model.FarmInventory)
            {
                if (farmInventoryItem.RecordType != RecordTypeConstants.Species) continue;

                if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormAnswers is not null)
                {
                    if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate is null)
                    {
                        var questions =
                            await FlexFormClient.GetQuestionnaire(farmInventoryItem
                                .SpeciesClinicalInvestigationFlexFormRequest);

                        if (questions.Count > 0)
                            farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate =
                                questions[0].idfsFormTemplate;
                    }

                    if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate != null && farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate != 0)
                    {
                        FlexFormActivityParametersSaveRequestModel request = new()
                        {
                            Answers = farmInventoryItem.SpeciesClinicalInvestigationObservationParameters,
                            idfsFormTemplate = (long) farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest
                                .idfsFormTemplate,
                            idfObservation = farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest
                                .idfObservation,
                            User = farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.User
                        };

                        var response = await FlexFormClient.SaveAnswers(request);
                        farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfObservation =
                            response.idfObservation;
                        farmInventoryItem.ObservationID = response.idfObservation;
                    }
                }

                await InvokeAsync(StateHasChanged);
            }

            Model.Animals ??= new List<AnimalGetListViewModel>();

            foreach (var animal in Model.Animals)
            {
                if (animal.ClinicalSignsIndicator != (long) YesNoUnknownEnum.Yes
                    || animal.ClinicalSignsFlexFormAnswers is null) continue;
                if (animal.ClinicalSignsFlexFormRequest.idfsFormTemplate != null)
                {
                    FlexFormActivityParametersSaveRequestModel flexFormRequest = new()
                    {
                        Answers = animal.ClinicalSignsObservationParameters,
                        idfsFormTemplate = (long) animal.ClinicalSignsFlexFormRequest.idfsFormTemplate,
                        idfObservation = animal.ClinicalSignsFlexFormRequest.idfObservation,
                        User = animal.ClinicalSignsFlexFormRequest.User
                    };
                    var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                    animal.ClinicalSignsFlexFormRequest.idfObservation = flexFormResponse.idfObservation;
                    animal.ObservationID = flexFormResponse.idfObservation;

                    await InvokeAsync(StateHasChanged);

                    animal.ObservationID = flexFormResponse.idfObservation;
                }
            }

            return Model.AnimalsSectionValidIndicator = true;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            //TODO: change validation once flex form is ready to go.
            Model.AnimalsSectionValidIndicator = true; // Form.EditContext.Validate();

            return Model.AnimalsSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection(bool isReview)
        {
            await InvokeAsync(StateHasChanged);

            IsReview = isReview;

            await LoadClinicalInvestigationData();

            await GetSpecies(new LoadDataArgs());

            await GetStatusTypes(new LoadDataArgs());

            if (Model.ReportCategoryTypeID != (long) CaseTypeEnum.Livestock) return;
            Model.Animals = null;
            await AnimalsGrid.Reload();

            if (SpeciesId is not null)
            {
                if (ClinicalInvestigation is not null)
                {
                    var response = Task.Run(() => ClinicalInvestigation.CollectAnswers(), _token);
                    response.Wait(_token);
                    Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                        .SpeciesClinicalInvestigationFlexFormRequest
                        .idfsFormTemplate = response.Result.idfsFormTemplate;
                    Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                        .SpeciesClinicalInvestigationFlexFormAnswers = ClinicalInvestigation.Answers;
                    Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                        .SpeciesClinicalInvestigationObservationParameters = response.Result.Answers;
                    Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                            .SpeciesClinicalInvestigationFlexFormRequest.ReviewAnswers =
                        ClinicalInvestigation.Answers;

                    if (IsReview)
                    {
                        ClinicalInvestigation.Answers = Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                            .SpeciesClinicalInvestigationFlexFormAnswers;
                        ClinicalInvestigation.SetFormDisabled(true);
                        ClinicalInvestigation.Render();
                    }
                    else
                    {
                        ClinicalInvestigation.SetFormDisabled(false);
                        ClinicalInvestigation.Render();
                    }

                    await InvokeAsync(StateHasChanged);
                }
            }
            else
            {
                if (Model.FarmInventory is not null &&
                    Model.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Species) == 1)
                {
                    SpeciesId = Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                        .SpeciesID;

                    if (ClinicalInvestigation is not null)
                    {
                        ClinicalInvestigation.SetFormDisabled(IsReview);

                        ClinicalInvestigation.SetRequestParameter(Model.FarmInventory
                            .First(x => x.SpeciesID == SpeciesId).SpeciesClinicalInvestigationFlexFormRequest);
                    }
                }
            }
        }

        #endregion

        #endregion
    }
}