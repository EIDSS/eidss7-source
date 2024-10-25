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
    public partial interface IVectorTypeClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetVectorTypeList(VectorTypesGetRequestModel vectorTypesGetRequestModel);
        Task<VectorTypeSaveRequestResponseModel> SaveVectorType(VectorTypeSaveRequestModel saveRequestModel);
        Task<APIPostResponseModel> DeleteVectorType(VectorTypeSaveRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class VectorTypeClient : BaseApiClient, IVectorTypeClient
    {
        public VectorTypeClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<VectorTypeClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetVectorTypeList(VectorTypesGetRequestModel vectorTypesGetRequestModel)
        {      
            var url = string.Format(_eidssApiOptions.GetVectorTypeListPath, _eidssApiOptions.BaseUrl);
            var stringContent = new StringContent(JsonSerializer.Serialize(vectorTypesGetRequestModel), Encoding.UTF8, "application/json");
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

        public async Task<VectorTypeSaveRequestResponseModel> SaveVectorType(VectorTypeSaveRequestModel saveRequestModel)
        {
            var url = string.Format(_eidssApiOptions.SaveVectorTypePath, _eidssApiOptions.BaseUrl);            
            var stringContent = new StringContent(JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
            var httpResponse = await _httpClient.PostAsync(url, stringContent);            

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                        
            return await JsonSerializer.DeserializeAsync<VectorTypeSaveRequestResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            //return returnResult;            
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteVectorType(VectorTypeSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteVectorTypePath, _eidssApiOptions.BaseUrl);
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
