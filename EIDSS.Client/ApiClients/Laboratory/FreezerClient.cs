using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Laboratory.Freezer;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Laboratory
{
    public partial interface IFreezerClient
    {
        Task<List<FreezerViewModel>> GetFreezerList(FreezerRequestModel request);
        Task<List<FreezerSubdivisionViewModel>> GetFreezerSubdivisionList(FreezerSubdivisionRequestModel request);
        Task<FreezerSaveRequestResponseModel> SaveFreezer(FreezerSaveRequestModel request);        
    }

    public partial class FreezerClient : BaseApiClient, IFreezerClient
    {
        public FreezerClient(HttpClient httpClient, 
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions, 
            ILogger<FreezerClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<FreezerViewModel>> GetFreezerList(FreezerRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFreezerListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<List<FreezerViewModel>>(contentStream,
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

        public async Task<List<FreezerSubdivisionViewModel>> GetFreezerSubdivisionList(FreezerSubdivisionRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFreezerSubdivisionListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<List<FreezerSubdivisionViewModel>>(contentStream,
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

        public async Task<FreezerSaveRequestResponseModel> SaveFreezer(FreezerSaveRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveFreezerPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<FreezerSaveRequestResponseModel>(contentStream,
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
    }
}
