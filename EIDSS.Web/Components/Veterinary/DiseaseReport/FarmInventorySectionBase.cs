#region Usings

using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
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

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class FarmInventorySectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmInventorySectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public CaseGetDetailViewModel Case { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public EventCallback TypeOfCaseChangeEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected List<BaseReferenceViewModel> FarmTypes { get; set; }
        protected RadzenTemplateForm<CaseGetDetailViewModel> Form { get; set; }
        protected RadzenDataGrid<FarmInventoryGetListViewModel> FarmInventoryGrid { get; set; }
        protected RadzenRadioButtonList<long?> TypeOfCaseRadioButtonList { get; set; }
        public int Count { get; set; }
        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }
        public string SectionHeadingResourceKey { get; set; }
        public string DetailsHeadingResourceKey { get; set; }
        public string FarmGroupColumnHeadingResourceKey { get; set; }
        public string SpeciesColumnHeadingResourceKey { get; set; }
        public string TotalColumnHeadingResourceKey { get; set; }
        public string SickColumnHeadingResourceKey { get; set; }
        public string DeadColumnHeadingResourceKey { get; set; }
        public string StartOfSignsDateColumnHeadingResourceKey { get; set; }
        public string AverageAgeColumnHeadingResourceKey { get; set; }
        public string NoteColumnHeadingResourceKey { get; set; }
        public bool ShowTypeOfCaseIsRequiredMessage { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private bool _isFarmTypeLoading;
        
        #endregion

        #region Constants

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public FarmInventorySectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected FarmInventorySectionBase() : base(CancellationToken.None)
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

            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportFarmFlockSpeciesHeading);
                DetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportFarmFlockSpeciesHeading);
                FarmGroupColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesFlockColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesSpeciesColumnHeading);
                TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesTotalColumnHeading);
                SickColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesSickColumnHeading);
                DeadColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesDeadColumnHeading);
                StartOfSignsDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesStartOfSignsColumnHeading);
                AverageAgeColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportFarmFlockSpeciesAverageAgeWeeksColumnHeading);
            }
            else
            {
                SectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportFarmHerdSpeciesHeading);
                DetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportFarmHerdSpeciesHeading);
                FarmGroupColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesHerdColumnHeading);
                SpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesSpeciesColumnHeading);
                TotalColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesTotalColumnHeading);
                SickColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesSickColumnHeading);
                DeadColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesDeadColumnHeading);
                StartOfSignsDateColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesStartOfSignsColumnHeading);
                NoteColumnHeadingResourceKey = Localizer.GetString(FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportFarmHerdSpeciesNoteIncludeBreedFieldLabel);
            }

            if (Model.OutbreakCaseIndicator)
            {
                await GetFarmTypes();
                await GetDiseaseReportSpeciesTypes();

                Form = new RadzenTemplateForm<CaseGetDetailViewModel> {EditContext = new EditContext(Case)};

                MessageStore = new List<EIDSSValidationMessageStore>();
            }

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
                if (Form?.EditContext != null)
                    Form.EditContext.OnFieldChanged -= OnFormFieldChanged;

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
                await JsRuntime
                    .InvokeVoidAsync("FarmInventorySection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this)).ConfigureAwait(false);

                IsLoading = true;

                if (Model.OutbreakCaseIndicator)
                {
                    _isFarmTypeLoading = true;
                    await InvokeAsync(LoadFarmTypeCheckBoxList);

                    await LoadFarmInventoryData();
                    await InvokeAsync(StateHasChanged);

                    Form.EditContext.OnFieldChanged += OnFormFieldChanged;
                }
                
                await GetDiseaseReportSpeciesTypes();
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task LoadFarmInventoryData()
        {
            try
            {
                if (Model.FarmInventory is null || Model.FarmInventory.Count == 0)
                    IsLoading = true;

                if (IsLoading)
                {
                    Model.FarmInventory =
                        await GetFarmInventory(Model.DiseaseReportID, Model.FarmMasterID, Model.FarmID);

                    Model.FarmInventory = AddSurveillanceSessionInventory(Model);
                    
                    Model.FarmGroups = Model.FarmInventory.Where(x => x.RecordType != RecordTypeConstants.Species)
                        .ToList();
                    Model.Species = Model.FarmInventory.Where(x => x.RecordType == RecordTypeConstants.Species)
                        .ToList();
                }
                else
                {
                    if (Model.FarmInventory != null)
                    {
                        Model.FarmInventory = AddSurveillanceSessionInventory(Model);
                        
                        Model.FarmGroups = Model.FarmInventory.Where(x =>
                            x.RecordType != RecordTypeConstants.Species &&
                            x.RowStatus == (int) RowStatusTypeEnum.Active).ToList();
                        Model.Species = Model.FarmInventory.Where(x =>
                            x.RecordType == RecordTypeConstants.Species &&
                            x.RowStatus == (int) RowStatusTypeEnum.Active).ToList();
                    }
                }

                if (Model.FarmInventory != null)
                {
                    Model.FarmInventory = Model.FarmInventory.Where(x => x.RowStatus == (int) RowStatusTypeEnum.Active)
                        .ToList();

                    if (Model.FarmInventory != null)
                        Count = Model.FarmInventory != null && !Model.FarmInventory.Any()
                            ? 0
                            : Model.FarmInventory.First().TotalRowCount;

                    if (Model.FarmInventory != null)
                        foreach (var farmInventoryItem in Model.FarmInventory)
                        {
                            if (farmInventoryItem.RecordType != RecordTypeConstants.Species) continue;
                            if (farmInventoryItem.SpeciesID == null) continue;
                            FlexFormQuestionnaireGetRequestModel request = new()
                            {
                                idfObservation = farmInventoryItem.ObservationID,
                                idfsDiagnosis = Model.DiseaseID,
                                idfsFormType = Model.ReportCategoryTypeID == (long)CaseTypeEnum.Avian
                                    ? (long)FlexibleFormTypeEnum.AvianSpeciesClinicalInvestigation
                                    : (long)FlexibleFormTypeEnum.LivestockSpeciesClinicalInvestigation,
                                LangID = GetCurrentLanguage(),
                                TagID = (long) farmInventoryItem.SpeciesID
                            };
                            farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest = request;
                        }
                }

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        protected void ToggleFarmInventory(FarmInventoryGetListViewModel record)
        {
            Model.FarmInventory ??= new List<FarmInventoryGetListViewModel>();

            if (Model.FarmInventory.Any(x => x.RecordID == record.RecordID))
            {
                var index = Model.FarmInventory.IndexOf(record);
                Model.FarmInventory[index] = record;
            }
            else
            {
                Model.FarmInventory.Add(record);
            }
        }

        #endregion

        #region Form Events

        /// <summary>
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnFormFieldChanged(object sender, FieldChangedEventArgs e)
        {
            var errorMessages = Form.EditContext.GetValidationMessages(e.FieldIdentifier);

            var tabIndex = e.FieldIdentifier.FieldName switch
            {
                nameof(Case.FarmTypeID) => TypeOfCaseRadioButtonList.TabIndex,
                _ => 0
            };

            var temp = MessageStore.Where(x => x.FieldName == e.FieldIdentifier.FieldName).ToList();
            foreach (var error in temp) MessageStore.Remove(error);

            var enumerable = errorMessages.ToList();
            if (!enumerable.Any()) return;
            foreach (var message in enumerable)
                MessageStore.Add(new EIDSSValidationMessageStore
                    {FieldName = e.FieldIdentifier.FieldName, Message = message, TabIndex = tabIndex});
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task GetFarmTypes()
        {
            var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.AccessoryList, HACodeList.AllHACode);
            FarmTypes = results.Where(t => t.IdfsBaseReference is HACodeBaseReferenceIds.Livestock or HACodeBaseReferenceIds.Avian).ToList();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetDiseaseReportSpeciesTypes()
        {
            await GetSpeciesTypes(Model.ReportCategoryTypeID).ConfigureAwait(false);
        }

        #endregion

        #region Farm Type Radio Button List Change Event

        /// <summary>
        /// </summary>
        protected async Task OnFarmTypeChange()
        {
            switch (Case.FarmTypeID)
            {
                case null:
                    Model.ReportCategoryTypeID = 0;
                    Case.VeterinaryDiseaseReport.ReportCategoryTypeID = 0;
                    Case.CaseTypeId = null;
                    break;
                case (long)FarmTypeEnum.Avian:
                    {
                        Model.ReportCategoryTypeID = (long)CaseTypeEnum.Avian;
                        Case.VeterinaryDiseaseReport.ReportCategoryTypeID = (long)CaseTypeEnum.Avian;
                        Case.CaseTypeId = (long)OutbreakSpeciesTypeEnum.Avian;
                        if (Model.OutbreakFlexFormTemplates.AvianCaseQuestionaireTemplateID != null)
                        {
                            FlexFormQuestionnaireGetRequestModel caseQuestionnaireFlexFormRequest = new()
                            {
                                idfsFormType = (long)FlexibleFormTypeEnum.AvianOutbreakCaseQuestionnaire,
                                idfsFormTemplate = (long)Model.OutbreakFlexFormTemplates.AvianCaseQuestionaireTemplateID,
                                LangID = GetCurrentLanguage()
                            };
                            Case.CaseQuestionnaireFlexFormRequest = caseQuestionnaireFlexFormRequest;
                        }

                        break;
                    }
                default:
                    {
                        Model.ReportCategoryTypeID = (long)CaseTypeEnum.Livestock;
                        Case.VeterinaryDiseaseReport.ReportCategoryTypeID = (long)CaseTypeEnum.Livestock;
                        Case.CaseTypeId = (long)OutbreakSpeciesTypeEnum.Livestock;
                        if (Model.OutbreakFlexFormTemplates.LivestockCaseQuestionaireTemplateID != null)
                        {
                            FlexFormQuestionnaireGetRequestModel caseQuestionnaireFlexFormRequest = new()
                            {
                                idfsFormType = (long)FlexibleFormTypeEnum.LivestockOutbreakCaseQuestionnaire,
                                idfsFormTemplate = (long)Model.OutbreakFlexFormTemplates.LivestockCaseQuestionaireTemplateID,
                                LangID = GetCurrentLanguage()
                            };
                            Case.CaseQuestionnaireFlexFormRequest = caseQuestionnaireFlexFormRequest;
                        }

                        break;
                    }
            }

            await InvokeAsync(StateHasChanged);

            SpeciesTypes = null;
            await GetDiseaseReportSpeciesTypes();

            await ValidateSection().ConfigureAwait(false);

            const int caseMonitoringStep = 6;
            if (Model.ReportCategoryTypeID == 0 && Case.Session.txtAvianCaseMonitoringDuration is null &&
                Case.Session.txtLivestockCaseMonitoringDuration is null)
                await JsRuntime.InvokeAsync<string>("hideCaseDiseaseReportStep", _token, caseMonitoringStep)
                    .ConfigureAwait(false);
            else
                await JsRuntime.InvokeAsync<string>("showCaseDiseaseReportStep", _token, caseMonitoringStep)
                    .ConfigureAwait(false);

            await JsRuntime.InvokeAsync<string>("reloadOnTypeOfCaseChange", _token).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task LoadFarmTypeCheckBoxList()
        {
            if (_isFarmTypeLoading)
            {
                if (FarmTypes is null)
                    await GetFarmTypes();

                // Outbreak - disable farm type for an outbreak session that does not have 
                // avian or livestock to prevent selection of a farm.
                RadzenRadioButtonListItem<long?> item = new();
                item.Text = FarmTypes[0].Name;
                item.Disabled = !Case.Session.bAvian;
                item.Value = FarmTypes[0].IdfsBaseReference;

                TypeOfCaseRadioButtonList.AddItem(item);

                item = new RadzenRadioButtonListItem<long?>();
                item.Text = FarmTypes[1].Name;
                item.Disabled = !Case.Session.bLivestock;
                item.Value = FarmTypes[1].IdfsBaseReference;
                TypeOfCaseRadioButtonList.AddItem(item);

                _isFarmTypeLoading = false;
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
                _logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Add Farm Inventory Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddFlockOrHerdClick()
        {
            try
            {
                if (await ValidateDiseaseReportFarmInventory(Model).ConfigureAwait(false))
                {
                    var identity = (Model.FarmInventory.Count + 1) * -1;
                    var herdFlock = new FarmInventoryGetListViewModel
                    {
                        RecordID = identity,
                        RecordType = RecordTypeConstants.Herd,
                        FarmID = Model.FarmMasterID,
                        FlockOrHerdID = identity,
                        FlockOrHerdMasterID = null,
                        EIDSSFlockOrHerdID =
                            $"({Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)} {Model.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Herd) + 1})",
                        TotalAnimalQuantity = 0,
                        DeadAnimalQuantity = 0,
                        SickAnimalQuantity = 0,
                        RowStatus = (int) RowStatusTypeEnum.Active,
                        RowAction = (int) RowActionTypeEnum.Insert
                    };

                    Model.FarmInventory.Add(herdFlock);
                    Model?.FarmInventory.OrderBy(x => x.EIDSSFlockOrHerdID);

                    await FarmInventoryGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null!);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="flockOrHerd"></param>
        protected async Task OnAddSpeciesClick(object flockOrHerd)
        {
            try
            {
                var inventory = flockOrHerd as FarmInventoryGetListViewModel;
                var isValid = true;

                if (Model.FarmInventory.Any(x =>
                        inventory != null && x.RecordType == RecordTypeConstants.Species &&
                        x.RowStatus == (int) RowStatusTypeEnum.Active && x.FlockOrHerdMasterID != null &&
                        x.FlockOrHerdMasterID == inventory.FlockOrHerdMasterID))
                    isValid = await ValidateDiseaseReportFarmInventory(Model).ConfigureAwait(false);

                if (isValid)
                {
                    var identity = (Model.FarmInventory.Count + 1) * -1;
                    if (inventory != null)
                    {
                        var species = new FarmInventoryGetListViewModel
                        {
                            RecordID = identity,
                            RecordType = RecordTypeConstants.Species,
                            SpeciesID = identity,
                            SpeciesMasterID = null,
                            FarmID = Model.FarmID,
                            FlockOrHerdMasterID = inventory.FlockOrHerdMasterID,
                            EIDSSFlockOrHerdID = inventory.EIDSSFlockOrHerdID,
                            FlockOrHerdID = inventory.FlockOrHerdID,
                            TotalAnimalQuantity = 0,
                            DeadAnimalQuantity = 0,
                            SickAnimalQuantity = 0,
                            StartOfSignsDate = null,
                            RowStatus = (int) RowStatusTypeEnum.Active,
                            RowAction = (int) RowActionTypeEnum.Insert
                        };

                        Model.FarmInventory.Add(species);
                        Model.SpeciesAddedRemovedIndicator = true;

                        FlexFormQuestionnaireGetRequestModel request = new()
                        {
                            idfObservation = Model.FarmInventory.First(x => x.SpeciesID == species.SpeciesID)
                                .ObservationID,
                            idfsDiagnosis = Model.DiseaseID,
                            idfsFormType = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                ? (long) FlexibleFormTypeEnum.AvianSpeciesClinicalInvestigation
                                : (long) FlexibleFormTypeEnum.LivestockSpeciesClinicalInvestigation,
                            LangID = GetCurrentLanguage()
                        };
                        Model.FarmInventory.First(x => x.SpeciesID == species.SpeciesID)
                            .SpeciesClinicalInvestigationFlexFormRequest = request;
                    }

                    await FarmInventoryGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Delete Farm Inventory Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="farmInventory"></param>
        protected async Task OnDeleteFarmInventoryClick(object farmInventory)
        {
            try
            {
                if (CanDeleteFarmInventoryRecord(farmInventory as FarmInventoryGetListViewModel))
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (Model.FarmInventory.Any(x =>
                                    x.RecordID == ((FarmInventoryGetListViewModel) farmInventory).RecordID))
                            {
                                if (((FarmInventoryGetListViewModel) farmInventory).RecordID <= 0)
                                {
                                    Model.FarmInventory.Remove(farmInventory as FarmInventoryGetListViewModel);
                                }
                                else
                                {
                                    ((FarmInventoryGetListViewModel) farmInventory).RowAction =
                                        (int) RowActionTypeEnum.Delete;
                                    ((FarmInventoryGetListViewModel) farmInventory).RowStatus =
                                        (int) RowStatusTypeEnum.Inactive;
                                    var index = Model.FarmInventory.IndexOf(
                                        (FarmInventoryGetListViewModel) farmInventory);
                                    Model.FarmInventory[index] = (FarmInventoryGetListViewModel) farmInventory;

                                    Model.PendingDeleteFarmInventory ??= new List<FarmInventoryGetListViewModel>();
                                    Model.PendingDeleteFarmInventory.Add((FarmInventoryGetListViewModel) farmInventory);

                                    ToggleFarmInventory((FarmInventoryGetListViewModel) farmInventory);
                                }
                            }

                            await FarmInventoryGrid.Reload();

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
                _logger.LogError(ex.Message, ex);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <returns></returns>
        private bool CanDeleteFarmInventoryRecord(FarmInventoryGetListViewModel farmInventory)
        {
            StateHasChanged();

            switch (farmInventory.RecordType)
            {
                case RecordTypeConstants.Herd when Model.Animals is not null && Model.Animals.Any(x =>
                    x.HerdID == farmInventory.FlockOrHerdID && x.RowStatus == (int) RowStatusTypeEnum.Active):
                case RecordTypeConstants.Species when Model.Vaccinations is not null && Model.Vaccinations.Any(x =>
                    x.SpeciesID == farmInventory.SpeciesID && x.RowStatus == (int) RowStatusTypeEnum.Active):
                case RecordTypeConstants.Species when Model.Animals is not null && Model.Animals.Any(x =>
                    x.SpeciesID == farmInventory.SpeciesID && x.RowStatus == (int) RowStatusTypeEnum.Active):
                case RecordTypeConstants.Species when Model.Samples is not null && Model.Samples.Any(x =>
                    x.SpeciesID == farmInventory.SpeciesID && x.RowStatus == (int) RowStatusTypeEnum.Active):
                case RecordTypeConstants.Species when Model.PensideTests is not null && Model.PensideTests.Any(x =>
                    x.SpeciesID == farmInventory.SpeciesID && x.RowStatus == (int) RowStatusTypeEnum.Active):
                case RecordTypeConstants.Species when Model.LaboratoryTests is not null && Model.LaboratoryTests.Any(
                    x =>
                        x.SpeciesID == farmInventory.SpeciesID && x.RowStatus == (int) RowStatusTypeEnum.Active):
                case RecordTypeConstants.Species when Model.LaboratoryTestInterpretations is not null &&
                                                      Model.LaboratoryTestInterpretations.Any(x =>
                                                          x.SpeciesID == farmInventory.SpeciesID &&
                                                          x.RowStatus == (int) RowStatusTypeEnum.Active):
                    return false;
                default:
                    return true;
            }
        }

        #endregion

        #region Add Species Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddSpeciesTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode),
                        Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (int) AccessoryCodeEnum.Avian
                            : (int) AccessoryCodeEnum.Livestock
                    },
                    {nameof(AddBaseReferenceRecord.BaseReferenceTypeID), (long) BaseReferenceTypeEnum.SpeciesList},
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        HeadingResourceKeyConstants.SpeciesTypesReferenceEditorPageHeading
                    },
                    {nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel()}
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth, Resizable = true, Draggable = false
                    });

                if (result is SpeciesTypeSaveRequestResponseModel)
                {
                    SpeciesTypes = null;
                    await GetSpeciesTypes(Model.ReportCategoryTypeID);
                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            var validIndicator = await ValidateDiseaseReportFarmInventory(Model);

            if (Model.OutbreakCaseIndicator && validIndicator && Case.FarmTypeID is null)
            {
                MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

                if (MessageStore.Count <= 0) return false;
                switch (MessageStore.First().FieldName)
                {
                    case nameof(Model.ReportedByOrganizationID):
                        await TypeOfCaseRadioButtonList.Element.FocusAsync();
                        break;
                }

                ShowTypeOfCaseIsRequiredMessage = true;

                return false;
            }

            ShowTypeOfCaseIsRequiredMessage = false;

            if (!validIndicator) return false;
            if (Model.OutbreakCaseIndicator)
                await JsRuntime.InvokeAsync<string>("reloadClinicalInformationSection", _token);
            else
                await JsRuntime.InvokeAsync<string>("reloadClinicalInvestigationSection", _token, 2);

            return true;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            var validIndicator = await ValidateDiseaseReportFarmInventory(Model);

            if (Model.OutbreakCaseIndicator && validIndicator && Case.FarmTypeID is null)
            {
                ShowTypeOfCaseIsRequiredMessage = true;
                await InvokeAsync(StateHasChanged);
                return false;
            }

            ShowTypeOfCaseIsRequiredMessage = false;

            if (!validIndicator) return false;
            if (Model.OutbreakCaseIndicator)
                await JsRuntime.InvokeAsync<string>("reloadClinicalInformationSection", _token);

            return true;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(async() =>
            {
                await FarmInventoryGrid.Reload();
                StateHasChanged();
            });
        }

        #endregion

        #endregion
    }
}