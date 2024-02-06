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
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Admin.Security
{

    public partial interface ISecurityPolicyClient
    {
        public Task<SecurityConfigurationViewModel> GetSecurityPolicy();
        public Task<APISaveResponseModel> SaveSecurityPolicy(SecurityPolicySaveRequestModel request);

    }
    public partial class SecurityPolicyClient : BaseApiClient, ISecurityPolicyClient
    {

        public SecurityPolicyClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SecurityPolicyClient> logger)
          : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<SecurityConfigurationViewModel> GetSecurityPolicy()
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetSecurityPolicyPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<SecurityConfigurationViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
                return response;

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<APISaveResponseModel> SaveSecurityPolicy(SecurityPolicySaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSecurityPolicyPath, _eidssApiOptions.BaseUrl);

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
