using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class SurveillanceSessionHeaderBase : SurveillanceSessionBaseComponent
    {
        [Inject]
        private ILogger<SurveillanceSessionHeaderBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected RadzenTemplateForm<VeterinaryActiveSurveillanceSessionStateContainerService> Form;

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            return base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetSurveillanceSessionSummary.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            StateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
        }

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "SessionID" || property == "SessionStatusTypeID" || property == "SessionStatusTypeName" || property == "DiseaseString" || property == "ShowSessionHeaderIndicator")
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            var validIndicator = ValidateSessionHeaderSection();
            //if (validIndicator)
            //    await JsRuntime.InvokeAsync<string>("reloadClinicalInvestigationSection", _token);

            return validIndicator;
        }

        #endregion Validation Methods
    }
}