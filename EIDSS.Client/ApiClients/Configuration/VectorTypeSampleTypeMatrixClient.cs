using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Configuration
{
    public partial interface IVectorTypeSampleTypeMatrixClient
    {
        public Task<List<VectorTypeSampleTypeMatrixViewModel>> GetVectorTypeSampleTypeMatrixList(VectorTypeSampleTypeMatrixGetRequestModel request);
        public Task<VectorTypeSampleTypeMatrixSaveRequestResponseModel> SaveVectorTypeSampleTypeMatrix(VectorTypeSampleTypeMatrixSaveRequestModel request);
        public Task<APIPostResponseModel> DeleteVectorTypeSampleTypeMatrix(VectorTypeSampleTypeMatrixSaveRequestModel request);
    }
    public partial class VectorTypeSampleTypeMatrixClient : BaseApiClient ,IVectorTypeSampleTypeMatrixClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public VectorTypeSampleTypeMatrixClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
        ILogger<VectorTypeSampleTypeMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }


        public async Task<List<VectorTypeSampleTypeMatrixViewModel>> GetVectorTypeSampleTypeMatrixList(VectorTypeSampleTypeMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorTypeSampleTypeMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VectorTypeSampleTypeMatrixViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<VectorTypeSampleTypeMatrixSaveRequestResponseModel> SaveVectorTypeSampleTypeMatrix(VectorTypeSampleTypeMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveVectorTypeSampleTypeMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<VectorTypeSampleTypeMatrixSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteVectorTypeSampleTypeMatrix(
            VectorTypeSampleTypeMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteVectorTypeSampleTypeMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }
    }
}