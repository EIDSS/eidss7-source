#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.FlexForm;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.AggregateActionsReport
{
    public class DiagnosticSectionBase : ReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<DiagnosticSectionBase> Logger { get; set; }

        [Inject] protected IFlexFormClient FlexFormClient { get; set; }

        [Inject]
        protected IVeterinaryDiagnosticInvestigationMatrixClient DiagnosticInvestigationMatrixClient { get; set; }

        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        public static FlexFormMatrix DiagnosticMatrixFlexForm { get; set; }

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

            StateContainer.DiagnosticFlexFormRenderIndicator = false;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnStateLoaded += async () => await OnStateLoadedAsync();
            StateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }

        protected override async Task OnInitializedAsync()
        {
            await GetDiagnosticInvestigationMatrixVersions();
            await GetDiagnosticInvestigationTemplates();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync(
                    "VetAggregateActionsReportDiagnosticInvestigationsSection.SetDotNetReference", _token,
                    lDotNetReference);
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
                case "DiagnosticReportDisabledIndicator":
                    if (DiagnosticMatrixFlexForm != null)
                        await DiagnosticMatrixFlexForm.Refresh(StateContainer.DiagnosticReportDisabledIndicator);
                    break;
            }
        }

        /// <summary>
        ///     Loads the flex form once the data is loaded or new record is initialized
        ///     in the state container.  For flex forms, we need to load lazy so all the
        ///     data is there on render.
        /// </summary>
        /// <returns></returns>
        private async Task OnStateLoadedAsync()
        {
            await LoadDiagnosticInvestigationsFlexForm();
        }

        #endregion LifeCycle Methods

        #region Flex Form

        protected async Task LoadDiagnosticInvestigationsFlexForm()
        {
            StateContainer.DiagnosticFlexFormRequest.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.InvestigationTypeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };

            StateContainer.DiagnosticFlexFormRequest.Title = string.Empty;
            StateContainer.DiagnosticFlexFormRequest.LangID = GetCurrentLanguage();
            StateContainer.DiagnosticFlexFormRequest.idfsFormType = (long) FlexibleFormTypes.VeterinaryDiagnostic;
            StateContainer.DiagnosticFlexFormRequest.idfsFormTemplate ??= StateContainer.DiagnosticTemplateIDDefault;
            StateContainer.DiagnosticMatrixVersionID ??= StateContainer.DiagnosticMatrixVersionIDDefault;
            if (StateContainer.DiagnosticObservationID is not null)
                StateContainer.DiagnosticFlexFormRequest.idfObservation = StateContainer.DiagnosticObservationID;

            var lstInvestigationTypes =
                await DiagnosticInvestigationMatrixClient.GetInvestigationTypeMatrixListAsync(
                    ReferenceEditorType.InvestigationTypes, null, GetCurrentLanguage());
            var lstSpecies = await CrossCuttingClient.GetSpeciesListAsync(ReferenceEditorType.SpeciesList,
                HACodeList.LiveStockAndAvian, GetCurrentLanguage());
            var lstDiseases = await CrossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(ReferenceEditorType.Disease,
                HACodeList.LiveStockAndAvian, GetCurrentLanguage());

            var request = new MatrixGetRequestModel
            {
                MatrixId = StateContainer.DiagnosticMatrixVersionID.GetValueOrDefault(),
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "intNumRow",
                SortOrder = "asc"
            };

            var lstRow =
                await DiagnosticInvestigationMatrixClient.GetVeterinaryDiagnosticInvestigationMatrixReport(request);

            StateContainer.DiagnosticFlexFormRequest.MatrixData = new List<FlexFormMatrixData>();
            foreach (var row in lstRow)
            {
                if (row.IdfAggrDiagnosticActionMTX == null) continue;
                var matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),

                    idfRow = (long) row.IdfAggrDiagnosticActionMTX
                };
                matrixData.MatrixData.Add(lstInvestigationTypes
                    .Find(v => v.IdfsBaseReference == row.IdfsDiagnosticAction)?.StrDefault);
                matrixData.MatrixData.Add(lstSpecies.Find(v => v.IdfsBaseReference == row.IdfsSpeciesType)?.StrDefault);
                matrixData.MatrixData.Add(lstDiseases.Find(v => v.IdfsBaseReference == row.IdfsDiagnosis)?.StrDefault);
                matrixData.MatrixData.Add(row.StrOIECode);
                StateContainer.DiagnosticFlexFormRequest.MatrixData.Add(matrixData);
            }

            StateContainer.DiagnosticFlexFormRenderIndicator = true;

            await InvokeAsync(StateHasChanged);
        }

        protected async Task SaveDiagnosticMatrixFlexForm()
        {
            await DiagnosticMatrixFlexForm?.SaveFlexForm();
        }

        #endregion Flex Form

        #region Load Data

        protected async Task GetDiagnosticInvestigationMatrixVersions()
        {
            try
            {
                StateContainer.DiagnosticMatrixList =
                    await CrossCuttingClient.GetMatrixVersionsByType(MatrixTypes.DiagnosticInvestigations);
                StateContainer.DiagnosticMatrixVersionIDDefault =
                    StateContainer.DiagnosticMatrixList != null && StateContainer.DiagnosticMatrixList.Any()
                        ? StateContainer.DiagnosticMatrixList.FirstOrDefault(x => x.BlnIsActive == true)?.IdfVersion
                        : null;
                if (StateContainer.DiagnosticMatrixVersionIDDefault != null &&
                    StateContainer.DiagnosticMatrixVersionID is null)
                    StateContainer.DiagnosticMatrixVersionID = StateContainer.DiagnosticMatrixVersionIDDefault;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetDiagnosticInvestigationTemplates()
        {
            FlexFormTemplateGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = null;
                request.idfsFormType = (long) FlexibleFormTypes.VeterinaryDiagnostic;

                StateContainer.DiagnosticTemplatesList = await FlexFormClient.GetTemplateList(request);
                StateContainer.DiagnosticTemplateIDDefault =
                    StateContainer.DiagnosticTemplatesList != null && StateContainer.DiagnosticTemplatesList.Any()
                        ? StateContainer.DiagnosticTemplatesList.FirstOrDefault(x => x.blnUNI)?.idfsFormTemplate
                        : null;
                if (StateContainer.DiagnosticTemplateIDDefault != null &&
                    StateContainer.DiagnosticFlexFormRequest.idfsFormTemplate is null)
                    StateContainer.DiagnosticFlexFormRequest.idfsFormTemplate =
                        StateContainer.DiagnosticTemplateIDDefault;
                await InvokeAsync(StateHasChanged);
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
            await LoadDiagnosticInvestigationsFlexForm();
            if (DiagnosticMatrixFlexForm != null)
                await DiagnosticMatrixFlexForm.Render();
        }

        protected async Task OnTemplateChange()
        {
            await LoadDiagnosticInvestigationsFlexForm();
            if (DiagnosticMatrixFlexForm != null)
                await DiagnosticMatrixFlexForm.Render();
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
            if (!StateContainer.ReportInformationValidIndicator) return StateContainer.DiagnosticSectionValidIndicator;

            if (DiagnosticMatrixFlexForm is null || DiagnosticMatrixFlexForm?.ComponentParameters.Count == 0)
            {
                StateContainer.DiagnosticSectionValidIndicator = true;
                return StateContainer.DiagnosticSectionValidIndicator;
            }

            await SaveDiagnosticMatrixFlexForm();

            await InvokeAsync(StateHasChanged);

            StateContainer.DiagnosticObservationID = StateContainer.DiagnosticFlexFormRequest.idfObservation;

            if (StateContainer.DiagnosticObservationID is not null)
                StateContainer.DiagnosticSectionValidIndicator = true;

            return StateContainer.DiagnosticSectionValidIndicator;
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
                StateContainer.DiagnosticReportDisabledIndicator = true;
            }
            else
            {
                if ((StateContainer.ReportKey <= 0 &&
                     !StateContainer.VeterinaryAggregateActionsReportPermissions.Create)
                    || (StateContainer.ReportKey > 0 &&
                        !StateContainer.VeterinaryAggregateActionsReportPermissions.Write))
                    StateContainer.DiagnosticReportDisabledIndicator = true;
                else
                    StateContainer.DiagnosticReportDisabledIndicator = false;
            }
        }

        #endregion Set ReportDisabledIndicators

        #endregion Methods
    }
}