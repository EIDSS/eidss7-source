using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Administration.Security
{
    public partial interface IConfigurableFiltrationClient
    {
        Task<List<AccessRuleGetListViewModel>> GetAccessRuleList(AccessRuleGetRequestModel request);
        Task<AccessRuleGetDetailViewModel> GetAccessRuleDetail(string languageID, long accessRuleID);
        Task<List<AccessRuleActorGetListViewModel>> GetAccessRuleActorList(AccessRuleActorGetRequestModel request);
        Task<APISaveResponseModel> SaveAccessRule(AccessRuleSaveRequestModel request);
        Task<APIPostResponseModel> DeleteAccessRule(long accessRuleID);
    }

    /// <summary>
    /// 
    /// </summary>
    public partial class ConfigurableFiltrationClient : BaseApiClient, IConfigurableFiltrationClient
    {
        public ConfigurableFiltrationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<ConfigurableFiltrationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<AccessRuleGetListViewModel>> GetAccessRuleList(AccessRuleGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetAccessRuleListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<AccessRuleGetListViewModel>>(contentStream,
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
            finally
            {
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageID"></param>
        /// <param name="accessRuleID"></param>
        /// <returns></returns>
        public async Task<AccessRuleGetDetailViewModel> GetAccessRuleDetail(string languageID, long accessRuleID)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetAccessRuleDetailPath, _eidssApiOptions.BaseUrl, languageID, accessRuleID);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<AccessRuleGetDetailViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { accessRuleID });
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<AccessRuleActorGetListViewModel>> GetAccessRuleActorList(AccessRuleActorGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");

                string url = string.Format(_eidssApiOptions.GetAccessRuleActorListPath, _eidssApiOptions.BaseUrl);
                using HttpResponseMessage httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<AccessRuleActorGetListViewModel>>(contentStream,
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APISaveResponseModel> SaveAccessRule(AccessRuleSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveAccessRulePath, _eidssApiOptions.BaseUrl);

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
            finally
            {
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="accessRuleID"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteAccessRule(long accessRuleID)
        {
            var url = string.Format(_eidssApiOptions.DeleteAccessRulePath, _eidssApiOptions.BaseUrl, accessRuleID);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }
    }
}