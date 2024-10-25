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
    public partial interface IVectorTypeCollectionMethodMatrixClient
    {
        public Task<List<VectorTypeCollectionMethodMatrixViewModel>> GetVectorTypeCollectionMethodMatrixList(VectorTypeCollectionMethodMatrixGetRequestModel request);
        public Task<VectorTypeCollectionMethodMatrixSaveRequestResponseModel> SaveVectorTypeCollectionMethodMatrix(VectorTypeCollectionMethodMatrixSaveRequestModel request);
        public Task<APIPostResponseModel> DeleteVectorTypeCollectionMethodMatrix(VectorTypeCollectionMethodMatrixSaveRequestModel request);
    }
    public partial class VectorTypeCollectionMethodMatrixClient : BaseApiClient, IVectorTypeCollectionMethodMatrixClient
    {
        ///api/Configuration/VectorTypeFieldTestMatrix/DeleteFieldTestMatrix
        ///#region Vector Type Field Test Matrix
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public VectorTypeCollectionMethodMatrixClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
        ILogger<VectorTypeCollectionMethodMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<VectorTypeCollectionMethodMatrixViewModel>> GetVectorTypeCollectionMethodMatrixList(VectorTypeCollectionMethodMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorTypeCollectionMethodMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VectorTypeCollectionMethodMatrixViewModel>>(contentStream,
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

        public async Task<VectorTypeCollectionMethodMatrixSaveRequestResponseModel> SaveVectorTypeCollectionMethodMatrix(VectorTypeCollectionMethodMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveVectorTypeCollectionMethodMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<VectorTypeCollectionMethodMatrixSaveRequestResponseModel>(contentStream,
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

        public async Task<APIPostResponseModel> DeleteVectorTypeCollectionMethodMatrix(VectorTypeCollectionMethodMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteVectorTypeCollectionMethodMatrixPath,
                    _eidssApiOptions.BaseUrl);

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