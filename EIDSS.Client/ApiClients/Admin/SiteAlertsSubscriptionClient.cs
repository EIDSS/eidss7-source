using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{

    public partial interface ISiteAlertsSubscriptionClient
    {
        Task<List<EventSubscriptionTypeModel>> GetSiteAlertsSubscriptionList(EventSubscriptionGetRequestModel model);
        Task<SitelAlertsSubcriptionSaveResponseModel> SaveSiteAlertSubscription(SiteAlertEventSaveRequestModel request);

        Task<List<NeighboringSiteListViewModel>> GetNeighboringSiteList(NeighboringSiteGetRequestModel model);
    }

    public partial class SiteAlertsSubscriptionClient : BaseApiClient, ISiteAlertsSubscriptionClient
    {
        public SiteAlertsSubscriptionClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SiteAlertsSubscriptionClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<EventSubscriptionTypeModel>> GetSiteAlertsSubscriptionList(EventSubscriptionGetRequestModel model)
        {

            try
            {
                var url = string.Format(_eidssApiOptions.GetSiteAlertsSubscriptionListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(model), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<List<EventSubscriptionTypeModel>>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { model });
                throw;
            }
            finally
            {
            }

        }

        public async Task<SitelAlertsSubcriptionSaveResponseModel> SaveSiteAlertSubscription(SiteAlertEventSaveRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSiteAlertSubscriptionPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<SitelAlertsSubcriptionSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }
        public async Task<List<NeighboringSiteListViewModel>> GetNeighboringSiteList(NeighboringSiteGetRequestModel model)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetNeighboringSiteListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(model), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<List<NeighboringSiteListViewModel>>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { model });
                throw;
            }
            finally
            {
            }
        }
    }
}
