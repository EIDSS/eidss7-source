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
    public partial interface IVeterinaryProphylacticMeasureMatrixClient
    {
        Task<List<VeterinaryProphylacticMeasureMatrixViewModel>> GetVeterinaryProphylacticMeasureMatrixReport(VeterinaryProphylacticMeasureMatrixGetRequestModel request);
        Task<List<InvestigationTypeViewModel>> GetVeterinaryProphylacticMeasureTypes(long idfsBaseReference, int intHACode, string languageId);
        Task<APIPostResponseModel> DeleteVeterinaryProphylacticMeasureMatrixRecord(MatrixViewModel request);
        Task<APIPostResponseModel> SaveVeterinaryProphylacticMeasureMatrix(MatrixViewModel request);
    }

    public partial class VeterinaryProphylacticMeasureMatrixClient : BaseApiClient, IVeterinaryProphylacticMeasureMatrixClient
    {
        public VeterinaryProphylacticMeasureMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<VeterinaryProphylacticMeasureMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteVeterinaryProphylacticMeasureMatrixRecord(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteVeterinaryProphylacticMeasureMatrixRecordPath, _eidssApiOptions.BaseUrl);
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

        public async Task<List<VeterinaryProphylacticMeasureMatrixViewModel>> GetVeterinaryProphylacticMeasureMatrixReport(VeterinaryProphylacticMeasureMatrixGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVeterinaryProphylacticMeasureMatrixReportPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(new Uri(url), stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VeterinaryProphylacticMeasureMatrixViewModel>>(contentStream,
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

        public async Task<List<InvestigationTypeViewModel>> GetVeterinaryProphylacticMeasureTypes(long idfsBaseReference, int intHACode, string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVeterinaryProphylacticMeasureTypesPath, _eidssApiOptions.BaseUrl, idfsBaseReference, intHACode, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<InvestigationTypeViewModel>>(contentStream,
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

        public async Task<APIPostResponseModel> SaveVeterinaryProphylacticMeasureMatrix(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveVeterinaryProphylacticMeasureMatrixPath, _eidssApiOptions.BaseUrl);
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
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
