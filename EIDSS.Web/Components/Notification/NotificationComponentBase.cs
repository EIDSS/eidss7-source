#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Notification;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Events;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.GC;

#endregion

namespace EIDSS.Web.Components.Notification
{
    public class NotificationComponentBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private INotificationClient NotificationClient { get; set; }
        [Inject] private ILogger<NotificationComponentBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public EventCallback NotificationCountChanged { get; set; }

        #endregion

        #region Properties

        #endregion

        #region Protected and Public Members

        protected RadzenDataGrid<EventGetListViewModel> Grid;
        protected List<EventGetListViewModel> SearchResults;
        private CancellationTokenSource _source;
        private CancellationToken _token;
        protected bool IsLoading;
        protected int Count;
        protected bool NotificationUpdated;
        private bool _disposedValue;

        #endregion

        #region Private Members

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            Eventbase.NotificationTriggered += (_, _) => { };

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
               await LoadData(new LoadDataArgs());
            }

            await base.OnAfterRenderAsync(firstRender);
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

        #region Data Grid Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadData(LoadDataArgs args)
        {
            try
            {
                IsLoading = true;

                var request = new EventGetListRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId),
                    DaysFromReadDate =
                        Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault),
                    SortColumn = "EventDate",
                    SortOrder = EIDSSConstants.SortConstants.Descending,
                    Page = 1,
                    PageSize = 10
                };

                args.Top ??= 0;

                if (args.Sorts is not null)
                {
                    if (args.Sorts.Any())
                    {
                        request.SortColumn = args.Sorts.First().Property;
                        request.SortOrder = args.Sorts.First().SortOrder?.ToString()
                            .Replace("Ascending", EIDSSConstants.SortConstants.Ascending)
                            .Replace("Descending", EIDSSConstants.SortConstants.Descending);
                    }
                    else
                    {
                        request.SortColumn = "EventDate";
                        request.SortOrder = EIDSSConstants.SortConstants.Descending;
                    }
                }
                else
                {
                    request.SortColumn = "EventDate";
                    request.SortOrder = EIDSSConstants.SortConstants.Descending;
                }

                // paging
                if (args.Skip is > 0)
                    request.Page = args.Skip.Value / Grid.PageSize + 1;
                else
                    request.Page = 1;

                request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;

                SearchResults = await NotificationClient.GetEventList(request, _token);

                Count = SearchResults is {Count: > 0} ? SearchResults.First().TotalRowCount : 0;

                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        protected void RowRender(RowRenderEventArgs<EventGetListViewModel> args)
        {
            args.Attributes.Add("style", $"font-weight: {(args.Data.ProcessedIndicator is 0 ? "bold" : "normal")};");
        }

        #endregion

        #region Delete Alert Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        protected async Task OnDeleteAlertButtonClick(EventGetListViewModel model)
        {
            try
            {
                var request = new EventStatusSaveRequestModel
                {
                    EventId = model.EventId,
                    UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId),
                    SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    StatusValue = 2,
                    User = _tokenService.GetAuthenticatedUser().UserName
                };

                var tr = Task.Run(() => NotificationClient.SaveEventStatus(request, _token), _token);
                tr.Wait(_token);

                await InvokeAsync(() =>
                {
                    NotificationUpdated = true;
                    Grid.Reload();
                    NotificationCountChanged.InvokeAsync();
                    StateHasChanged();
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region View Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        protected async Task OnViewAlertButtonClick(EventGetListViewModel model)
        {
            try
            {
                if (model.ProcessedIndicator == 0)
                {
                    var request = new EventStatusSaveRequestModel
                    {
                        EventId = model.EventId,
                        UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId),
                        SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                        StatusValue = 1,
                        User = _tokenService.GetAuthenticatedUser().UserName
                    };

                    var tr = Task.Run(() => NotificationClient.SaveEventStatus(request, _token), _token);
                    tr.Wait(_token);

                    await InvokeAsync(() =>
                    {
                        NotificationUpdated = true;
                        Grid.Reload();
                        NotificationCountChanged.InvokeAsync();
                        StateHasChanged();
                    });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Clear Alerts Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearAlertsButtonClick()
        {
            try
            {
                var request = new EventStatusSaveRequestModel
                {
                    EventId = null,
                    UserId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().EIDSSUserId),
                    SiteId = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    StatusValue = 2,
                    User = _tokenService.GetAuthenticatedUser().UserName
                };

                await NotificationClient.SaveEventStatus(request, _token).ConfigureAwait(false);
               
                NotificationUpdated = true;

                await InvokeAsync(() =>
                {
                    Grid.Reload();
                    NotificationCountChanged.InvokeAsync();
                    StateHasChanged();
                });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Close Dialog Window Button Click Event

        /// <summary>
        /// </summary>
        protected void OnCloseDialogWindowButtonClick()
        {
            try
            {
                DiagService.Close();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}