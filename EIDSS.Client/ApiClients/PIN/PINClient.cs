using System;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.PIN;
using EIDSS.Domain.ViewModels;
using EIDSS.Security.Encryption;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EIDSS.ClientLibrary.ApiClients.PIN
{
    public class PINClient : BaseApiClient, IPINClient
    {
        private readonly IConfiguration _configuration;
        private readonly ITokenService _tokenService;

        public PINClient(
            HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<PINClient> logger,
            IConfiguration configuration,
            ITokenService tokenservice)
            : base(httpClient, eidssApiOptions, logger)
        {
            _configuration = configuration;
            _tokenService = tokenservice;
        }

        /// <summary>
        /// Get PIN Person data...
        /// </summary>
        /// <param name="personalID"></param>
        /// <param name="birthYear"></param>
        /// <returns></returns>
        public async Task<PersonalDataModel> GetPersonData(string personalID, string birthYear)
        {
            var accesstime = DateTime.Now;

            try
            {
                // If we're calling the real PIN service, then we must use a different http client...
                var _cli = _eidssApiOptions.MockPINService == true ? _httpClient : new HttpClient();

                // Get the protected configuration from esettings...
                var protectedConfigSection = _configuration.GetSection("ProtectedConfiguration");
                var protectedConfig = protectedConfigSection.Get<ProtectedConfigurationSettings>();

                // Log into the PIN System...  This gives us our token...
                var token = await PINSysLogin(
                    protectedConfig.PIN_UserName.Decrypt(),
                    protectedConfig.PIN_Password.Decrypt());

                // Formulate the url...
                var url = string.Format(_eidssApiOptions.GetPersonData, _eidssApiOptions.PINUrl, personalID, birthYear);

                // Add the login token to the header...
                _cli.DefaultRequestHeaders.Add("LoginToken", token);

                // Cal the service...
                var httpResponse = await _cli.GetAsync(new Uri(url));

                // Ensure success...
                httpResponse.EnsureSuccessStatusCode();

                // Read the content as a stream...
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                PersonalDataModel response = new();

                if (contentStream.Length != 0)
                    response =
                    await JsonSerializer.DeserializeAsync<PersonalDataModel>(contentStream, SerializationOptions);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
                // Log the request...
                await LogPINSystemAccess(personalID, accesstime);
            }
        }

        /// <summary>
        /// Audit each request made to the PIN System.
        /// </summary>
        /// <param name="personalID">A valid PIN System record identifier.</param>
        /// <param name="datEIDSSAccess">A datetime value representing when the EIDSS system was accessed for this request.</param>
        /// <returns></returns>
        private async Task<APISaveResponseModel> LogPINSystemAccess(string personalID, DateTime datEIDSSAccess)
        {
            using var ms = new MemoryStream();
            var user = _tokenService.GetAuthenticatedUser();
            var request = new PINAuditRequestModel
            {
                strPIN = personalID,
                datEIDSSAccessAttempt = datEIDSSAccess,
                idfUser = Convert.ToInt64(user.EIDSSUserId),
                idfsSite = Convert.ToInt64(user.SiteId),
                datPINAccessAttempt = DateTime.Now
            };

            var url = string.Format(_eidssApiOptions.AuditPINSystemAccess, _eidssApiOptions.BaseUrl);
            var aj = new MediaTypeWithQualityHeaderValue("application/json");

            await JsonSerializer.SerializeAsync(ms, request);
            ms.Seek(0, SeekOrigin.Begin);

            var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            requestmessage.Headers.Accept.Add(aj);

            using var requestContent = new StreamContent(ms);
            requestmessage.Content = requestContent;
            requestContent.Headers.ContentType = aj;
            using var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead);
            response.EnsureSuccessStatusCode();
            var content = await response.Content.ReadAsStreamAsync();
            return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(content, SerializationOptions);
        }

        /// <summary>
        /// Log into the PIN system.  The returned token is cached infinitely for subsequent calls to the service.
        /// </summary>
        /// <param name="request">An instance of <see cref="LoginViewModel"/></param> that specifies the username and password of the user logging in.
        /// <returns>A character based token.</returns>
        [ResponseCache(CacheProfileName = "CacheInfini")]
        private async Task<string> PINSysLogin(string loginName, string password)
        {
            try
            {
                // If we're calling the real PIN service, then we must use a different http client...
                var _cli = _eidssApiOptions.MockPINService == true ? _httpClient : new HttpClient();

                // formulate the url...
                var url = string.Format(_eidssApiOptions.LoginUrl, _eidssApiOptions.PINUrl, loginName, password);

                // make the call...
                var httpResponse = await _cli.GetAsync(new Uri(url));

                // ensure success...
                httpResponse.EnsureSuccessStatusCode();

                // read the response into a stream...
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                // Get the response from the stream...
                var response = await JsonSerializer.DeserializeAsync<string>(contentStream, SerializationOptions);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
