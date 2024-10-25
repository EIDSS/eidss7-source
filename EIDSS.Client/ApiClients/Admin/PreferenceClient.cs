using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IPreferenceClient
    {
        Task<SystemPreferences> InitializeSystemPreferences();
        Task<SystemPreferenceSaveResponseModel> SetSystemPreferences(SystemPreferences sysprefs);
        Task<UserPreferences> InitializeUserPreferences(long userId);
        Task<UserPreferenceSaveResponseModel> SetUserPreferences(UserPreferences userPrefs);
    }

    public partial class PreferenceClient : BaseApiClient, IPreferenceClient
    {
        public PreferenceClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<PreferenceClient> logger, IUserConfigurationService userConfigurationService) : base(httpClient, eidssApiOptions, logger, userConfigurationService)
        {
        }

        public async Task<SystemPreferences> InitializeSystemPreferences()
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetSystemPreferencePath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<SystemPreferenceViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                // property into our preference class...
                var prefs = JsonConvert.DeserializeObject<SystemPreferences>(response.PreferenceDetail);
                prefs.SystemPreferencesId = response.SystemPreferenceID;

                //load into config factory....
                //ConfigFactory.SetSystemPreferences(prefs);
                _userConfigurationService.SystemPreferences = prefs;

                return prefs;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<UserPreferences> InitializeUserPreferences(long userId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetUserPreferencePath, _eidssApiOptions.BaseUrl, userId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                UserPreferences prefs = new UserPreferences( _userConfigurationService);
                var response = new UserPreferenceViewModel();
                if (httpResponse.StatusCode != System.Net.HttpStatusCode.NoContent)
                {
                    response = await System.Text.Json.JsonSerializer.DeserializeAsync<UserPreferenceViewModel>(contentStream,
                        new JsonSerializerOptions
                        {
                            IgnoreNullValues = true,
                            PropertyNameCaseInsensitive = true
                        });

                    // property into our preference class...

                    var settings = new JsonSerializerSettings
                    {
                        PreserveReferencesHandling = PreserveReferencesHandling.Objects
                    }; 
                    
                    prefs = new UserPreferences(_userConfigurationService);
                    JsonConvert.PopulateObject(response.preferenceDetail, prefs, settings);

                    prefs.UserPreferencesId = response.UserPreferenceUID;


                    //prefs = System.Text.Json.JsonSerializer.Deserialize<UserPreferences>(response.preferenceDetail,
                    //      new JsonSerializerOptions
                    //      {
                    //          IgnoreNullValues = true,
                    //          PropertyNameCaseInsensitive = false
                    //      });
                    //prefs.UserPreferencesId = response.UserPreferenceUID;

                }

                prefs.UserId = userId;

                //load into config factory....
                //ConfigFactory.SetUserPreferences(prefs);
                //TODO: remove commented if session-User approach works//_userConfigurationService.SetUserPreferences(prefs, userId);
                _userConfigurationService.SetUserPreferences(prefs, String.Empty, userId);

                return prefs;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<SystemPreferenceSaveResponseModel> SetSystemPreferences(SystemPreferences sysPrefs)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SetSystemPreferencePath, _eidssApiOptions.BaseUrl);

                SystemPreferenceSetParameters jsonContainer = new();

                // Set the identifier...
                jsonContainer.SystemPreferenceID = sysPrefs.SystemPreferencesId;

                // Serialize the object into JSON...
                jsonContainer.PreferenceDetail = JsonConvert.SerializeObject(sysPrefs);

                var sysprefsJson = new StringContent(System.Text.Json.JsonSerializer.Serialize(jsonContainer), Encoding.UTF8, "application/json");

                var httpResponse = await _httpClient.PostAsync(new Uri(url), sysprefsJson).ConfigureAwait(false);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync().ConfigureAwait(false);

                return await System.Text.Json.JsonSerializer.DeserializeAsync<SystemPreferenceSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }).ConfigureAwait(false);
            }

            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { sysPrefs });
                throw;
            }
        }

        public async Task<UserPreferenceSaveResponseModel> SetUserPreferences(UserPreferences userPrefs)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SetUserPreferencePath, _eidssApiOptions.BaseUrl);

                UserPreferenceSetParameters jsonContainer = new()
                {
                    // Set the identifier...
                    UserPreferenceID = userPrefs.UserPreferencesId == 0 ? null : userPrefs.UserPreferencesId,
                    UserId = userPrefs.UserId,
                    ModuleConstantId = null,
                    AuditUserName= userPrefs.AuditUserName,
                    // Serialize the object into JSON... 
                    PreferenceDetail = "<UserPreferences>" + JsonConvert.SerializeObject(userPrefs) + "</UserPreferences>"
                };

                var postRequest = new HttpRequestMessage(HttpMethod.Post, url)
                {
                    Content = JsonContent.Create(jsonContainer)
                };


                var httpResponse = await _httpClient.SendAsync(postRequest);

                //var userPrefsJson = new StringContent(System.Text.Json.JsonSerializer.Serialize(jsonContainer), Encoding.UTF8, "application/json");

                //var httpResponse = await _httpClient.PostAsync(new Uri(url), userPrefsJson).ConfigureAwait(false);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync().ConfigureAwait(false);

                return await System.Text.Json.JsonSerializer.DeserializeAsync<UserPreferenceSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }).ConfigureAwait(false);
            }

            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { userPrefs });
                throw;
            }
        }

      
    }
}
