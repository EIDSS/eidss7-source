using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using static System.String;

namespace EIDSS.ClientLibrary.ApiClients.Notification
{
    public interface INotificationClient
    {
        Task<List<EventCountResponseModel>> GetEventCount(EventGetListRequestModel request, CancellationToken cancellationToken = default);
        Task<List<EventGetListViewModel>> GetEventList(EventGetListRequestModel request, CancellationToken cancellationToken = default);
        Task<EventSaveRequestResponseModel> SaveEventStatus(EventStatusSaveRequestModel request, CancellationToken cancellationToken = default);
        Task<APIPostResponseModel> SaveEvent(EventSaveRequestModel request, CancellationToken cancellationToken = default);
    }

    public class NotificationClient : BaseApiClient, INotificationClient
    {
        public NotificationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<NotificationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<EventCountResponseModel>> GetEventCount(EventGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = Format(_eidssApiOptions.GetEventCountPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<EventCountResponseModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<List<EventGetListViewModel>> GetEventList(EventGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = Format(_eidssApiOptions.GetEventListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<EventGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> SaveEvent(EventSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = Format(_eidssApiOptions.SaveEventPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<EventSaveRequestResponseModel> SaveEventStatus(EventStatusSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = Format(_eidssApiOptions.SaveEventStatusPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<EventSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }
    }
}
