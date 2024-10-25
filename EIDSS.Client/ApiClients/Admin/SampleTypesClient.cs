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

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface ISampleTypesClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetSampleTypesReferenceList(SampleTypesEditorGetRequestModel request);
        Task<APISaveResponseModel> SaveSampleType(SampleTypeSaveRequestModel request);
        Task<APIPostResponseModel> DeleteSampleType(SampleTypeSaveRequestModel request, CancellationToken cancellationToken = default);
    }
    
    public partial class SampleTypesClient : BaseApiClient, ISampleTypesClient
    {
        public SampleTypesClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SampleTypesClient> logger)
            : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetSampleTypesReferenceList(SampleTypesEditorGetRequestModel request)
        {
            try
            {
                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSampleTypesReferenceListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, sampleTypesViewModelJson);

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

        public async Task<APISaveResponseModel> SaveSampleType(SampleTypeSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveSampleTypeUrl = string.Format(_eidssApiOptions.SaveSampleTypePath, _eidssApiOptions.BaseUrl);
                
                var httpResponse = await _httpClient.PostAsync(saveSampleTypeUrl, requestModelJson);

                // Throws an exception if the call to the service failed...
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

        public async Task<APIPostResponseModel> DeleteSampleType(SampleTypeSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveBaseReferenceUrl = string.Format(_eidssApiOptions.DeleteSampleTypePath, _eidssApiOptions.BaseUrl);
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
