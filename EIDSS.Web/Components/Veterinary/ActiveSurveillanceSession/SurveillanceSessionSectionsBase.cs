using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System.Threading;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class SurveillanceSessionSectionsBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ILogger<SurveillanceSessionSectionsBase> Logger { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        public void Dispose()
        {
            try
            {
                _source?.Cancel();
                _source?.Dispose();
            }
            catch (System.Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }

        #endregion Methods
    }
}