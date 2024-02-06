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
using EIDSS.Domain.ViewModels.Administration.Security;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;


namespace EIDSS.ClientLibrary.ApiClients.Admin.Security
{
    public partial interface ISystemEventClient
    {
        Task<List<SystemEventLogGetListViewModel>> GetSystemEventLogList(SystemEventLogGetRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class SystemEventClient : BaseApiClient, ISystemEventClient
    {
        

        public SystemEventClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SecurityEventClient> logger, IUserConfigurationService userConfigService = null) : base(httpClient, eidssApiOptions, logger, userConfigService)
        {

        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SystemEventLogGetListViewModel>> GetSystemEventLogList(SystemEventLogGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetSystemEventLogPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SystemEventLogGetListViewModel>>(contentStream,
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
    }
}
