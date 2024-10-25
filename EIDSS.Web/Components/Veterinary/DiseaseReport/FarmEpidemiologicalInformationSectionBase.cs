#region Usings

using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    public class FarmEpidemiologicalInformationSectionBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmEpidemiologicalInformationSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] public IFlexFormClient FlexFormClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected FlexForm.FlexForm FarmEpidemiologicalInfo { get; set; }
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

                FarmEpidemiologicalInfo ??= new FlexForm.FlexForm();

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
                FarmEpidemiologicalInfo.FlexFormClient = FlexFormClient;
                await FarmEpidemiologicalInfo.SetRequestParameter(Model.FarmEpidemiologicalInfoFlexForm);

                await JsRuntime
                    .InvokeVoidAsync("FarmEpidemiologicalInformationSection.SetDotNetReference", _token,
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
            Dispose(disposing: true);
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
            try
            {
                Model.FarmEpidemiologicalInfoSectionValidIndicator = true;
                Model.FarmEpidemiologicalInfoSectionModifiedIndicator = FarmEpidemiologicalInfo.IsFormModified();

                if (!Model.FarmEpidemiologicalInfoSectionValidIndicator)
                    return Model.FarmEpidemiologicalInfoSectionValidIndicator;

                if (Model.FarmEpidemiologicalInfoFlexForm is null)
                    return Model.FarmEpidemiologicalInfoSectionValidIndicator;
                if (Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate is null)
                {
                    var questions =
                        await FlexFormClient.GetQuestionnaire(Model.FarmEpidemiologicalInfoFlexForm);

                    if (questions.Count > 0)
                        Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate =
                            questions[0].idfsFormTemplate;
                }

                if (Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate is > 0)
                    await FarmEpidemiologicalInfo.SaveFlexForm();

                Model.FarmEpidemiologicalObservationID = FarmEpidemiologicalInfo.Request.idfObservation;

                await InvokeAsync(StateHasChanged);

                return Model.FarmEpidemiologicalInfoSectionValidIndicator;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
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
            try
            {
                IsReview = isReview;

                var response = await FarmEpidemiologicalInfo.CollectAnswers();
                Model.FarmEpidemiologicalInfoFlexFormAnswers = FarmEpidemiologicalInfo.Answers;
                Model.FarmEpidemiologicalInfoObservationParameters = response.Answers;
                await FarmEpidemiologicalInfo.Render();
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