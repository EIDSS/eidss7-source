#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Administration.SiteAlertSubscription
{
    public class SubscriptionManagementBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<SubscriptionManagementBase> Logger { get; set; }
        [Inject] private ISiteAlertsSubscriptionClient SiteAlertSubscriptionClient { get; set; }

        #endregion

        #region Parameters

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public IList<EventSubscriptionTypeModel> Subscriptions { get; set; }
        protected List<EventSubscriptionTypeModel> PendingSaveSubscriptions { get; set; }
        public bool WritePermissionIndicator { get; set; }
        protected RadzenDataGrid<EventSubscriptionTypeModel> SubscriptionsGrid { get; set; }
        public int Count { get; set; }
        public string SearchTerm { get; set; }
        public bool SaveDisabledIndicator { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "EventTypeName";

        #endregion

        #endregion

        #region Constructors

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _userPermissions = GetUserPermissions(PagePermission.AccessToOutbreakVectorData);

            WritePermissionIndicator = _userPermissions.Write;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            _disposedValue = true;
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

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                IsLoading = true;
                SaveDisabledIndicator = true;
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadSubscriptionData(LoadDataArgs args)
        {
            try
            {
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Ascending;

                if (args.Top != null)
                {
                    if (Subscriptions is null)
                        IsLoading = true;

                    if (IsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        var requestModel = new EventSubscriptionGetRequestModel
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = MaxValue - 1,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder,
                            SiteAlertName = SearchTerm,
                            UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                        };

                        Subscriptions = await SiteAlertSubscriptionClient.GetSiteAlertsSubscriptionList(requestModel);
                    }
                    else if (Subscriptions != null)
                    {
                        Count = Subscriptions.Count;
                    }
                }

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
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveSubscriptions(EventSubscriptionTypeModel record,
            EventSubscriptionTypeModel originalRecord)
        {
            PendingSaveSubscriptions ??= new List<EventSubscriptionTypeModel>();

            if (PendingSaveSubscriptions.Any(x => x.EventNameId == record.EventNameId))
            {
                var index = PendingSaveSubscriptions.IndexOf(originalRecord);
                PendingSaveSubscriptions[index] = record;
            }
            else
            {
                PendingSaveSubscriptions.Add(record);
            }

            SaveDisabledIndicator = false;
        }

        #endregion

        #region Toggle Receive Alert Methods

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnToggleReceiveAlertIndicatorClick(bool value)
        {
            try
            {
                foreach (var item in Subscriptions)
                {
                    item.ReceiveAlertIndicator = value;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSearchButtonClick()
        {
            Subscriptions = null;
            await InvokeAsync(() =>
            {
                SubscriptionsGrid.Reload();
                StateHasChanged();
            });

            
        }

        #endregion

        #region Clear Search Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnClearSearchButtonClick()
        {
            SearchTerm = null;
            Subscriptions = null;
            await InvokeAsync(() =>
            {
                SubscriptionsGrid.Reload();
                StateHasChanged();
            });
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSaveButtonClick()
        {
            try
            {
                var request = new SiteAlertEventSaveRequestModel
                {
                    Subscriptions = JsonConvert.SerializeObject(BuildSubscriptionParameters(Subscriptions)),
                    UserName = authenticatedUser.UserName
                };
                var response =
                    await SiteAlertSubscriptionClient.SaveSiteAlertSubscription(request);

                if (response.ReturnCode != null)
                {
                    var result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                        null, ButtonResourceKeyConstants.OKButton, null, null);

                    if (result is DialogReturnResult)
                    {
                        DiagService.Close();
                    }
                }
                else
                    throw new ApplicationException("Unable to save site alert subscription.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="subscriptions"></param>
        /// <returns></returns>
        private static List<SubscriptionSaveRequestModel> BuildSubscriptionParameters(
            IList<EventSubscriptionTypeModel> subscriptions)
        {
            List<SubscriptionSaveRequestModel> requests = new();

            if (subscriptions is null)
                return new List<SubscriptionSaveRequestModel>();

            foreach (var subscription in subscriptions)
            {
                var request = new SubscriptionSaveRequestModel();
                {
                    request.RowId = subscription.RowId;
                    request.EventTypeId = subscription.EventNameId;
                    request.UserId = subscription.UserId;
                    request.ReceiveAlertIndicator = subscription.ReceiveAlertIndicator;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #endregion
    }
}