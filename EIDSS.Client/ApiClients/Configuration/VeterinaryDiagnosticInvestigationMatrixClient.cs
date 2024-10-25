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
    public partial interface IVeterinaryDiagnosticInvestigationMatrixClient
    {                       
        Task<List<VeterinaryDiagnosticInvestigationMatrixReportModel>> GetVeterinaryDiagnosticInvestigationMatrixReport(MatrixGetRequestModel request);           
        Task<List<InvestigationTypeViewModel>> GetInvestigationTypeMatrixListAsync(long idfsBaseReference, int? intHACode, string strLanguageId);
        Task<APIPostResponseModel> DeleteVeterinaryDiagnosticInvestigationMatrixRecord(MatrixViewModel request);
        Task<APIPostResponseModel> SaveVeterinaryDiagnosticInvestigationMatrix(MatrixViewModel request);
    }

    public partial class VeterinaryDiagnosticInvestigationMatrixClient : BaseApiClient, IVeterinaryDiagnosticInvestigationMatrixClient
    {
        public VeterinaryDiagnosticInvestigationMatrixClient(HttpClient httpClient, 
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions, 
            ILogger<VeterinaryDiagnosticInvestigationMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<VeterinaryDiagnosticInvestigationMatrixReportModel>>
            GetVeterinaryDiagnosticInvestigationMatrixReport(MatrixGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVeterinaryDiagnosticInvestigationMatrixReportPath,
                    _eidssApiOptions.BaseUrl);
                var stringContent =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(new Uri(url), stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response =
                    await JsonSerializer.DeserializeAsync<List<VeterinaryDiagnosticInvestigationMatrixReportModel>>(
                        contentStream,
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

        public async Task<List<InvestigationTypeViewModel>> GetInvestigationTypeMatrixListAsync(long idfsBaseReference,
            int? intHACode, string strLanguageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetInvestigationTypeMatrixListAsyncPath,
                    _eidssApiOptions.BaseUrl, idfsBaseReference, intHACode, strLanguageId);
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

        public async Task<APIPostResponseModel> DeleteVeterinaryDiagnosticInvestigationMatrixRecord(
            MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteVeterinaryDiagnosticInvestigationMatrixRecordPath,
                    _eidssApiOptions.BaseUrl);
                var stringContent =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
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

        public async Task<APIPostResponseModel> SaveVeterinaryDiagnosticInvestigationMatrix(MatrixViewModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveVeterinaryDiagnosticInvestigationMatrixPath,
                    _eidssApiOptions.BaseUrl);
                var stringContent =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
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
