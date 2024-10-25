using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DiseaseReportsSectionBase : SurveillanceSessionBaseComponent
    {
        [Inject]
        private ILogger<DiseaseReportsSectionBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            return base.OnInitializedAsync();
        }
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {

                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetSurveillanceDiseaseReportsSection.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

        }

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            var validIndicator = ValidateDiseaseReportsSection();
 
            return validIndicator;
        }


        #endregion

    }
}
