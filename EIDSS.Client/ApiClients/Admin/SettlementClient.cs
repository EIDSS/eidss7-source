using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{

    public partial interface ISettlementClient
    {
        Task<List<SettlementTypeModel>> GetSettlementTypeList(string languageId);
        Task<SettlementTypeSaveRequestResponseModel> SaveSettlementType(SettlementTypeSaveRequestModel saveRequestModel);        

    }

    public partial class SettlementClient : BaseApiClient, ISettlementClient
    {
        public SettlementClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SettlementClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }
        public async Task<List<SettlementTypeModel>> GetSettlementTypeList(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetSettlementTypeListPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<SettlementTypeModel>>(contentStream,
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

        public async Task<SettlementTypeSaveRequestResponseModel> SaveSettlementType(SettlementTypeSaveRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveSettlementTypePath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<SettlementTypeSaveRequestResponseModel>(contentStream,
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
