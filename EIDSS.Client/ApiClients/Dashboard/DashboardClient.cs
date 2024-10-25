using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Dashboard;
using EIDSS.Domain.ViewModels.Dashboard;
using EIDSS.Domain.ViewModels.Laboratory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Dashboard
{
    public partial interface IDashboardClient
    {
        Task<List<DashboardLinksListViewModel>> GetDashboardLinks(DashboardLinksGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<ApprovalsGetListViewModel>> GetDashboardApprovals(string LanguageID, string SiteList, CancellationToken cancellationToken = default);
        Task<List<DashboardInvestigationsListViewModel>> GetDashboardInvestigations(DashboardInvestigationsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DashboardInvestigationsListViewModel>> GetDashboardMyInvestigations(DashboardInvestigationsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DashboardNotificationsListViewModel>> GetDashboardNotifications(DashboardNotificationsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DashboardNotificationsListViewModel>> GetDashboardMyNotifications(DashboardNotificationsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DashboardCollectionsListViewModel>> GetDashboardMyCollections(DashboardCollectionsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DashboardUsersListViewModel>> GetDashboardUsers(DashboardUsersGetRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class DashboardClient : BaseApiClient, IDashboardClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public DashboardClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<DashboardClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<ApprovalsGetListViewModel>> GetDashboardApprovals(string LanguageID, string SiteList, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetDashboardApprovalsPath, _eidssApiOptions.BaseUrl, LanguageID, SiteList);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<List<ApprovalsGetListViewModel>>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<DashboardInvestigationsListViewModel>> GetDashboardInvestigations(DashboardInvestigationsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardInvestigationsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardInvestigationsListViewModel>>(contentStream,
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

        public async Task<List<DashboardInvestigationsListViewModel>> GetDashboardMyInvestigations(DashboardInvestigationsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardMyInvestigationsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardInvestigationsListViewModel>>(contentStream,
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

        public async Task<List<DashboardNotificationsListViewModel>> GetDashboardNotifications(DashboardNotificationsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardNotificationsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardNotificationsListViewModel>>(contentStream,
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

        public async Task<List<DashboardNotificationsListViewModel>> GetDashboardMyNotifications(DashboardNotificationsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardMyNotificationsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardNotificationsListViewModel>>(contentStream,
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

        public async Task<List<DashboardCollectionsListViewModel>> GetDashboardMyCollections(DashboardCollectionsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardMyCollectionsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardCollectionsListViewModel>>(contentStream,
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

        public async Task<List<DashboardLinksListViewModel>> GetDashboardLinks(DashboardLinksGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardLinksPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardLinksListViewModel>>(contentStream,
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



            //throw new NotImplementedException();
        }

        public async Task<List<DashboardUsersListViewModel>> GetDashboardUsers(DashboardUsersGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDashboardUsersPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DashboardUsersListViewModel>>(contentStream,
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

            //throw new NotImplementedException();
        }
    }
}
