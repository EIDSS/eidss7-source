using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public partial interface IWHOExportClient
    {
        Task<List<WHOExportGetListViewModel>> GetWHOExportList(WHOExportRequestModel request);
    }

    public partial class WHOExportClient : BaseApiClient, IWHOExportClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public WHOExportClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<WHOExportClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<WHOExportGetListViewModel>> GetWHOExportList(WHOExportRequestModel request)
        {
            try
            {
                var requestContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetWHOExportListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<WHOExportGetListViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {

                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }
    }
}
