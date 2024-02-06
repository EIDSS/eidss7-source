using System;
using System.Threading.Tasks;
using EIDSS.Web.Abstracts;
using System.Threading;
using Microsoft.AspNetCore.Components;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Services;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class SummaryHeaderBase : ParentComponent, IDisposable
    {
        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        private ILogger<SessionInformationBase> Logger { get; set; }
        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion

        protected override async Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;
                model = StateContainer.Model;

                if (model.Summary == null)
                {
                    model.Summary = new ActiveSurveillanceSessionSummaryHeader();
                }

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}