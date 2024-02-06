#region Usings

using System;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case.Veterinary
{
    public class CaseSummaryBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CaseSummaryBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<CaseGetDetailViewModel> Form { get; set; }

        public string RelatedToResourceKey { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        public CaseSummaryBase(CancellationToken token) : base(token)
        {
        }

        protected CaseSummaryBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            GetUserPermissions(PagePermission.AccessToOutbreakVeterinaryCaseData);

            RelatedToResourceKey = Localizer.GetString(FieldLabelResourceKeyConstants
                    .OutbreakCaseSummaryRelatedToFieldLabel);

            Form = new RadzenTemplateForm<CaseGetDetailViewModel>
            {
                EditContext = new EditContext(Model)
            };

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
                await JsRuntime.InvokeVoidAsync("CaseSummary.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);
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

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSummary()
        {
            return true;
        }

        #endregion

        #region Refresh Summary Method

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        [JSInvokable]
        public void RefreshSummary(bool isReview)
        {
            Model.CaseDisabledIndicator = isReview;

            StateHasChanged();
        }

        #endregion

        #region Related to Disease Report Button Click Event
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="outbreakId"></param>
        /// <returns></returns>
        protected async Task OnRelatedToDiseaseReportClick(string diseaseReportId, string outbreakId)
        {
            try
            {
                if (Form.EditContext.IsModified() ||
                    Model.VeterinaryDiseaseReport.FarmDetailsSectionModifiedIndicator ||
                    Model.VeterinaryDiseaseReport.NotificationSectionModifiedIndicator ||
                    Model.VeterinaryDiseaseReport.FarmEpidemiologicalInfoSectionModifiedIndicator ||
                    Model.VeterinaryDiseaseReport.SpeciesClinicalInvestigationInfoSectionModifiedIndicator ||
                    Model.VeterinaryDiseaseReport.ControlMeasuresSectionModifiedIndicator ||
                    Model.VeterinaryDiseaseReport.PendingSaveAnimals is not null && Model.VeterinaryDiseaseReport.PendingSaveAnimals.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSaveCaseLogs is not null && Model.VeterinaryDiseaseReport.PendingSaveCaseLogs.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSaveLaboratoryTestInterpretations is not null &&
                    Model.VeterinaryDiseaseReport.PendingSaveLaboratoryTestInterpretations.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSaveLaboratoryTests is not null && Model.VeterinaryDiseaseReport.PendingSaveLaboratoryTests.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSaveEvents is not null && Model.VeterinaryDiseaseReport.PendingSaveEvents.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSavePensideTests is not null && Model.VeterinaryDiseaseReport.PendingSavePensideTests.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSaveSamples is not null && Model.VeterinaryDiseaseReport.PendingSaveSamples.Count > 0 ||
                    Model.VeterinaryDiseaseReport.PendingSaveVaccinations is not null && Model.VeterinaryDiseaseReport.PendingSaveVaccinations.Count > 0)
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText != Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            _source?.Cancel();

                            string uri;

                            if (outbreakId is null)
                            {
                                const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                                var query =
                                    $"?reportTypeID={Model.VeterinaryDiseaseReport.ReportCategoryTypeID}&farmID={Model.VeterinaryDiseaseReport.FarmID}&diseaseReportID={diseaseReportId}&isEdit=true";
                                uri = $"{NavManager.BaseUri}{path}{query}";
                            }
                            else
                            {
                                const string path = "Outbreak/OutbreakSession/Edit";
                                var query = $"?queryData={Model.OutbreakId}";
                                uri = $"{NavManager.BaseUri}{path}{query}";
                            }

                            NavManager.NavigateTo(uri, true);
                        }
                        else
                        {
                            DiagService.Close(result);

                            if (Model.VeterinaryDiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                                await JsRuntime.InvokeAsync<string>("validateAvianDiseaseReport", _token, null, false);
                            else
                                await JsRuntime.InvokeAsync<string>("validateLivestockDiseaseReport", _token, null, false);
                        }
                    }
                }
                else
                {
                    _source?.Cancel();

                    string uri;

                    if (outbreakId is null)
                    {
                        const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                        var query =
                            $"?reportTypeID={Model.VeterinaryDiseaseReport.ReportCategoryTypeID}&farmID={Model.VeterinaryDiseaseReport.FarmID}&diseaseReportID={diseaseReportId}&isEdit=true";
                        uri = $"{NavManager.BaseUri}{path}{query}";
                    }
                    else
                    {
                        const string path = "Outbreak/OutbreakSession/Edit";
                        var query = $"?queryData={Model.OutbreakId}";
                        uri = $"{NavManager.BaseUri}{path}{query}";
                    }

                    NavManager.NavigateTo(uri, true);
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