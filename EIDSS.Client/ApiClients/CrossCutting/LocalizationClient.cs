using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.CrossCutting
{
    public partial interface ILocalizationClient
    {
        Task<List<LanguageModel>> GetLanguageList(string languageID);
        Task<List<ResourceModel>> GetResourceList(string cultureName);
    }

    public partial class LocalizationClient : BaseApiClient, ILocalizationClient
    {
        public LocalizationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<LocalizationClient> logger)
            :
            base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<LanguageModel>> GetLanguageList(string languageID)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetLanguageListPath, _eidssApiOptions.BaseUrl, languageID);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<LanguageModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<ResourceModel>> GetResourceList(string cultureName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetResourceListPath, _eidssApiOptions.BaseUrl, cultureName);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ResourceModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { cultureName });
                throw;
            }
            finally
            {
            }
        }
    }
}