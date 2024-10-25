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
    public partial interface IVeterinarySanitaryActionMatrixClient
    {
        Task<List<VeterinarySanitaryActionMatrixViewModel>> GetVeterinarySanitaryActionMatrixReport(string LangID, long idfVersion);
        Task<List<InvestigationTypeViewModel>> GetVeterinarySanitaryActionTypes(long idfsBaseReference, int intHACode, string languageId);
        Task<APIPostResponseModel> DeleteVeterinarySanitaryActionMatrixRecord(MatrixViewModel request);
        Task<APIPostResponseModel> SaveVeterinarySanitaryActionMatrix(MatrixViewModel request);
    }

    public partial class VeterinarySanitaryActionMatrixClient : BaseApiClient, IVeterinarySanitaryActionMatrixClient
    {
        public VeterinarySanitaryActionMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<VeterinarySanitaryActionMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteVeterinarySanitaryActionMatrixRecord(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteVeterinarySanitaryActionMatrixRecordPath, _eidssApiOptions.BaseUrl);
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

        public async Task<List<VeterinarySanitaryActionMatrixViewModel>> GetVeterinarySanitaryActionMatrixReport(string LangID, long idfVersion)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVeterinarySanitaryActionMatrixReportPath, _eidssApiOptions.BaseUrl, LangID, idfVersion);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VeterinarySanitaryActionMatrixViewModel>>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, idfVersion);
                throw;
            }
        }

        public async Task<List<InvestigationTypeViewModel>> GetVeterinarySanitaryActionTypes(long idfsBaseReference, int intHACode, string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVeterinarySanitaryActionTypesListAsyncPath, _eidssApiOptions.BaseUrl, idfsBaseReference, intHACode, languageId);
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
                _logger.LogError(ex.Message, idfsBaseReference);
                throw;
            }
        }

        public async Task<APIPostResponseModel> SaveVeterinarySanitaryActionMatrix(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveVeterinarySanitaryActionMatrixPath, _eidssApiOptions.BaseUrl);
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
