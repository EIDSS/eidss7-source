using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IStatisticalDataClient
    {
        Task<List<StatisticalDataResponseModel>> GetStatisticalData(StatisticalDataRequestModel request);
        Task<List<USP_ADMIN_STAT_SETResultResponseModel>> SaveStatisticalData(USP_ADMIN_STAT_SETResultRequestModel request);
        Task<List<USP_ADMIN_STAT_GetDetailResultResponseModel>> GetStatisticalDataDetails(USP_ADMIN_STAT_GetDetailResultRequestModel request);
        Task<List<USP_ADMIN_STAT_DELResultResponseModel>> DeleteStatisticalData(USP_ADMIN_STAT_DELResultRequestModel request);
    }
    public partial class StatisticalDataClient : BaseApiClient, IStatisticalDataClient
    {
        public StatisticalDataClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<StatisticalTypeClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<StatisticalDataResponseModel>> GetStatisticalData(StatisticalDataRequestModel request)
        {
            try
            {
                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetStatisticalDataPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, sampleTypesViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<StatisticalDataResponseModel>>(contentStream,
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
                throw; // new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<USP_ADMIN_STAT_SETResultResponseModel>> SaveStatisticalData(USP_ADMIN_STAT_SETResultRequestModel request)
        {
            try
            {
                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveStatisticalDataPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, sampleTypesViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_ADMIN_STAT_SETResultResponseModel>>(contentStream,
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
                throw; // new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<USP_ADMIN_STAT_GetDetailResultResponseModel>> GetStatisticalDataDetails(USP_ADMIN_STAT_GetDetailResultRequestModel request)
        {
            try
            {
                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetStatisticalDataDetailsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, sampleTypesViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_ADMIN_STAT_GetDetailResultResponseModel>>(contentStream,
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
                throw; // new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<USP_ADMIN_STAT_DELResultResponseModel>> DeleteStatisticalData(USP_ADMIN_STAT_DELResultRequestModel request)
        {
            try
            {
                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteStatisticalDataPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, sampleTypesViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_ADMIN_STAT_DELResultResponseModel>>(contentStream,
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
                throw; // new NotImplementedException();
            }
            finally
            {
            }
        }
    }
}
