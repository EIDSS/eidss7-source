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
    public partial interface IAggregateSettingsClient
    {
        public Task<List<AggregateSettingsViewModel>> GetAggregateSettingsList(AggregateSettingsGetRequestModel request);
        public Task<APISaveResponseModel> SaveAggregateSettings(AggregateSettingsSaveRequestModel request);
    }
    public partial class AggregateSettingsClient : BaseApiClient , IAggregateSettingsClient
    {
        ///api/Configuration/VectorTypeFieldTestMatrix/DeleteFieldTestMatrix
        ///#region Vector Type Field Test Matrix
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public AggregateSettingsClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
        ILogger<ConfigurationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }


        public async Task<List<AggregateSettingsViewModel>> GetAggregateSettingsList(AggregateSettingsGetRequestModel request)
        {
            var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.GetAggregateSettingsPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, viewModelJson);


            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<List<AggregateSettingsViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }



        public async Task<APISaveResponseModel> SaveAggregateSettings(AggregateSettingsSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveAggregateSettingsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

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
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }
    }
}
