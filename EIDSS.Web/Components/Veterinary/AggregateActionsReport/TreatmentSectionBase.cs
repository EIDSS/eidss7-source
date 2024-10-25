#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.FlexForm;
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

namespace EIDSS.Web.Components.Veterinary.AggregateActionsReport
{
    public class TreatmentSectionBase : ReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<TreatmentSectionBase> Logger { get; set; }

        [Inject]
        protected IFlexFormClient FlexFormClient { get; set; }

        [Inject]
        protected IVeterinaryProphylacticMeasureMatrixClient ProphylacticMeasureMatrixClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        protected FlexForm.FlexFormMatrix TreatmentMatrixFlexForm { get; set; }

        #endregion Properties

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region LifeCycle Methods

        protected override void OnInitialized()
        {
            _logger = Logger;

            StateContainer.TreatmentFlexFormRenderIndicator = false;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnStateLoaded += async () => await OnStateLoadedAsync();
            StateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }

        protected override async Task OnInitializedAsync()
        {
            await GetTreatmentMatrixVersions();
            await GetTreatmentTemplates();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetAggregateActionsReportTreatmentMeasuresSection.SetDotNetReference", _token, lDotNetReference);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public new void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            if (StateContainer == null) return;
            StateContainer.OnStateLoaded -= async () => await OnStateLoadedAsync();
            StateContainer.OnChange -= async property => await OnStateContainerChangeAsync(property);
        }

        private async Task OnStateContainerChangeAsync(string property)
        {
            switch (property)
            {
                case "TreatmentReportDisabledIndicator":
                    if (TreatmentMatrixFlexForm != null)
                        await TreatmentMatrixFlexForm.Refresh(StateContainer.TreatmentReportDisabledIndicator);
                    break;
            }
        }

        /// <summary>
        /// Loads the flex form once the data is loaded or new record is initialized
        /// in the state container.  For flex forms, we need to load lazy so all the
        /// data is there on render.
        /// </summary>
        /// <returns></returns>
        private async Task OnStateLoadedAsync()
        {
            await LoadTreatmentFlexForm();
        }

        #endregion LifeCycle Methods

        #region Flex Form

        protected async Task LoadTreatmentFlexForm()
        {
            StateContainer.TreatmentFlexFormRequest.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.MeasureTypeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.MeasureCodeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };
            StateContainer.TreatmentFlexFormRequest.Title = String.Empty;
            StateContainer.TreatmentFlexFormRequest.LangID = GetCurrentLanguage();
            StateContainer.TreatmentFlexFormRequest.idfsFormType = (long)FlexibleFormTypes.VeterinaryProphylactic;
            StateContainer.TreatmentFlexFormRequest.idfsFormTemplate ??= StateContainer.DiagnosticTemplateIDDefault;
            StateContainer.TreatmentMatrixVersionID ??= StateContainer.TreatmentMatrixVersionIDDefault;
            if (StateContainer.TreatmentObservationID is not null)
                StateContainer.TreatmentFlexFormRequest.idfObservation = StateContainer.TreatmentObservationID;

            var lstMeasureTypes = await ProphylacticMeasureMatrixClient.GetVeterinaryProphylacticMeasureTypes(ReferenceEditorType.Prophylactic, HACodeList.LivestockHACode, GetCurrentLanguage());
            var lstSpecies = await CrossCuttingClient.GetSpeciesListAsync(ReferenceEditorType.SpeciesList, HACodeList.LiveStockAndAvian, GetCurrentLanguage());
            var lstDiseases = await CrossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(ReferenceEditorType.Disease, HACodeList.LiveStockAndAvian, GetCurrentLanguage());

            var request = new VeterinaryProphylacticMeasureMatrixGetRequestModel
            {
                IdfVersion = StateContainer.TreatmentMatrixVersionID.GetValueOrDefault(),
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "intNumRow",
                SortOrder = SortConstants.Ascending
            };

            var lstRow = await ProphylacticMeasureMatrixClient.GetVeterinaryProphylacticMeasureMatrixReport(request);

            StateContainer.TreatmentFlexFormRequest.MatrixData = new List<FlexFormMatrixData>();

            foreach (var row in lstRow)
            {
                if (row.IdfAggrProphylacticActionMTX == null) continue;
                var matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),

