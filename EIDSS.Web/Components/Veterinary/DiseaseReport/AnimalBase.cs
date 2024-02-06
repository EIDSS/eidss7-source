#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static System.GC;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;
using System.Threading;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class AnimalBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AnimalBase> Logger { get; set; }
        [Inject] protected IConfigurationClient ConfigurationClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public AnimalGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<AnimalGetListViewModel> Form { get; set; }
        protected RadzenDropDown<long?> FarmGroupDropDown { get; set; }
        protected RadzenDropDown<long?> SpeciesDropDown { get; set; }
        protected RadzenDropDown<long?> AgeTypeDropDown { get; set; }
        protected RadzenDropDown<long?> SexTypeDropDown { get; set; }
        protected RadzenDropDown<long?> ConditionTypeDropDown { get; set; }
        protected RadzenTextBox AnimalIdTextBox { get; set; }
        protected RadzenTextBox AnimalDescriptionTextBox { get; set; }
        public FlexForm.FlexForm ClinicalSigns { get; set; }
        public IEnumerable<FarmInventoryGetListViewModel> FarmGroups { get; set; }
        public IEnumerable<FarmInventoryGetListViewModel> Species { get; set; }
        public IEnumerable<ConfigurationMatrixViewModel> AgeTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> SexTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> ConditionTypes { get; set; }
        public bool IsLoading { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AnimalBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AnimalBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();

            _logger = Logger;

            IsLoading = true;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            FarmGroups = DiseaseReport.FarmInventory.Where(x =>
                x.RecordType == RecordTypeConstants.Herd && x.RowStatus == (int) RowStatusTypeEnum.Active);

            if (Model.HerdID is not null)
                Species = DiseaseReport.FarmInventory
                    .Where(x => x.FlockOrHerdID == (long) Model.HerdID && x.RecordType == RecordTypeConstants.Species);

            FlexFormQuestionnaireGetRequestModel clinicalSignsFlexFormRequest = new()
            {
                idfObservation = Model.ObservationID,
                idfsDiagnosis = DiseaseReport.DiseaseID,
                idfsFormType = (long) FlexibleFormTypeEnum.LivestockAnimalClinicalSigns,
                LangID = GetCurrentLanguage()
            };
            Model.ClinicalSignsFlexFormRequest = clinicalSignsFlexFormRequest;
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
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
            SuppressFinalize(this);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetFarmGroups(LoadDataArgs args)
        {
            FarmGroups = DiseaseReport.FarmInventory.Where(x =>
                Model.HerdID != null && x.FlockOrHerdID == (long) Model.HerdID &&
                x.RecordType == RecordTypeConstants.Herd && x.RowStatus == (int) RowStatusTypeEnum.Active).ToList();

            if (!IsNullOrEmpty(args.Filter))
                FarmGroups =
                    DiseaseReport.FarmInventory.Where(c =>
                        c.EIDSSFlockOrHerdID is not null &&
                        c.EIDSSFlockOrHerdID.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSpecies(LoadDataArgs args)
        {
            if (Model.HerdID is not null)
            {
                Species = DiseaseReport.FarmInventory.Where(x =>
                    x.FlockOrHerdID == (long) Model.HerdID && x.RecordType == RecordTypeConstants.Species &&
                    x.RowStatus == (int) RowStatusTypeEnum.Active);

                if (!IsNullOrEmpty(args.Filter))
                    Species =
                        DiseaseReport.FarmInventory.Where(c =>
                            c.Species is not null &&
                            c.Species.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));
            }

            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetAgeTypes(LoadDataArgs args)
        {
            try
            {
                if (Model.SpeciesTypeID is null)
                {
                    AgeTypes = new List<ConfigurationMatrixViewModel>();
                }
                else
                {
                    SpeciesAnimalAgeGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "strAnimalType",
                        SortOrder = SortConstants.Ascending,
                        idfsSpeciesType = Model.SpeciesTypeID
                    };
                    IList<ConfigurationMatrixViewModel> list =
                        await ConfigurationClient.GetSpeciesAnimalAgeList(request);

                    AgeTypes = list.Where(x => x.idfsSpeciesType == Model.SpeciesTypeID);

                    if (!IsNullOrEmpty(args.Filter))
                        AgeTypes = AgeTypes.Where(c =>
                            c.strAnimalType != null && c.strAnimalType.Contains(args.Filter,
                                StringComparison.CurrentCultureIgnoreCase));
                }

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetSexTypes(LoadDataArgs args)
        {
            try
            {
                SexTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AnimalSex, HACodeList.NoneHACode);

                if (!IsNullOrEmpty(args.Filter))
                    SexTypes = SexTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetConditionTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AnimalBirdStatus, HACodeList.NoneHACode);

                ConditionTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    ConditionTypes = ConditionTypes.Where(c =>
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

        #region Herd Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnHerdChange(object value)
        {
            try
            {
                if (value == null)
                {
                    Model.HerdID = null;
                    Model.Species = null;
                    Model.SpeciesID = null;
                    Model.SpeciesTypeID = null;
                    Model.SpeciesTypeName = null;
                    Species.ToList().Clear();
                }
                else
                {
                    Model.HerdID = (long) value;
                    Species = DiseaseReport.FarmInventory.Where(x =>
                        x.FlockOrHerdID == (long) value && x.RecordType == RecordTypeConstants.Species).ToList();
                }

                IsLoading = true;
                await GetSpecies(new LoadDataArgs());
                IsLoading = false;
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
        protected async Task OnSpeciesChange(object value)
        {
            try
            {
                if (value == null)
                {
                    Model.Species = null;
                    Model.SpeciesID = null;
                    Model.SpeciesTypeID = null;
                    Model.SpeciesTypeName = null;
                }
                else
                {
                    Model.SpeciesTypeID = DiseaseReport.Species.First(x => x.SpeciesID == (long) value).SpeciesTypeID;
                    Model.SpeciesTypeName =
                        DiseaseReport.Species.First(x => x.SpeciesID == (long) value).SpeciesTypeName;
                }

                IsLoading = true;
                await GetAgeTypes(new LoadDataArgs());
                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Clinical Signs Radio Button List Change Event

        /// <summary>
        ///     Load the clinical signs flex form component for this animal record.
        /// </summary>
        /// <param name="value"></param>
        protected async Task OnClinicalSignsChange(object value)
        {
            try
            {
                if (value is not null && (long) value == (long) YesNoUnknownEnum.Yes)
                {
                    await RefreshClinicalSigns();
                    DiagService.Refresh();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        private async Task RefreshClinicalSigns()
        {
            if (ClinicalSigns is not null)
            {
                var response = await ClinicalSigns.CollectAnswers();
                Model.ClinicalSignsFlexFormRequest.idfsFormTemplate = response.idfsFormTemplate;
                Model.ClinicalSignsFlexFormAnswers = ClinicalSigns.Answers;
                Model.ClinicalSignsObservationParameters = response.Answers;

                ClinicalSigns.SetRequestParameter(Model.ClinicalSignsFlexFormRequest);
            }
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.AnimalID)
            {
                case 0:
                {
                    Model.AnimalID = (DiseaseReport.Animals.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                }
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            Model.HerdID = (FarmGroupDropDown.SelectedItem as FarmInventoryGetListViewModel)?.FlockOrHerdID;
            Model.EIDSSHerdID = (FarmGroupDropDown.SelectedItem as FarmInventoryGetListViewModel)?.EIDSSFlockOrHerdID;

            Model.SpeciesID = (SpeciesDropDown.SelectedItem as FarmInventoryGetListViewModel)?.SpeciesID;
            Model.SpeciesTypeName = (SpeciesDropDown.SelectedItem as FarmInventoryGetListViewModel)?.SpeciesTypeName;

            Model.AgeTypeID = (AgeTypeDropDown.SelectedItem as ConfigurationMatrixViewModel)?.idfsAnimalAge;
            Model.AgeTypeName = (AgeTypeDropDown.SelectedItem as ConfigurationMatrixViewModel)?.strAnimalType;

            Model.ConditionTypeID = (ConditionTypeDropDown.SelectedItem as BaseReferenceViewModel)?.IdfsBaseReference;
            Model.ConditionTypeName = (ConditionTypeDropDown.SelectedItem as BaseReferenceViewModel)?.Name;

            Model.SexTypeID = (SexTypeDropDown.SelectedItem as BaseReferenceViewModel)?.IdfsBaseReference;
            Model.SexTypeName = (SexTypeDropDown.SelectedItem as BaseReferenceViewModel)?.Name;

            Model.AnimalDescription = AnimalDescriptionTextBox.Value;
            Model.EIDSSAnimalID = IsNullOrEmpty(AnimalIdTextBox.Value) ? null : AnimalIdTextBox.Value;

            if (IsNullOrEmpty(Model.EIDSSAnimalID))
                Model.EIDSSAnimalID =
                    "(" + Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel) + " " +
                    (DiseaseReport.Animals.Count + 1) + ")";

            if (Model.ClinicalSignsIndicator == (long) YesNoUnknownEnum.Yes)
            {
                var response = await ClinicalSigns.CollectAnswers();
                await InvokeAsync(StateHasChanged);
                Model.ClinicalSignsFlexFormRequest.idfsFormTemplate = response.idfsFormTemplate;
                Model.ClinicalSignsFlexFormAnswers = ClinicalSigns.Answers;
                Model.ClinicalSignsObservationParameters = response.Answers;
            }

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
                }
                else
                {
                    DiagService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}