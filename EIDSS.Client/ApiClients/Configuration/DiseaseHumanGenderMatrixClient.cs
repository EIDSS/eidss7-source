using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
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
    public partial interface IDiseaseHumanGenderMatrixClient
    {
        Task<List<DiseaseHumanGenderMatrixViewModel>> GetDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixGetRequestModel request);
        Task<APISaveResponseModel> SaveDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixSaveRequestModel request);
        Task<APIPostResponseModel> DeleteDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixSaveRequestModel request);
        Task<List<GenderForDiseaseOrDiagnosisGroupViewModel>> GetGenderForDiseaseOrDiagnosisGroupMatrix(GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel request);
    }

    public partial class DiseaseHumanGenderMatrixClient : BaseApiClient, IDiseaseHumanGenderMatrixClient
    {
        public DiseaseHumanGenderMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<DiseaseHumanGenderMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<DiseaseHumanGenderMatrixViewModel>> GetDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixGetRequestModel request)
        {
            List<DiseaseHumanGenderMatrixViewModel> response;

            try
            {
                var url = string.Format(_eidssApiOptions.GetDiseaseHumanGenderMatrixListAsyncPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                response = await JsonSerializer.DeserializeAsync<List<DiseaseHumanGenderMatrixViewModel>>(contentStream,
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

            return response;
        }

        public async Task<List<GenderForDiseaseOrDiagnosisGroupViewModel>> GetGenderForDiseaseOrDiagnosisGroupMatrix(GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel request)
        {
            List<GenderForDiseaseOrDiagnosisGroupViewModel> response;

            try
            {
                var url = string.Format(_eidssApiOptions.GetGenderForDiseaseOrDiagnosisMatrixAsyncPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                response = await JsonSerializer.DeserializeAsync<List<GenderForDiseaseOrDiagnosisGroupViewModel>>(contentStream,
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

            return response;
        }

        public async Task<APISaveResponseModel> SaveDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixSaveRequestModel saveRequestModel)
        {
            APISaveResponseModel response;

            try
            {
                var url = string.Format(_eidssApiOptions.SaveDiseaseHumanGenderMatrixAsyncPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                response = await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
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

            return response;
        }


        public async Task<APIPostResponseModel> DeleteDiseaseHumanGenderMatrix(DiseaseHumanGenderMatrixSaveRequestModel request)
        {
            APIPostResponseModel response;

            try
            {
                var url = string.Format(_eidssApiOptions.DeleteDiseaseHumanGenderMatrixRecordPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
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

            return response;
        }
    }
}
