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
                // MJK -    commented out the serviceProvider and call to tokenService because they were not actually used and
                //              httpcontext will be null if the signal r hub disconnects, causing a null reference exception that gets thrown up the stack
                //TODO -  we should not use httpcontextaccessor from the blazor side of the app but instead should probably pass
                //              the authorization headers right in the HttpRequestMessage because we are not guaranteed to have httpcontext in blazor
                //              Refer to this article: https://docs.microsoft.com/en-us/aspnet/core/fundamentals/http-context?view=aspnetcore-6.0#use-httpcontext-from-middleware
                //var serviceProvider = _httpContextAccessor.HttpContext.RequestServices;
                //var tokenService = (ITokenService)serviceProvider.GetService(typeof(ITokenService));

                string token = null;

                //TODO: remove commented if session-User approach works//var userToken = UserConfigurationService.GetUserToken();
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
                Logger.LogDebug("after the request AuthenticationDelegatingHandler");
                if (!response.IsSuccessStatusCode)
                {
                    if (response.StatusCode == (HttpStatusCode)StatusCodes.Status401Unauthorized
                        /*&& response.Headers.Contains("Token-Expired")*/)
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

                                //TODO: remove commented if session-User approach works//var authenticatedUser = UserConfigurationService.GetUserToken();
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
            //TODO: remove commented if session-User approach works//var userToken = UserConfigurationService.GetUserToken();
            ////string tokenStr = null;
            //////if (ApplicationContext.GetSession("UserName") == null) return null;
            ////// var userName =  ApplicationContext.GetSession("UserName");
            ////var authenticatedUser = UserConfigurationService.GetUserToken();
            ////if (authenticatedUser?.AccessToken != null)
            ////{
            ////    tokenStr = authenticatedUser.AccessToken;
            ////}

            ////return tokenStr;

            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            var authenticatedUser = UserConfigurationService.GetUserToken(sessionId, loggedUserName);

            return authenticatedUser?.AccessToken;
        }

        private string GetRefreshToken()
        {
            //TODO: remove commented if session-User approach works//var userToken = UserConfigurationService.GetUserToken();
            ////string refreshTokenStr = null;
            ////// if (ApplicationContext.GetSession("UserName") == null) return null;
            ////// var userName = ApplicationContext.GetSession("UserName");
            ////var authenticatedUser = UserConfigurationService.GetUserToken();
            ////if (authenticatedUser?.RefreshToken != null)
            ////{
            ////    refreshTokenStr = authenticatedUser.RefreshToken;
            ////}

            ////return refreshTokenStr;

            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            var authenticatedUser = UserConfigurationService.GetUserToken(sessionId, loggedUserName);

            return authenticatedUser?.RefreshToken;

        }
    }
}
