#region Usings

using System;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class ControlMeasuresSectionBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ControlMeasuresSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] public IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        public FlexForm.FlexForm ControlMeasures { get; set; }
        public bool IsReview { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                _logger = Logger;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                ControlMeasures ??= new FlexForm.FlexForm();
                
                IsReview = Model.ReportViewModeIndicator;

                base.OnInitialized();
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                //catch cancellation exception
                if (e.Message.Contains("The operation was canceled"))
                {
                    
                }
                else
                {
                    throw;
                }
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                ControlMeasures.FlexFormClient = FlexFormClient;
                ControlMeasures.SetRequestParameter(Model.ControlMeasuresFlexForm);

                await JsRuntime
                    .InvokeVoidAsync("ControlMeasuresSection.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);
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

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection()
        {
            Model.ControlMeasuresSectionValidIndicator = true;
            Model.ControlMeasuresSectionModifiedIndicator = ControlMeasures.IsFormModified();

            if (!Model.ControlMeasuresSectionValidIndicator) return Model.ControlMeasuresSectionValidIndicator;

            if (Model.ControlMeasuresFlexForm is not null)
            {
                if (Model.ControlMeasuresFlexForm.idfsFormTemplate is null)
                {
                    var questions =
                        await FlexFormClient.GetQuestionnaire(Model.ControlMeasuresFlexForm);

                    if (questions.Count > 0)
                        Model.ControlMeasuresFlexForm.idfsFormTemplate =
                            questions[0].idfsFormTemplate;
                }

                if (Model.ControlMeasuresFlexForm.idfsFormTemplate is > 0)
                    await ControlMeasures.SaveFlexForm();

                Model.ControlMeasuresObservationID = ControlMeasures.Request.idfObservation;
            }

            await InvokeAsync(StateHasChanged);

            return Model.ControlMeasuresSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection(bool isReview)
        {
            try
            {
                IsReview = isReview;

                var response = Task.Run(() => ControlMeasures.CollectAnswers(), _token);
                response.Wait(_token);
                Model.ControlMeasuresObservationParameters = response.Result.Answers;
                Model.ControlMeasuresFlexFormAnswers = ControlMeasures.Answers;
                ControlMeasures.Render(); 
                StateHasChanged();
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                //catch cancellation exception
                if (e.Message.Contains("The operation was canceled"))
                {
                    
                }
                else
                {
                    throw;
                }
            }
        }

        #endregion

        #endregion
    }
}