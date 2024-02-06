using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
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

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IOrganizationClient
    {
        Task<List<OrganizationGetListViewModel>> GetOrganizationList(OrganizationGetRequestModel request);

        Task<List<OrganizationAdvancedGetListViewModel>> GetOrganizationAdvancedList(OrganizationAdvancedGetRequestModel request);

        Task<OrganizationGetDetailViewModel> GetOrganizationDetail(string languageID, long organizationID);
        Task<APISaveResponseModel> SaveOrganization(OrganizationSaveRequestModel request);
        Task<APIPostResponseModel> DeleteOrganization(long organizationID, string auditUserName, bool? deleteAnyway);
    }

    public partial class OrganizationClient : BaseApiClient, IOrganizationClient
    {
        public OrganizationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<OrganizationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<OrganizationGetListViewModel>> GetOrganizationList(OrganizationGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOrganizationListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<OrganizationGetListViewModel>>(contentStream,
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


        public async Task<List<OrganizationAdvancedGetListViewModel>> GetOrganizationAdvancedList(OrganizationAdvancedGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetAdvancedOrganizationListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<OrganizationAdvancedGetListViewModel>>(contentStream,
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
        /// <param name="organizationID"></param>
        /// <returns></returns>
        public async Task<OrganizationGetDetailViewModel> GetOrganizationDetail(string languageID, long organizationID)
        {
            var url = string.Format(_eidssApiOptions.GetOrganizationDetailPath, _eidssApiOptions.BaseUrl, languageID, organizationID);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<OrganizationGetDetailViewModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APISaveResponseModel> SaveOrganization(OrganizationSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveOrganizationPath, _eidssApiOptions.BaseUrl);

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
        /// <param name="organizationID"></param>
        /// <param name="auditUserName"></param>
        /// <param name="deleteAnyway"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteOrganization(long organizationID, string auditUserName, bool? deleteAnyway)
        {
            var url = string.Format(_eidssApiOptions.DeleteOrganizationPath, _eidssApiOptions.BaseUrl, organizationID, auditUserName, deleteAnyway);
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
