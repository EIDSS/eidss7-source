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
    public partial interface IReportDiseaseGroupDiseaseMatrixClient
    {
        Task<List<ReportDiseaseGroupDiseaseMatrixViewModel>> GetReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixGetRequestModel request);
        Task<APISaveResponseModel> SaveReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixSaveRequestModel request);
        Task<APIPostResponseModel> DeleteReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixSaveRequestModel request);        
    }

    public partial class ReportDiseaseGroupDiseaseMatrixClient : BaseApiClient, IReportDiseaseGroupDiseaseMatrixClient
    {
        public ReportDiseaseGroupDiseaseMatrixClient(HttpClient httpClient,
           IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
           ILogger<ReportDiseaseGroupDiseaseMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixSaveRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteReportDiseaseGroupDiseaseMatrixPath, _eidssApiOptions.BaseUrl);
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
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<ReportDiseaseGroupDiseaseMatrixViewModel>> GetReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetReportDiseaseGroupDiseaseMatrixListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<ReportDiseaseGroupDiseaseMatrixViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SaveReportDiseaseGroupDiseaseMatrix(ReportDiseaseGroupDiseaseMatrixSaveRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveReportDiseaseGroupDiseaseMatrixPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
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
