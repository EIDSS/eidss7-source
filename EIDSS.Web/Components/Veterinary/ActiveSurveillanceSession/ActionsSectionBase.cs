using EIDSS.Web.Areas.Veterinary.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class ActionsSectionBase : SurveillanceSessionBaseComponent
    {
        [Inject]
        private ILogger<ActionsSectionBase> Logger { get; set; }

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
                await JsRuntime.InvokeVoidAsync("VetSurveillanceActionsSection.SetDotNetReference", _token, lDotNetReference)
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
            var validIndicator = ValidateActionsSection();
            //if (validIndicator)
            //    await JsRuntime.InvokeAsync<string>("reloadClinicalInvestigationSection", _token);

            return validIndicator;
        }


        #endregion
    }
}
