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

    public partial interface IHumanAggregateDiseaseMatrixClient
    {
        Task<List<HumanAggregateDiseaseMatrixViewModel>> GetHumanAggregateDiseaseMatrixList(HumanAggregateCaseMatrixGetRequestModel request);
        Task<APIPostResponseModel> DeleteHumanAggregateDiseaseMatrixRecord(MatrixViewModel request);
        Task<APIPostResponseModel> SaveHumanAggregateDiseaseMatrix(MatrixViewModel request);
        Task<List<HumanDiseaseDiagnosisListViewModel>> GetHumanDiseaseDiagnosisMatrixListAsync(long usingType, long intHACode, string strLanguageID);
    }
    public partial class HumanAggregateDiseaseMatrixClient : BaseApiClient, IHumanAggregateDiseaseMatrixClient
    {
        public HumanAggregateDiseaseMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<HumanAggregateDiseaseMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteHumanAggregateDiseaseMatrixRecord(MatrixViewModel request)
        {
            var url = string.Format(_eidssApiOptions.DeleteHumanAggregateDiseaseMatrixRecordPath, _eidssApiOptions.BaseUrl);
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

        public async Task<List<HumanAggregateDiseaseMatrixViewModel>> GetHumanAggregateDiseaseMatrixList(HumanAggregateCaseMatrixGetRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.GetHumanAggregateDiseaseMatrixListAsyncPath, _eidssApiOptions.BaseUrl);
            var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var httpResponse = await _httpClient.PostAsync(url, stringContent);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<HumanAggregateDiseaseMatrixViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });
        }

        public async Task<List<HumanDiseaseDiagnosisListViewModel>> GetHumanDiseaseDiagnosisMatrixListAsync(long usingType, long intHACode, string languageID)
        {
            var url = string.Format(_eidssApiOptions.GetHumanDiseaseDiagnosisMatrixListAsyncPath, _eidssApiOptions.BaseUrl, usingType, intHACode, languageID);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<List<HumanDiseaseDiagnosisListViewModel>>(contentStream,
               new JsonSerializerOptions
               {
                   IgnoreNullValues = true,
                   PropertyNameCaseInsensitive = true
               });

            return response;
        }

        public async Task<APIPostResponseModel> SaveHumanAggregateDiseaseMatrix(MatrixViewModel request)
        {
            var url = string.Format(_eidssApiOptions.SaveHumanAggregateDiseaseMatrixPath, _eidssApiOptions.BaseUrl);
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
    }
}