using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IAdministrativeUnitsClient
    {
        Task<List<AdministrativeUnitsGetListViewModel>> GetAdministrativeUnitsList(AdministrativeUnitsSearchRequestModel request);
        Task<APISaveResponseModel> SaveAdministrativeUnit(AdministrativeUnitSaveRequestModel request);
        Task<ApiPostGisDataResponseModel> DeleteAdministrativeUnit(long IdfsLocationId, string UserName);
    }
    public partial class AdministrativeUnitsClient :  BaseApiClient, IAdministrativeUnitsClient
    {
        public AdministrativeUnitsClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<AdministrativeUnitsClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<AdministrativeUnitsGetListViewModel>> GetAdministrativeUnitsList(AdministrativeUnitsSearchRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetAdministrativeUnitsListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                
                return await JsonSerializer.DeserializeAsync<List<AdministrativeUnitsGetListViewModel>>(contentStream, SerializationOptions);
                
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APISaveResponseModel> SaveAdministrativeUnit(AdministrativeUnitSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveAdministrativeUnitPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
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
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="IdfsLocationId"></param>
        /// <param name="UserName"></param>
        /// <returns></returns>
        public async Task<ApiPostGisDataResponseModel> DeleteAdministrativeUnit(long IdfsLocationId, string UserName)
        {
            var url = string.Format(_eidssApiOptions.DeleteAdministrativeUnitPath, _eidssApiOptions.BaseUrl, IdfsLocationId, UserName);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<ApiPostGisDataResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }
    }
}