                    idfRow = (long)row.IdfAggrProphylacticActionMTX
                };

                matrixData.MatrixData.Add(lstMeasureTypes.Find(v => v.IdfsBaseReference == row.IdfsProphilacticAction)?.StrDefault);
                matrixData.MatrixData.Add(row.StrActionCode);
                matrixData.MatrixData.Add(lstSpecies.Find(v => v.IdfsBaseReference == row.IdfsSpeciesType)?.StrDefault);
                matrixData.MatrixData.Add(lstDiseases.Find(v => v.IdfsBaseReference == row.IdfsDiagnosis)?.StrDefault);
                matrixData.MatrixData.Add(row.StrOIECode);
                StateContainer.TreatmentFlexFormRequest.MatrixData.Add(matrixData);
            }

            StateContainer.TreatmentFlexFormRenderIndicator = true;

            await InvokeAsync(StateHasChanged);
        }

        protected async Task SaveTreatmentMatrixFlexForm()
        {
            await TreatmentMatrixFlexForm?.SaveFlexForm();
        }

        #endregion Flex Form

        #region Load Data

        protected async Task GetTreatmentMatrixVersions()
        {
            try
            {
                StateContainer.TreatmentMatrixList = await CrossCuttingClient.GetMatrixVersionsByType(MatrixTypes.Prophylactic);
                StateContainer.TreatmentMatrixVersionIDDefault = StateContainer.TreatmentMatrixList != null && StateContainer.TreatmentMatrixList.Any() ? StateContainer.TreatmentMatrixList.FirstOrDefault(x => x.BlnIsActive == true)?.IdfVersion : null;
                if (StateContainer.TreatmentMatrixVersionIDDefault != null && StateContainer.TreatmentMatrixVersionID is null)
                    StateContainer.TreatmentMatrixVersionID = StateContainer.TreatmentMatrixVersionIDDefault;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetTreatmentTemplates()
        {
            FlexFormTemplateGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = null;
                request.idfsFormType = (long)FlexibleFormTypes.VeterinaryProphylactic;

                StateContainer.TreatmentTemplatesList = await FlexFormClient.GetTemplateList(request);
                StateContainer.TreatmentTemplateIDDefault =
                    (StateContainer.TreatmentTemplatesList != null && StateContainer.TreatmentTemplatesList.Any())
                        ? StateContainer.TreatmentTemplatesList.FirstOrDefault(x => x.blnUNI)?.idfsFormTemplate
                        : null;
                if (StateContainer.TreatmentTemplateIDDefault != null &&
                    StateContainer.TreatmentFlexFormRequest.idfsFormTemplate is null)
                    StateContainer.TreatmentFlexFormRequest.idfsFormTemplate = StateContainer.TreatmentTemplateIDDefault;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data

        #region Matrix and Template Change Event

        protected async Task OnMatrixVersionChange()
        {
            await LoadTreatmentFlexForm();
            if (TreatmentMatrixFlexForm != null)
                await TreatmentMatrixFlexForm.Render();
        }

        protected async Task OnTemplateChange()
        {
            await LoadTreatmentFlexForm();
            if (TreatmentMatrixFlexForm != null)
                await TreatmentMatrixFlexForm.Render();
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            // if the first section does not validate, don't save observation
            if (!StateContainer.ReportInformationValidIndicator) return StateContainer.TreatmentSectionValidIndicator;

            // if there are no rows in the flex form matrix because the template has not been
            // established, just return true
            if (TreatmentMatrixFlexForm is null || TreatmentMatrixFlexForm?.ComponentParameters.Count == 0)
            {
                StateContainer.TreatmentSectionValidIndicator = true;
                return StateContainer.TreatmentSectionValidIndicator;
            }

            await SaveTreatmentMatrixFlexForm();

            await InvokeAsync(StateHasChanged);

            StateContainer.TreatmentObservationID = StateContainer.TreatmentFlexFormRequest.idfObservation;

            if (StateContainer.TreatmentObservationID is not null)
                StateContainer.TreatmentSectionValidIndicator = true;

            return StateContainer.TreatmentSectionValidIndicator;
        }

        #endregion Validation Methods

        #region Set ReportDisabledIndicator

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("SetReportDisabledIndicator")]
        public void SetReportDisabledIndicator(int currentIndex)
        {
            if (currentIndex == 4) //review section
            {
                StateContainer.TreatmentReportDisabledIndicator = true;
            }
            else
            {
                if ((StateContainer.ReportKey <= 0 && !StateContainer.VeterinaryAggregateActionsReportPermissions.Create)
                    || (StateContainer.ReportKey > 0 && !StateContainer.VeterinaryAggregateActionsReportPermissions.Write))
                {
                    StateContainer.TreatmentReportDisabledIndicator = true;
                }
                else
                {
                    StateContainer.TreatmentReportDisabledIndicator = false;
                }
            }
        }

        #endregion Set ReportDisabledIndicators

        #endregion Methods
    }
}