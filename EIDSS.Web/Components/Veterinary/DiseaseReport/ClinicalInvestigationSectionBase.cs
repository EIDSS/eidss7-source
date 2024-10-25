#region Usings

using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class ClinicalInvestigationSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ClinicalInvestigationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] public IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected FlexForm.FlexForm ClinicalInvestigation { get; set; }
        public List<FlexForm.FlexForm> ReviewClinicalInvestigations { get; set; }
        public long? SpeciesId { get; set; }
        public long? PriorSpeciesId { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> CopiedAnswers { get; set; }
        public bool IsReview { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        public string HeadingResourceKey { get; set; }

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public ClinicalInvestigationSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected ClinicalInvestigationSectionBase() : base(CancellationToken.None)
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

            HeadingResourceKey = Localizer.GetString(Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                ? HeadingResourceKeyConstants.AvianDiseaseReportSpeciesInvestigationHeading
                : HeadingResourceKeyConstants.LivestockDiseaseReportSpeciesInvestigationHeading);

            ClinicalInvestigation ??= new FlexForm.FlexForm();
            ReviewClinicalInvestigations ??= new List<FlexForm.FlexForm>();

            base.OnInitialized();
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
                    .InvokeVoidAsync("ClinicalInvestigationSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);

                if (Model.FarmInventory is null)
                {
                    Model.FarmInventory = await GetFarmInventory(Model.DiseaseReportID, Model.FarmMasterID, Model.FarmID);

                    Model.FarmInventory = AddSurveillanceSessionInventory(Model);

                    LoadClinicalInvestigationReviewFlexFormCollection();
                }

                if (Model.ReportViewModeIndicator == false && Model.ShowReviewSectionIndicator == false)
                {
                    if (Model.FarmInventory.Any(x => x.RecordType == RecordTypeConstants.Species))
                    {
                        if (Model.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Species) == 1)
                            SpeciesId = Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                                .SpeciesID;
                    }

                    ClinicalInvestigation.FlexFormClient = FlexFormClient;

                    if (SpeciesId is not null)
                        await ClinicalInvestigation.SetRequestParameter(Model.FarmInventory
                            .First(x => x.SpeciesID is not null && x.SpeciesID == SpeciesId).SpeciesClinicalInvestigationFlexFormRequest);

                    await InvokeAsync(StateHasChanged);
                }
            }

            await base.OnAfterRenderAsync(firstRender);
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

        #endregion

        #region Load Reveiw Flex Form Method

        /// <summary>
        /// 
        /// </summary>
        private async Task LoadClinicalInvestigationReviewFlexFormCollection()
        {
            foreach (var farmInventoryItem in Model.FarmInventory)
            {
                if (farmInventoryItem.RecordType != RecordTypeConstants.Species) continue;
                if (farmInventoryItem.SpeciesID == null) continue;

                if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest is null)
                {
                    FlexFormQuestionnaireGetRequestModel request = new()
                    {
                        idfObservation = farmInventoryItem.ObservationID,
                        idfsDiagnosis = Model.DiseaseID,
                        idfsFormType = Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (long) FlexibleFormTypeEnum.AvianSpeciesClinicalInvestigation
                            : (long) FlexibleFormTypeEnum.LivestockSpeciesClinicalInvestigation,
                        LangID = GetCurrentLanguage(),
                        TagID = (long) farmInventoryItem.SpeciesID
                    };
                    farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest = request;
                }

                var reviewForm = new FlexForm.FlexForm
                {
                    FlexFormClient = FlexFormClient
                };

                if (farmInventoryItem.SpeciesID != null)
                {
                    Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                            .SpeciesClinicalInvestigationFlexFormRequest.TagID =
                        (long) farmInventoryItem.SpeciesID;

                    await reviewForm.SetRequestParameter(Model.FarmInventory
                        .First(x => x.SpeciesID == farmInventoryItem.SpeciesID)
                        .SpeciesClinicalInvestigationFlexFormRequest);
                    reviewForm.Request.Title = farmInventoryItem.Species;
                }

                ReviewClinicalInvestigations.Add(reviewForm);
            }
        }

        #endregion

        #region Species Radio Button List Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSpeciesChange(long? value)
        {
            try
            {
                if (value is null) return;
                if (PriorSpeciesId is not null)
                {
                    var response = await ClinicalInvestigation.CollectAnswers();
                    Model.FarmInventory.First(x => x.SpeciesID == PriorSpeciesId)
                        .SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate = response.idfsFormTemplate;
                    Model.FarmInventory.First(x => x.SpeciesID == PriorSpeciesId)
                        .SpeciesClinicalInvestigationFlexFormAnswers = ClinicalInvestigation.Answers;
                    Model.FarmInventory.First(x => x.SpeciesID == PriorSpeciesId)
                        .SpeciesClinicalInvestigationFlexFormRequest.ReviewAnswers = ClinicalInvestigation.Answers;
                    Model.FarmInventory.First(x => x.SpeciesID == PriorSpeciesId)
                        .SpeciesClinicalInvestigationObservationParameters = response.Answers;
                }

                ClinicalInvestigation.Answers = Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                    .SpeciesClinicalInvestigationFlexFormAnswers;
                PriorSpeciesId = SpeciesId;

                await ClinicalInvestigation.SetRequestParameter(Model.FarmInventory
                        .First(x => x.SpeciesID == SpeciesId).SpeciesClinicalInvestigationFlexFormRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
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
            await ClinicalInvestigation.Render();

            CopiedAnswers = ClinicalInvestigation.Answers;
        }

        #endregion

        #region Paste Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnPasteClick()
        {
            Model.FarmInventory.First(x => x.SpeciesID == SpeciesId).SpeciesClinicalInvestigationFlexFormAnswers =
                CopiedAnswers;

            ClinicalInvestigation.Answers = Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                .SpeciesClinicalInvestigationFlexFormAnswers;
            await ClinicalInvestigation.Render();
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

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            Model.SpeciesClinicalInvestigationInfoSectionValidIndicator = true;
            if (ClinicalInvestigation is not null)
                Model.SpeciesClinicalInvestigationInfoSectionModifiedIndicator = ClinicalInvestigation.IsFormModified();

            if (!Model.SpeciesClinicalInvestigationInfoSectionValidIndicator)
                return Model.SpeciesClinicalInvestigationInfoSectionValidIndicator = true;

            foreach (var farmInventoryItem in Model.FarmInventory)
            {
                if (farmInventoryItem.RecordType != RecordTypeConstants.Species) continue;

                if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormAnswers is null) continue;
                if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate is null)
                {
                    var questions =
                        await FlexFormClient.GetQuestionnaire(farmInventoryItem
                            .SpeciesClinicalInvestigationFlexFormRequest);

                    if (questions.Count > 0)
                        farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate =
                            questions[0].idfsFormTemplate;
                }

                if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest.idfsFormTemplate == null) continue;
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

            return Model.SpeciesClinicalInvestigationInfoSectionValidIndicator = true;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            //TODO: change validation once flex form is ready to go.
            Model.SpeciesClinicalInvestigationInfoSectionValidIndicator = true; // Form.EditContext.Validate();

            return Model.SpeciesClinicalInvestigationInfoSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// 
        /// </summary>
        /// <param name="isReview"></param>
        /// <param name="currentStepNumber"></param>
        [JSInvokable]
        public async Task ReloadSection(bool isReview, int currentStepNumber)
        {
            IsReview = isReview;

            if (Model.FarmInventory is not null)
            {
                var index = 0;
                foreach (var farmInventoryItem in Model.FarmInventory)
                {
                    if (farmInventoryItem.RecordType != RecordTypeConstants.Species) continue;
                    if (farmInventoryItem.SpeciesClinicalInvestigationFlexFormRequest is null) continue;

                    if (farmInventoryItem.SpeciesID != null)
                    {
                        Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                                .SpeciesClinicalInvestigationFlexFormRequest.TagID =
                            (long) farmInventoryItem.SpeciesID;

                        if (SpeciesId is not null && farmInventoryItem.SpeciesID == SpeciesId)
                        {
                            if (currentStepNumber == 4)
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
                            }
                        }
                    }

                    if (isReview)
                    {
                        ReviewClinicalInvestigations = new List<FlexForm.FlexForm>();
                        await LoadClinicalInvestigationReviewFlexFormCollection();

                        if (Model.FarmInventory.Any(x => x.RecordType == RecordTypeConstants.Species))
                        {
                            if (Model.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Species) == 1)
                                SpeciesId = Model.FarmInventory
                                    .First(x => x.RecordType == RecordTypeConstants.Species)
                                    .SpeciesID;

                            ClinicalInvestigation.FlexFormClient = FlexFormClient;
                            await ClinicalInvestigation.SetRequestParameter(Model.FarmInventory
                                .First().SpeciesClinicalInvestigationFlexFormRequest);
                        }

                        await ReviewClinicalInvestigations[index].Render();

                        if (farmInventoryItem.SpeciesID < 0)
                        {
                            ReviewClinicalInvestigations[index].Request.ReviewAnswers =
                                farmInventoryItem.SpeciesClinicalInvestigationFlexFormAnswers;

                            ReviewClinicalInvestigations[index].Answers =
                                farmInventoryItem.SpeciesClinicalInvestigationFlexFormAnswers;
                        }

                        StateHasChanged();
                    }

                    index += 1;
                }
            }

            if (isReview)
            {
                SpeciesId = null;
                PriorSpeciesId = null;
            }
            else
            {
                if (Model.SpeciesAddedRemovedIndicator)
                {
                    Model.SpeciesAddedRemovedIndicator = false;

                    if (Model.FarmInventory is not null &&
                        Model.FarmInventory.Any(x => x.RecordType == RecordTypeConstants.Species))
                    {
                        if (Model.FarmInventory.Count(x => x.RecordType == RecordTypeConstants.Species) == 1)
                            SpeciesId = Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                                .SpeciesID;

                        ClinicalInvestigation.FlexFormClient = FlexFormClient;
                        await ClinicalInvestigation.SetRequestParameter(Model.FarmInventory
                            .First().SpeciesClinicalInvestigationFlexFormRequest);

                        if (SpeciesId is null)
                        {
                            SpeciesId = Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                                .SpeciesID;
                            PriorSpeciesId = SpeciesId;
                        }
                    }
                }
                else
                {
                    if (SpeciesId is null)
                    {
                        if (Model.FarmInventory is not null &&
                            Model.FarmInventory.Any(x => x.RecordType == RecordTypeConstants.Species))
                        {
                            SpeciesId = Model.FarmInventory.First(x => x.RecordType == RecordTypeConstants.Species)
                                .SpeciesID;
                        }
                    }

                    PriorSpeciesId = SpeciesId;

                    await ClinicalInvestigation.Render();
                }

                StateHasChanged();

                if (Model.FarmInventory is null) return;
                {
                    if (SpeciesId is not null)
                        ClinicalInvestigation.Answers = Model.FarmInventory.First(x => x.SpeciesID == SpeciesId)
                            .SpeciesClinicalInvestigationFlexFormAnswers;
                }
            }
        }

        #endregion

        #endregion
    }
}