using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Services;
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

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class DetailedInformationSectionBase : SurveillanceSessionBaseComponent
    {

        [Inject]
        private ILogger<DetailedInformationSectionBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            MessageStore = new List<EIDSSValidationMessageStore>();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {

                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetSurveillanceDetailedInformationSection.SetDotNetReference", _token, lDotNetReference)
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
            bool validIndicator;
            if (StateContainer.FarmInventory != null && StateContainer.FarmInventory.Any())
                validIndicator = await ValidateFarmInventory(StateContainer.FarmInventory);
            else
                validIndicator = true;

            StateContainer.SessionDetailedInformationValidIndicator = validIndicator;

            return validIndicator;
        }


        #endregion
    }
}
