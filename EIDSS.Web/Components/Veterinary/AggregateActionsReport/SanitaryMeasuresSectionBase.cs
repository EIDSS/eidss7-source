#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
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
    public class SanitaryMeasuresSectionBase : ReportBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SanitaryMeasuresSectionBase> Logger { get; set; }

        [Inject]
        protected IFlexFormClient FlexFormClient { get; set; }

        [Inject]
        protected IVeterinarySanitaryActionMatrixClient SanitaryActionsMatrixClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        protected FlexForm.FlexFormMatrix SanitaryMatrixFlexForm { get; set; }

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

            StateContainer.SanitaryFlexFormRenderIndicator = false;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnStateLoaded += async () => await OnStateLoadedAsync();
            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            base.OnInitialized();
        }

        protected override async Task OnInitializedAsync()
        {
            await GetSanitaryMatrixVersions();
            await GetSanitaryTemplates();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetAggregateActionsReportSanitaryMeasuresSection.SetDotNetReference", _token, lDotNetReference);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override void Dispose(bool disposing)
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
                case "SanitaryReportDisabledIndicator":
                    if (SanitaryMatrixFlexForm != null)
                        await SanitaryMatrixFlexForm.Refresh(StateContainer.SanitaryReportDisabledIndicator);
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
            await LoadSanitaryFlexForm();
        }

        #endregion LifeCycle Methods

        #region Flex Form

        protected async Task LoadSanitaryFlexForm()
        {
            // set up the flex form matrix
            StateContainer.SanitaryFlexFormRequest.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SanitaryActionColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SanitaryCodeColumnHeading)
            };

            StateContainer.SanitaryFlexFormRequest.Title = "Sanitary";
            StateContainer.SanitaryFlexFormRequest.LangID = GetCurrentLanguage();
            StateContainer.SanitaryFlexFormRequest.idfsFormType = (long)FlexibleFormTypes.VeterinarySanitary;
            StateContainer.SanitaryFlexFormRequest.idfsFormTemplate ??= StateContainer.SanitaryTemplateIDDefault;
            StateContainer.SanitaryMatrixVersionID ??= StateContainer.SanitaryMatrixVersionIDDefault;
            if (StateContainer.SanitaryObservationID is not null)
                StateContainer.SanitaryFlexFormRequest.idfObservation = StateContainer.SanitaryObservationID;

            var lstSanitaryActionTypes = await SanitaryActionsMatrixClient.GetVeterinarySanitaryActionTypes(ReferenceEditorType.Sanitary, HACodeList.LivestockHACode, GetCurrentLanguage());
            var matrixRows = await SanitaryActionsMatrixClient.GetVeterinarySanitaryActionMatrixReport(GetCurrentLanguage(), StateContainer.SanitaryMatrixVersionID.GetValueOrDefault());

            StateContainer.SanitaryFlexFormRequest.MatrixData = new List<FlexFormMatrixData>();
            foreach (var row in matrixRows)
            {
                var matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),
                    idfRow = row.IdfAggrSanitaryActionMTX
                };

                matrixData.MatrixData.Add(lstSanitaryActionTypes.Find(v => v.IdfsBaseReference == row.IdfsSanitaryAction)?.StrDefault);
                matrixData.MatrixData.Add(row.StrActionCode);
                StateContainer.SanitaryFlexFormRequest.MatrixData.Add(matrixData);
            }

            StateContainer.SanitaryFlexFormRenderIndicator = true;

            await InvokeAsync(StateHasChanged);
        }

        protected async Task SaveSanitaryMatrixFlexForm()
        {
            await SanitaryMatrixFlexForm?.SaveFlexForm();
        }

        #endregion Flex Form

        #region Load Data

        protected async Task GetSanitaryMatrixVersions()
        {
            try
            {
                StateContainer.SanitaryMatrixList = await CrossCuttingClient.GetMatrixVersionsByType(MatrixTypes.VeterinarySanitaryMeasures);
                StateContainer.SanitaryMatrixVersionIDDefault = StateContainer.SanitaryMatrixList != null && StateContainer.SanitaryMatrixList.Any() ? StateContainer.SanitaryMatrixList.FirstOrDefault(x => x.BlnIsActive == true)?.IdfVersion : null;
                if (StateContainer.SanitaryMatrixVersionIDDefault != null && StateContainer.SanitaryMatrixVersionID is null)
                    StateContainer.SanitaryMatrixVersionID = StateContainer.SanitaryMatrixVersionIDDefault;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetSanitaryTemplates()
        {
            FlexFormTemplateGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = null;
                request.idfsFormType = (long)FlexibleFormTypes.VeterinarySanitary;

                StateContainer.SanitaryTemplatesList = await FlexFormClient.GetTemplateList(request);
                StateContainer.SanitaryTemplateIDDefault = StateContainer.SanitaryTemplatesList != null && StateContainer.SanitaryTemplatesList.Any() ? StateContainer.SanitaryTemplatesList.FirstOrDefault(x => x.blnUNI)?.idfsFormTemplate : null;
                if (StateContainer.SanitaryTemplateIDDefault != null && StateContainer.SanitaryFlexFormRequest.idfsFormTemplate is null)
                    StateContainer.SanitaryFlexFormRequest.idfsFormTemplate = StateContainer.SanitaryTemplateIDDefault;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion Load Data

        #region Matrix Version Change Event

        protected async Task OnMatrixVersionChange()
        {
            await LoadSanitaryFlexForm();
            if (SanitaryMatrixFlexForm != null)
                await SanitaryMatrixFlexForm.Render();
        }

        protected async Task OnTemplateChange()
        {
            await LoadSanitaryFlexForm();
            if (SanitaryMatrixFlexForm != null)
                await SanitaryMatrixFlexForm.Render();
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            // if the first section does not validate or the matrix data has no rows, don't save observation
            if (!StateContainer.ReportInformationValidIndicator) return StateContainer.SanitarySectionValidIndicator;

            // if there are no controls in the flex form matrix because the template has not been
            // established, just return true
            if (SanitaryMatrixFlexForm is null || SanitaryMatrixFlexForm?.ComponentParameters.Count == 0)
            {
                StateContainer.SanitarySectionValidIndicator = true;
                return StateContainer.SanitarySectionValidIndicator;
            }

            await SaveSanitaryMatrixFlexForm();

            await InvokeAsync(StateHasChanged);

            StateContainer.SanitaryObservationID = StateContainer.SanitaryFlexFormRequest.idfObservation;

            if (StateContainer.SanitaryObservationID is not null)
                StateContainer.SanitarySectionValidIndicator = true;

            return StateContainer.SanitarySectionValidIndicator;
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
                StateContainer.SanitaryReportDisabledIndicator = true;
            }
            else
            {
                if ((StateContainer.ReportKey <= 0 && !StateContainer.VeterinaryAggregateActionsReportPermissions.Create)
                    || (StateContainer.ReportKey > 0 && !StateContainer.VeterinaryAggregateActionsReportPermissions.Write))
                {
                    StateContainer.SanitaryReportDisabledIndicator = true;
                }
                else
                {
                    StateContainer.SanitaryReportDisabledIndicator = false;
                }
            }
        }

        #endregion Set ReportDisabledIndicators

        #endregion Methods
    }
}