#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Notification;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.JSInterop;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;

#endregion

namespace EIDSS.Web.Components.Notification
{
    public class NotificationEnvelopeComponentBase : BaseComponent, IDisposable
    {
        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private INotificationClient NotificationClient { get; set; }
        [Inject] private ILogger<NotificationEnvelopeComponentBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Properties

        protected int MessageCount { get; set; }
        protected List<EventCountResponseModel> SearchResults;

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #region Methods

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
                await GetNotificationCount();
                await InvokeAsync(StateHasChanged);

                await JsRuntime.InvokeVoidAsync("Notification.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this))
                    .ConfigureAwait(false);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task GetNotificationCount()
        {
            var user = _tokenService.GetAuthenticatedUser();

            if (user != null)
            {
                var request = new EventGetListRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DaysFromReadDate =
                        Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault),
                    UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId),
                    SortColumn = "EventDate",
                    SortOrder = SortConstants.Descending,
                    Page = 1,
                    PageSize = MaxValue - 1
                };

                SearchResults = await NotificationClient.GetEventCount(request, _token).ConfigureAwait(false);
                MessageCount = SearchResults.Any() ? SearchResults.First().EventCount : 0;
            }
        }

        public EventCallback UpdateEnvelopeHandler =>
            new(this, (Action)RefreshEnvelopeCount);

        private async void RefreshEnvelopeCount()
        {
            await GetNotificationCount();

            if (MessageCount == 0) // TODO: the UI does not update when the count is zero.  Have not determined why this happens, so this is a temp fix.
            {
                await JsRuntime.InvokeAsync<string>("setNotificationEnvelopeCount", _token, null, false);
            }

            await InvokeAsync(StateHasChanged);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task ShowNotifications()
        {
            var dialogParams = new Dictionary<string, object> {{"NotificationCountChanged", UpdateEnvelopeHandler}};

            await DiagService.OpenAsync<NotificationComponent>(
                Localizer.GetString(HeadingResourceKeyConstants.SiteAlertMessengerModalSiteAlertMessengerHeading),
                dialogParams
                , new DialogOptions {Width = "700px", Resizable = true, Draggable = false});
        }

        /// <summary>
        /// Cancel any background tasks and remove event handlers.
        /// </summary>
        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion
    }
}