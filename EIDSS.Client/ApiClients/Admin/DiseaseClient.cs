using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
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
    public partial interface IDiseaseClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetDiseasesList(DiseasesGetRequestModel request);
        Task<List<DiseaseReferenceGetDetailViewModel>> GetDiseasesDetail(string languageId, long diseaseId, CancellationToken cancellationToken = default);
        Task<APIPostResponseModel> SaveDisease(DiseaseSaveRequestModel diseaseModel);
        Task<APIPostResponseModel> DeleteDisease(DiseaseSaveRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class DiseaseClient : BaseApiClient, IDiseaseClient
    {
        public DiseaseClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<DiseaseClient> logger): base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteDisease(DiseaseSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveBaseReferenceUrl = string.Format(_eidssApiOptions.DeleteDiseasePath, _eidssApiOptions.BaseUrl);
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

        public async Task<List<BaseReferenceEditorsViewModel>> GetDiseasesList(DiseasesGetRequestModel request)
        {
            try
            {
                var diseaseViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDiseasesListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, diseaseViewModelJson);

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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="diseaseId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<DiseaseReferenceGetDetailViewModel>> GetDiseasesDetail(string languageId, long diseaseId, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetDiseasesDetailPath, _eidssApiOptions.BaseUrl, languageId, diseaseId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url), cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<DiseaseReferenceGetDetailViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { diseaseId });
                throw;
            }
        }

        public async Task<APIPostResponseModel> SaveDisease(DiseaseSaveRequestModel diseaseModel)
        {
            try
            {
                var diseaseViewModelJson = new StringContent(JsonSerializer.Serialize(diseaseModel), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveDiseasePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, diseaseViewModelJson);

                if (!httpResponse.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorStream = await httpResponse.Content.ReadAsStreamAsync();
                        await JsonSerializer.DeserializeAsync<DiseaseSaveRequestReponseModel>(errorStream);
                    }
                    catch
                    {
                    }
                }

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
                _logger.LogError(ex.Message, diseaseModel); 
                throw;
            }
        }
    }
}
