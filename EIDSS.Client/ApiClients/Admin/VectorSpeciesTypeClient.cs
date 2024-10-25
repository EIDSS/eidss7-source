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
    public partial interface IVectorSpeciesTypeClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetVectorSpeciesTypeList(VectorSpeciesTypesGetRequestModel VectorSpeciesTypesGetRequestModel);
        Task<APISaveResponseModel> SaveVectorSpeciesType(VectorSpeciesTypesSaveRequestModel saveRequestModel);
        Task<APIPostResponseModel> DeleteVectorSpeciesType(VectorSpeciesTypesSaveRequestModel request, CancellationToken cancellationToken = default);
    }
    public partial class VectorSpeciesTypeClient : BaseApiClient, IVectorSpeciesTypeClient
    {
        public VectorSpeciesTypeClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<VectorSpeciesTypeClient> logger ) : 
            base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetVectorSpeciesTypeList(VectorSpeciesTypesGetRequestModel VectorSpeciesTypesGetRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVectorSpeciesTypeListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(VectorSpeciesTypesGetRequestModel), Encoding.UTF8, "application/json");
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
                _logger.LogError(ex.Message, VectorSpeciesTypesGetRequestModel);
                throw;
            }
        }

        public async Task<APISaveResponseModel> SaveVectorSpeciesType(VectorSpeciesTypesSaveRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveVectorSpeciesTypePath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
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
                _logger.LogError(ex.Message, saveRequestModel);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteVectorSpeciesType(VectorSpeciesTypesSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteVectorSpeciesTypePath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestModelJson, cancellationToken);

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
