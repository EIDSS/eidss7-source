#region Usings

using System.Threading;
using System.Threading.Tasks;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class FarmHeaderBase : FarmBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmHeaderBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<FarmStateContainer> Form { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);

            return base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("FarmHeaderSection.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
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
                StateContainer.OnChange -= async property => await OnStateContainerChangeAsync(property);
        }

        #endregion

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property is "DateEntered" or "DateModified") await InvokeAsync(StateHasChanged);
        }

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion
    }
}