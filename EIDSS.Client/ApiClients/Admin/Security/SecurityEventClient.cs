using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EIDSS.ClientLibrary.ApiClients.Admin.Security
{
    public partial interface ISecurityEventClient
    {
        Task<List<SecurityEventLogGetListViewModel>> GetSecurityEventLogList(SecurityEventLogGetRequestModel request, CancellationToken cancellationToken = default);
        Task<APISaveResponseModel> SaveSecurityEventLog(SecurityEventLogSaveRequestModel request);
    }

    public partial class SecurityEventClient:BaseApiClient, ISecurityEventClient
    {
        protected internal EidssApiConfigurationOptions eidssApiConfigurationOptions;

        public SecurityEventClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SecurityEventClient> logger, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions) :
            base(httpClient, eidssApiOptions, logger)
        {
            this.eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;

        }
        /// <summary>
        /// GetSecurityEventLogList
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        public async Task<List<SecurityEventLogGetListViewModel>> GetSecurityEventLogList(SecurityEventLogGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetSecurityEventLogPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SecurityEventLogGetListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);
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

        public async Task<APISaveResponseModel> SaveSecurityEventLog(SecurityEventLogSaveRequestModel request)
        {

            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSecurityEventPath, _eidssApiOptions.BaseUrl);

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
    }
}
