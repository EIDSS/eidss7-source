using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.Handlers
{
    public class AuthenticationDelegatingHandler : DelegatingHandler
    {
        protected internal EidssApiOptions EidssApiOptions;
        protected internal ILogger Logger;
        protected internal IUserConfigurationService UserConfigurationService;
        protected internal IApplicationContext ApplicationContext;

        public AuthenticationDelegatingHandler(IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<AuthenticationDelegatingHandler> logger,
            IUserConfigurationService configurationService, IApplicationContext applicationContext)
        {
            EidssApiOptions = eidssApiOptions.Value;
            Logger = logger;
            UserConfigurationService = configurationService;
            ApplicationContext = applicationContext;
        }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            HttpResponseMessage response;
            try
            {
                string token = null;

                var sessionId = ApplicationContext.SessionId;
                var loggedUserName = ApplicationContext.GetSession("UserName");
                var userToken = UserConfigurationService.GetUserToken(sessionId, loggedUserName);

                if (userToken != null)
                {
                    token = userToken.AccessToken;
                }
                if (!string.IsNullOrEmpty(token))
                {
                    request.Headers.Authorization = new AuthenticationHeaderValue("bearer", token);
                }

                response = await base.SendAsync(request, cancellationToken);
                Logger.LogInformation("after the request AuthenticationDelegatingHandler");
                if (!response.IsSuccessStatusCode)
                {
                    if (response.StatusCode == (HttpStatusCode)StatusCodes.Status401Unauthorized)
                    {
                        try
                        {
                            if (userToken != null)
                            {
                                var userTokenName = userToken.UserName;
                                var refreshToken = userToken.RefreshToken;
                                var refreshTokenModel = new RefreshTokenViewModel()
                                {
                                    Token = token,
                                    RefreshToken = refreshToken,
                                    UserName = userTokenName
                                };

                                var refreshTokenViewModelJson = new StringContent(
                                    JsonSerializer.Serialize(refreshTokenModel),
                                    Encoding.UTF8, "application/json");
                                var requestMessage = new HttpRequestMessage
                                {
                                    Method = HttpMethod.Post,
                                    RequestUri = new Uri($"{EidssApiOptions.BaseUrl}Admin/RefreshToken"),
                                    Content = refreshTokenViewModelJson
                                };
                                var responseMessage = await base.SendAsync(requestMessage, cancellationToken);

                                responseMessage.EnsureSuccessStatusCode();
                                var contentStream = await responseMessage.Content.ReadAsStreamAsync(cancellationToken);

                                var responseMessageViewModel =
                                    await JsonSerializer.DeserializeAsync<LoginResponseViewModel>(
                                        contentStream,
                                        new JsonSerializerOptions
                                        {
                                            IgnoreNullValues = true,
                                            PropertyNameCaseInsensitive = true
                                        }, cancellationToken);

                                var authenticatedUser = UserConfigurationService.GetUserToken(sessionId, userTokenName);
                                authenticatedUser.RefreshToken = responseMessageViewModel.RefreshToken;
                                authenticatedUser.AccessToken = responseMessageViewModel.Token;

                                var newAccessToken = GetToken();
                                request.Headers.Authorization = new AuthenticationHeaderValue("bearer", newAccessToken);
                                response = await base.SendAsync(request, cancellationToken);

                                if (!response.IsSuccessStatusCode)
                                {
                                    var msg = response.Content.ReadAsStringAsync(cancellationToken).Result;
                                    Logger.LogError(msg);
                                    throw new Exception(msg);
                                }
                            }
                        }
                        catch (Exception e)
                        {
                            if (e.StackTrace != null) Logger.LogError(e.StackTrace.ToString());
                            throw;
                        }
                    }
                    else
                    {
                        string msg = response.Content.ReadAsStringAsync(cancellationToken).Result;
                        Logger.LogError(msg);
                        throw new Exception(msg);
                    }
                }

            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "Exception calling api client. " + ex.StackTrace, request);
                throw;
            }

            return response;
        }

        private string GetToken()
        {
            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            var authenticatedUser = UserConfigurationService.GetUserToken(sessionId, loggedUserName);

            return authenticatedUser?.AccessToken;
        }

        private string GetRefreshToken()
        {
            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            var authenticatedUser = UserConfigurationService.GetUserToken(sessionId, loggedUserName);

            return authenticatedUser?.RefreshToken;

        }
    }
}
