using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;

namespace EIDSS.ClientLibrary.Services
{
    public interface INotificationSiteAlertService
    {
        Task<EventSaveRequestModel> CreateEvent(long objectId, long? diseaseId, SystemEventLogTypes eventTypeId, long siteId, string customMessage);

        Task<List<NeighboringSiteListViewModel>> GetNeighboringSiteList(long? siteId);

        public IList<EventSaveRequestModel> Events { get; set; }
    }

    public class NotificationSiteAlertService : BaseApiClient, INotificationSiteAlertService
    {
        private IEnumerable<EventSubscriptionTypeModel> EventTypes { get; set; }

        internal CultureInfo CultureInfo = Thread.CurrentThread.CurrentCulture;

        public IList<EventSaveRequestModel> Events { get; set; }
        public ISiteAlertsSubscriptionClient SiteAlertsSubscriptionClient { get; set; }

        private readonly AuthenticatedUser _authenticatedUser;

        public ITokenService TokenService;

        protected internal EidssApiConfigurationOptions EidssApiConfigurationOptions;

        public NotificationSiteAlertService(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
          ILogger<NotificationSiteAlertService> logger, ISiteAlertsSubscriptionClient siteAlertsSubscriptionClient, ITokenService tokenService) : base(httpClient, eidssApiOptions, logger)
        {
            EidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
            SiteAlertsSubscriptionClient = siteAlertsSubscriptionClient;
            TokenService = tokenService;
            _authenticatedUser = TokenService.GetAuthenticatedUser();
        }

        public string GetCurrentLanguage()
        {
            return CultureInfo.Name;
        }

        private async Task GetEventTypes()
        {
            try
            {
                if (EventTypes == null)
                {
                    var requestModel = new EventSubscriptionGetRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "EventName",
                        SortOrder = SortConstants.Ascending,
                        SiteAlertName = "", 
                        UserId = Convert.ToInt64(_authenticatedUser.EIDSSUserId)
                    };

                    var list = await SiteAlertsSubscriptionClient.GetSiteAlertsSubscriptionList(requestModel);

                    EventTypes = list;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="objectId"></param>
        /// <param name="diseaseId"></param>
        /// <param name="eventTypeId"></param>
        /// <param name="siteId"></param>
        /// <param name="customMessage"></param>
        /// <returns></returns>
        public async Task<EventSaveRequestModel> CreateEvent(long objectId, long? diseaseId, SystemEventLogTypes eventTypeId, long siteId, string customMessage)
        {
            try
            {
                if (EventTypes is null)
                    await GetEventTypes();

                Events ??= new List<EventSaveRequestModel>();

                var identity = (Events.Count + 1) * -1;

                EventSaveRequestModel eventRecord = new()
                {
                    LoginSiteId = Convert.ToInt64(_authenticatedUser.SiteId),
                    EventId = identity,
                    ObjectId = objectId,
                    DiseaseId = diseaseId,
                    EventTypeId = (long) eventTypeId,
                    InformationString = string.IsNullOrEmpty(customMessage) ? null : customMessage,
                    SiteId = siteId, //site id of where the record was created.
                    UserId = Convert.ToInt64(_authenticatedUser.EIDSSUserId),
                    LocationId = _authenticatedUser.RayonId
                };

                return eventRecord;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, siteId);
                throw;
            }
        }

        public async Task<List<NeighboringSiteListViewModel>> GetNeighboringSiteList(long? siteId)
        {
            try
            {
                var request = new NeighboringSiteGetRequestModel
                {
                    SiteID = siteId
                };
                var response = await SiteAlertsSubscriptionClient.GetNeighboringSiteList(request);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, siteId);
                throw;
            }
        }
    }
}