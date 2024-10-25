#region Usings

using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

#endregion

namespace EIDSS.ClientLibrary.ApiClients.Administration.Security
{
    public partial interface ISiteClient
    {
        Task<SiteGetDetailViewModel> GetSiteDetails(string languageId, long siteId, long userId);
        Task<List<SiteGetListViewModel>> GetSiteList(SiteGetRequestModel request);
        Task<List<SiteActorGetListViewModel>> GetSiteActorList(SiteActorGetRequestModel request);
        Task<APISaveResponseModel> SaveSite(SiteSaveRequestModel request);
        Task<APIPostResponseModel> DeleteSite(long siteId, string auditUserName);
    }

    public partial class SiteClient : BaseApiClient, ISiteClient
    {
        #region Constructors

        public SiteClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SiteClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="siteId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public async Task<SiteGetDetailViewModel> GetSiteDetails(string languageId, long siteId, long userId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetSiteDetailsPath, _eidssApiOptions.BaseUrl, languageId, siteId, userId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<SiteGetDetailViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, siteId);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<SiteGetListViewModel>> GetSiteList(SiteGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSiteListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<SiteGetListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<SiteActorGetListViewModel>> GetSiteActorList(SiteActorGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");

                string url = string.Format(_eidssApiOptions.GetSiteActorListPath, _eidssApiOptions.BaseUrl);
                using HttpResponseMessage httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<SiteActorGetListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APISaveResponseModel> SaveSite(SiteSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSitePath, _eidssApiOptions.BaseUrl);

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
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="siteId"></param>
        /// <param name="auditUserName"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteSite(long siteId, string auditUserName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteSitePath, _eidssApiOptions.BaseUrl, siteId, auditUserName);
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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, siteId);
                throw;
            }
        }
    }
}