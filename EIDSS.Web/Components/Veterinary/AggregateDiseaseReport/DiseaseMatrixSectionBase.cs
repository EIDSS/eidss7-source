using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.FlexForm;
using EIDSS.Web.Components.Veterinary.AggregateDiseaseReport;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary
{
    public class DiseaseMatrixSectionBase : AggregateDiseaseReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<DiseaseMatrixSectionBase> Logger { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected IVeterinaryAggregateDiseaseMatrixClient VeterinaryAggregateDiseaseMatrixClient { get; set; }

        [Inject]
        private IFlexFormClient FlexFormClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public AggregateReportDetailsViewModel Model { get; set; }

        #endregion Parameters

        #region Properties

        protected RadzenTemplateForm<AggregateReportDetailsViewModel> Form { get; set; }
        protected bool IsReadOnly { get; set; }
        protected IEnumerable<MatrixVersionViewModel> MatrixVersions { get; set; }
        protected IEnumerable<FlexFormTemplateListViewModel> Templates { get; set; }
        protected FlexFormMatrix DiseaseMatrixFlexForm { get; set; }
        protected bool FlexFormRenderIndicator { get; set; }

        #endregion Properties

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            FlexFormRenderIndicator = false;

            Model.IsReadOnly = IsReadOnly;

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VeterinaryAggregateDiseaseReport.DiseaseMatrixSection.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);

                await LoadFlexFormsAsync();
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion Lifecycle Methods

        #region Load Data

        private async Task LoadFlexFormsAsync()
        {
            var model = Model.DiseaseMatrixSection;

            model.AggregateCase.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };
            model.AggregateCase.Title = Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateCaseHeading);  //"Vet Aggregate Case";
            model.AggregateCase.SubmitButtonID = "btnSubmit";
            model.AggregateCase.LangID = GetCurrentLanguage();
            model.AggregateCase.idfsFormType = (long)FlexibleFormTypes.VeterinaryAggregate;
            model.AggregateCase.ObserationFieldID = "idfCaseObservation";
            model.AggregateCase.idfObservation = model.AggregateCase.idfObservation;
            model.AggregateCase.idfsFormTemplate = model.idfsFormTemplate;

            var lstDiseases = await CrossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(EIDSSConstants.ReferenceEditorType.Disease, EIDSSConstants.HACodeList.LiveStockAndAvian, GetCurrentLanguage());
            var lstSpecies = await CrossCuttingClient.GetSpeciesListAsync(EIDSSConstants.ReferenceEditorType.SpeciesList, EIDSSConstants.HACodeList.LiveStockAndAvian, GetCurrentLanguage());

            if (model.idfVersion > 0 && model.idfsFormTemplate != null)
            {
                var lstRow = await VeterinaryAggregateDiseaseMatrixClient.GetVeterinaryAggregateDiseaseMatrixListAsync(model.idfVersion.ToString(), GetCurrentLanguage());

                model.AggregateCase.MatrixData = new List<FlexFormMatrixData>();

                foreach (var row in lstRow)
                {
                    if (row.IdfAggrVetCaseMTX == null) continue;
                    var matrixData = new FlexFormMatrixData
                    {
                        MatrixData = new List<string>(),
                        idfRow = (long)row.IdfAggrVetCaseMTX
                    };
                    matrixData.MatrixData.Add(lstDiseases.Find(v => v.IdfsBaseReference == row.IdfsDiagnosis)?.StrDefault);
                    matrixData.MatrixData.Add(lstSpecies.Find(v => v.IdfsBaseReference == row.IdfsSpeciesType)?.StrDefault);
                    matrixData.MatrixData.Add(row.StrOIECode);
                    model.AggregateCase.MatrixData.Add(matrixData);
                }
            }

            FlexFormRenderIndicator = model.idfsFormTemplate != null && model.idfsFormTemplate > 0;

            await InvokeAsync(StateHasChanged);
        }

        public async Task LoadMatrixVersions()
        {
            try
            {
                var listVersion = await CrossCuttingClient.GetMatrixVersionsByType(EIDSSConstants.MatrixTypes.VetAggregateCase);

                MatrixVersions = listVersion.AsODataEnumerable();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadTemplatesAsync()
        {
            FlexFormTemplateGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = null;
                request.idfsFormType = (long)FlexibleFormTypes.VeterinaryAggregate;

                var listTemplate = await FlexFormClient.GetTemplateList(request);

                Templates = listTemplate.AsODataEnumerable();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data

        #region Matrix and Template Change Events

        protected async Task OnMatrixVersionChange()
        {
            await LoadFlexFormsAsync();
            if (DiseaseMatrixFlexForm != null)
                await DiseaseMatrixFlexForm.Render();
        }

        protected async Task OnTemplateChange()
        {
            await LoadFlexFormsAsync();
            if (DiseaseMatrixFlexForm != null)
                await DiseaseMatrixFlexForm.Render();
        }

        #endregion Matrix and Template Change Events

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            if (DiseaseMatrixFlexForm is not null && Model.ReportDetailsSection.ReportDetailsSectionValidIndicator)
            {
                await DiseaseMatrixFlexForm.SaveFlexForm();
            }

            return await Task.FromResult(true);
        }

        #endregion Validation Methods

        #region Set ReportDisabledIndicator

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("SetReportDisabledIndicator")]
        public async Task SetReportDisabledIndicator(int currentIndex)
        {
            if (currentIndex == 2) //review section
            {
                IsReadOnly = true;
                Model.IsReadOnly = true;
                await InvokeAsync(StateHasChanged);
            }
            else
            {
                if ((Model.idfAggrCase <= 0 &&
                     !Model.Permissions.Create)
                    || (Model.idfAggrCase > 0 &&
                        !Model.Permissions.Write))
                {
                    IsReadOnly = true;
                    Model.IsReadOnly = true;
                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    IsReadOnly = false;
                    Model.IsReadOnly = false;
                    await InvokeAsync(StateHasChanged);
                    if (DiseaseMatrixFlexForm != null)
                    {
                        await DiseaseMatrixFlexForm.Refresh(IsReadOnly);
                    }
                }
            }
        }

        #endregion Set ReportDisabledIndicator

        #endregion Methods
    }
}