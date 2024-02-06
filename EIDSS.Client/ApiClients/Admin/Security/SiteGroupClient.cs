#region Using Statements

using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
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
    public partial interface ISiteGroupClient
    {
        Task<SiteGroupGetDetailViewModel> GetSiteGroupDetails(string languageID, long siteGroupID);
        Task<List<SiteGroupGetListViewModel>> GetSiteGroupList(SiteGroupGetRequestModel request);
        Task<APISaveResponseModel> SaveSiteGroup(SiteGroupSaveRequestModel request);
        Task<APIPostResponseModel> DeleteSiteGroup(long siteGroupID, bool? deleteAnyway);
    }

    public partial class SiteGroupClient : BaseApiClient, ISiteGroupClient
    {
        #region Constructors

        public SiteGroupClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SiteGroupClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageID"></param>
        /// <param name="siteGroupID"></param>
        /// <returns></returns>
        public async Task<SiteGroupGetDetailViewModel> GetSiteGroupDetails(string languageID, long siteGroupID)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetSiteGroupDetailsPath, _eidssApiOptions.BaseUrl, languageID, siteGroupID);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<SiteGroupGetDetailViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { siteGroupID });
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<SiteGroupGetListViewModel>> GetSiteGroupList(SiteGroupGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetSiteGroupListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<SiteGroupGetListViewModel>>(contentStream,
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APISaveResponseModel> SaveSiteGroup(SiteGroupSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSiteGroupPath, _eidssApiOptions.BaseUrl);

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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="siteGroupID"></param>
        /// <param name="deleteAnyway"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteSiteGroup(long siteGroupID, bool? deleteAnyway)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteSiteGroupPath, _eidssApiOptions.BaseUrl, siteGroupID, deleteAnyway);
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
                _logger.LogError(ex.Message, new object[] { siteGroupID });
                throw;
            }
        }
    }
}