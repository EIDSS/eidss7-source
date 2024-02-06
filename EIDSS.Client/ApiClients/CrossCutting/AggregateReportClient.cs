using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;

namespace EIDSS.ClientLibrary.ApiClients.CrossCutting
{
    public partial interface IAggregateReportClient
    {
        Task<APIPostResponseModel> DeleteAggregateReport(long ID, string User);
        Task<List<AggregateReportGetDetailViewModel>> GetAggregateReportDetail(AggregateReportGetListDetailRequestModel request, CancellationToken token = default);
        Task<List<AggregateReportGetListViewModel>> GetAggregateReportList(AggregateReportSearchRequestModel request, CancellationToken token = default);
        Task<AggregateReportSaveResponseModel> SaveAggregateReport(AggregateReportSaveRequestModel request, CancellationToken token = default);
        Task<ObservationSaveResponseModel> SaveObservation(ObservationSaveRequestModel request);
    }

    public partial class AggregateReportClient : BaseApiClient, IAggregateReportClient
    {
        protected internal EidssApiConfigurationOptions EidssApiConfigurationOptions;

        public AggregateReportClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<AggregateReportClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            EidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<APIPostResponseModel> DeleteAggregateReport(long id, string user)
        {
            var url = string.Format(_eidssApiOptions.DeleteAggregateReportPath, _eidssApiOptions.BaseUrl, id, user);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }

        public async Task<List<AggregateReportGetDetailViewModel>> GetAggregateReportDetail(AggregateReportGetListDetailRequestModel request, CancellationToken token = default)
        {
            try
            {
                var requestContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetAggregateReportDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestContent, token);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<AggregateReportGetDetailViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request.idfAggrCase });
                throw;
            }
            finally
            {
            }
        }
        public async Task<List<AggregateReportGetListViewModel>> GetAggregateReportList(AggregateReportSearchRequestModel request, CancellationToken token = default)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetAggregateReportListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters, token);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<AggregateReportGetListViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }

        public async Task<AggregateReportSaveResponseModel> SaveAggregateReport(AggregateReportSaveRequestModel request, CancellationToken token = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveAggregateReportPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, token);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<AggregateReportSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }

        public async Task<ObservationSaveResponseModel> SaveObservation(ObservationSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveObservationPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ObservationSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }
    }
}
