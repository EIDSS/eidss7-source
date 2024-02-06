using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Menu
{

    public partial interface IMenuClient
    {
        Task<List<MenuViewModel>> GetMenuListAsync(long userID, string languageID, bool isConnectToArchive);
        Task<List<MenuByUserViewModel>> GetMenuByUserListAsync(long userID, string languageID, bool isConnectToArchive);
    }


    public partial class MenuClient : BaseApiClient, IMenuClient
    {

        private readonly IApplicationContext _applicationContext;
        public MenuClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<MenuClient> logger, IUserConfigurationService configurationService, IApplicationContext applicationContext) : 
            base(httpClient, eidssApiOptions, logger, configurationService)
        {
            _applicationContext = applicationContext;
        }

        public async Task<List<MenuViewModel>> GetMenuListAsync(long userID, string languageID,bool isConnectToArchive)
        {

            try
            {
                var url = string.Format(_eidssApiOptions.GetMenuListPath, _baseurl, userID, languageID, isConnectToArchive);

                var requestUri = new Uri(url);
                var httpResponse = await _httpClient.GetAsync(requestUri);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<MenuViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] {userID,languageID});
                throw;
            }
            finally
            {
            }
        }

        private string GetToken()
        {
            var sessionId = _applicationContext.SessionId;
            var userName = _applicationContext.GetSession("UserName");

            if (string.IsNullOrEmpty(sessionId))
                return null;

            if (string.IsNullOrEmpty(userName))
                return null;

            var authenticatedUser = _userConfigurationService.GetUserToken(sessionId, userName);

            return authenticatedUser?.AccessToken;

        }

        public async Task<List<MenuByUserViewModel>> GetMenuByUserListAsync(long userID, string languageID, bool isConnectToArchive)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetMenuByUserListPath, _baseurl, userID, languageID, isConnectToArchive);

                var requestUri = new Uri(url);
                var httpResponse = await _httpClient.GetAsync(requestUri);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<MenuByUserViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { userID, languageID });
                throw;
            }
            finally
            {
            }
        }
    }
}