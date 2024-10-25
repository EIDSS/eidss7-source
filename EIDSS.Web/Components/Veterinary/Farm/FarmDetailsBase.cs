#region Usings

using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class FarmDetailsBase : FarmBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmDetailsBase> Logger { get; set; }
        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Properties

        protected IList<BaseReferenceViewModel> OwnershipStructures { get; set; }
        protected IList<BaseReferenceViewModel> AvianFarmTypes { get; set; }
        protected RadzenTemplateForm<FarmStateContainer> Form { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("FarmDetailsSection.SetDotNetReference", _token, dotNetReference);

                await GetOwnershipStructures().ConfigureAwait(false);

                await GetAvianFarmTypes().ConfigureAwait(false);

                StateContainer.OnChange += async _ => await OnStateContainerChangeAsync();
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            if (StateContainer != null)
                StateContainer.OnChange -= async _ => await OnStateContainerChangeAsync();
        }

        #endregion

        #region Load Data Methods and Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);

            StateContainer.FarmAddressSectionChangedIndicator = Form.EditContext.IsModified();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetOwnershipStructures()
        {
            try
            {
                OwnershipStructures = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.FarmOwnershipType, HACodeList.LiveStockAndAvian);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetAvianFarmTypes()
        {
            try
            {
                AvianFarmTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AvianFarmType, HACodeList.AvianHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        protected void SetFormIsModified()
        {
            StateContainer.FarmAddressSectionChangedIndicator = true;
        }

        #endregion

        #region Validation Methods

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            Form.EditContext?.MarkAsUnmodified();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion
    }
}