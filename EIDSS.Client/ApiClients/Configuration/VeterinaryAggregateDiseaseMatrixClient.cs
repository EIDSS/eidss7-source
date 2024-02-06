using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
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
    public partial interface IVeterinaryAggregateDiseaseMatrixClient
    {
        Task<List<VeterinaryAggregateDiseaseMatrixViewModel>> GetVeterinaryAggregateDiseaseMatrixListAsync(string versionList, string LangID);
        Task<APIPostResponseModel> DeleteVeterinaryAggregateDiseaseMatrixRecord(MatrixViewModel request);
        Task<APIPostResponseModel> SaveVeterinaryAggregateDiseaseMatrix(MatrixViewModel request);
    }

    public partial class VeterinaryAggregateDiseaseMatrixClient : BaseApiClient, IVeterinaryAggregateDiseaseMatrixClient
    {
        public VeterinaryAggregateDiseaseMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<VeterinaryAggregateDiseaseMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteVeterinaryAggregateDiseaseMatrixRecord(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteVeterinaryAggregateDiseaseMatrixRecordPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

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

        public async Task<List<VeterinaryAggregateDiseaseMatrixViewModel>> GetVeterinaryAggregateDiseaseMatrixListAsync(string versionList, string LangID)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVeterinaryAggregateDiseaseMatrixListAsyncPath, _eidssApiOptions.BaseUrl, versionList, LangID);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VeterinaryAggregateDiseaseMatrixViewModel>>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, versionList);
                throw;
            }
        }

        public async Task<APIPostResponseModel> SaveVeterinaryAggregateDiseaseMatrix(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveVeterinaryAggregateDiseaseMatrixPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
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
    }

}