using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using static System.String;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface ICaseClassificationClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetCaseClassificationList(CaseClassificationGetRequestModel request);
        Task<APISaveResponseModel> SaveCaseClassification(CaseClassificationSaveRequestModel request);
        Task<APIPostResponseModel> DeleteCaseClassification(CaseClassificationSaveRequestModel request, CancellationToken cancellationToken = default);
    }
    public partial class CaseClassificationClient : BaseApiClient, ICaseClassificationClient
    {
        public CaseClassificationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<CaseClassificationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetCaseClassificationList(CaseClassificationGetRequestModel request)
        {
            try
            {
                var url = Format(_eidssApiOptions.GetCaseClassificationListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<BaseReferenceEditorsViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SaveCaseClassification(CaseClassificationSaveRequestModel request)
        {
            try
            {
                var url = Format(_eidssApiOptions.SaveCaseClassificationPath, _eidssApiOptions.BaseUrl);
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
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteCaseClassification(CaseClassificationSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveBaseReferenceUrl = Format(_eidssApiOptions.DeleteCaseClassificationPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(saveBaseReferenceUrl, requestModelJson, cancellationToken);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }
    }
}
