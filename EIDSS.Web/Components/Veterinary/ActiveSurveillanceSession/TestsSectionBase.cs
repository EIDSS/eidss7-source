using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class TestsSectionBase : SurveillanceSessionBaseComponent
    {
        //MJK - fixing some stuff.

        [Inject]
        private ILogger<TestsSectionBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

   

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

        }

     
    }
}
