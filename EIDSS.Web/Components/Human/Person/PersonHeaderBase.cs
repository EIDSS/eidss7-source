using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonHeaderBase : PersonBaseComponent
    {
        [Inject]
        private ILogger<PersonHeaderBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }        

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected RadzenTemplateForm<PersonStateContainer> Form;

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
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.PersonHeaderSection.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        public async Task RefreshComponent()
        {
            await InvokeAsync(StateHasChanged);
        }

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        //[JSInvokable]
        public bool ValidateSection()
        {
            var validIndicator = ValidatePersonHeaderSection();
            //if (validIndicator)
            //    await JsRuntime.InvokeAsync<string>("reloadClinicalInvestigationSection", _token);

            return validIndicator;
        }

        #endregion

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
    }
}
