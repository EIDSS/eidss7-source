using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
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
    public partial interface IUniqueNumberingSchemaClient
    {
        Task<List<UniqueNumberingSchemaListViewModel>> GetUniqueNumberingSchemaListAsync(UniqueNumberingSchemaGetRequestModel request);
        Task<UniqueNumberingSchemaSaveResquestResponseModel> SaveUniqueNumberingSchemaAsync(UniqueNumberingSchemaSaveRequestModel saveRequestModel);
    }

    public partial class UniqueNumberingSchemaClient : BaseApiClient, IUniqueNumberingSchemaClient
    {
        public UniqueNumberingSchemaClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<UniqueNumberingSchemaClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<UniqueNumberingSchemaListViewModel>> GetUniqueNumberingSchemaListAsync(UniqueNumberingSchemaGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetUniqueNumberingSchemaListAsyncPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<List<UniqueNumberingSchemaListViewModel>>(contentStream,
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

        public async Task<UniqueNumberingSchemaSaveResquestResponseModel> SaveUniqueNumberingSchemaAsync(UniqueNumberingSchemaSaveRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveUniqueNumberingSchemaAsyncPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<UniqueNumberingSchemaSaveResquestResponseModel>(contentStream,
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
