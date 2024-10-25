using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Administration;
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
    public partial interface IDiseaseAgeGroupMatrixClient
    {
        Task<List<DiseaseAgeGroupMatrixViewModel>> GetDiseaseAgeGroupMatrix(DiseaseAgeGroupGetRequestModel request);
        Task<AgeGroupSaveRequestResponseModel> DeleteDiseaseAgeGroupMatrixRecord(DiseaseAgeGroupSaveRequestModel request);
        Task<AgeGroupSaveRequestResponseModel> SaveDiseaseAgeGroupMatrix(DiseaseAgeGroupSaveRequestModel saveRequestModel);
    }

    public partial class DiseaseAgeGroupMatrixClient : BaseApiClient, IDiseaseAgeGroupMatrixClient
    {
        public DiseaseAgeGroupMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<DiseaseAgeGroupMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<AgeGroupSaveRequestResponseModel> DeleteDiseaseAgeGroupMatrixRecord(DiseaseAgeGroupSaveRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteDiseaseAgeGroupMatrixRecordPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<AgeGroupSaveRequestResponseModel>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });

                return response;
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<DiseaseAgeGroupMatrixViewModel>> GetDiseaseAgeGroupMatrix(DiseaseAgeGroupGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetDiseaseAgeGroupMatrixListAsyncPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DiseaseAgeGroupMatrixViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<AgeGroupSaveRequestResponseModel> SaveDiseaseAgeGroupMatrix(DiseaseAgeGroupSaveRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveDiseaseAgeGroupMatrixPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<AgeGroupSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
