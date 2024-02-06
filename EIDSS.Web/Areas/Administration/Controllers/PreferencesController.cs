using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    public class PreferencesController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ILocalizationClient _localizationClient;
        private readonly IPreferenceClient _preferenceClient;
        private ICrossCuttingService _iCrossCuttingService;
        private readonly IStringLocalizer _localizer;
        private readonly IConfiguration _configuration;
        private IUserConfigurationService _userConfigurationService;

        private UserPermissions systemPrefPermissions;

        public PreferencesController(ICrossCuttingClient crossCuttingClient, 
            ILocalizationClient localizationClient, 
            IPreferenceClient preferenceClient,
            ITokenService tokenService,
             ICrossCuttingService crossCuttingService,
             IStringLocalizer localizer,
             IConfiguration configuration,
            ILogger<PreferencesController> logger,
            IUserConfigurationService configurationService) : base(logger, tokenService)
        {
            _crossCuttingClient = crossCuttingClient;
            _localizationClient = localizationClient;
            _preferenceClient = preferenceClient;
            _iCrossCuttingService = crossCuttingService;
            _localizer = localizer;
            _configuration = configuration;
            _userConfigurationService = configurationService;
            systemPrefPermissions = GetUserPermissions(PagePermission.AccessToSystemPreferences);
        }

        [HttpGet]
        public async Task<IActionResult> SystemPreferenceSettings()
        {
            var systemPrefViewModel = new SystemPreferencePageViewModel();
            var systemPref = new SystemPreferences();
            try
            {
                systemPref = await _preferenceClient.InitializeSystemPreferences();
                systemPref.PageHeading = _localizer.GetString(HeadingResourceKeyConstants.SystemPreferencesPageHeading);
                systemPref.DefaultMapProject = -1;
                systemPref.SystemPreferencesId = systemPref.SystemPreferencesId;
                List<CountryModel> countryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
                systemPref.CountryList = countryList;
                List<LanguageModel> languageList = await _localizationClient.GetLanguageList(GetCurrentLanguage()).ConfigureAwait(false);
                systemPref.LanguageList = languageList;
                var mapProjects = new List<MapProject>();
                MapProject mapProject = new()
                {
                    MapText = _localizer.GetString(HeadingResourceKeyConstants.SytemPreferencesDefault),
                    Value = -1
                };
                mapProjects.Add(mapProject);
                systemPref.MapProjects = mapProjects;

                systemPrefViewModel = new SystemPreferencePageViewModel()
                {
                    systemPreferences = systemPref,
                    permissions = systemPrefPermissions
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return View(systemPrefViewModel);
        }

        [HttpPost]
        public async Task<IActionResult> SystemPreferenceSettings(string button, SystemPreferencePageViewModel systemPreferencePageViewModel)
        {
            try
            {

                if (button != "Clear" && ModelState.IsValid)
                {
                    systemPreferencePageViewModel.systemPreferences.Country = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

                    if (systemPreferencePageViewModel.systemPreferences.StartupLanguage == "-1")
                    {
                        ModelState.AddModelError("systemPreferences.StartupLanguage", "Select Startup Language");
                    }
                    else
                    {
                        var response = await _preferenceClient.SetSystemPreferences(systemPreferencePageViewModel.systemPreferences).ConfigureAwait(false);

                        if (response.ReturnCode != null)
                        {
                            switch (response.ReturnCode)
                            {
                                // Success
                                case 0:
                                    systemPreferencePageViewModel.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                    break;

                                default:
                                    throw new ApplicationException("Unable to save system preferences.");
                            }
                        }
                        else
                        {
                            throw new ApplicationException("Unable to save system preferences.");
                        }
                    }
                }

                if (button == "Clear")
                {
                    ModelState.Clear();
                    systemPreferencePageViewModel.systemPreferences = new SystemPreferences();
                    systemPreferencePageViewModel.systemPreferences.Country = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

                }
                //systemPreferencePageViewModel.systemPreferences = new SystemPreferences();
                systemPreferencePageViewModel.systemPreferences.PageHeading = _localizer.GetString(HeadingResourceKeyConstants.SystemPreferencesPageHeading);

                List<CountryModel> countryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
                systemPreferencePageViewModel.systemPreferences.CountryList = countryList;
                List<LanguageModel> languageList = await _localizationClient.GetLanguageList(GetCurrentLanguage()).ConfigureAwait(false);
                systemPreferencePageViewModel.systemPreferences.StartupLanguage = "-1";
                systemPreferencePageViewModel.systemPreferences.LanguageList = languageList;
                var mapProjects = new List<MapProject>();
                MapProject mapProject = new()
                {
                    MapText = "Default",
                    Value = -1
                };
                mapProjects.Add(mapProject);
                systemPreferencePageViewModel.systemPreferences.MapProjects = mapProjects;
                return View(systemPreferencePageViewModel); 
           }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpGet]
        public async Task<IActionResult> UserPreferenceSettings()
        {
            UserPreferencePageViewModel userPreferencePageViewModel = new();
            UserPreferences userPreferences = new(_userConfigurationService);
            try
            {
                
                userPreferences = await _preferenceClient.InitializeUserPreferences(Convert.ToInt64(authenticatedUser.EIDSSUserId));
                userPreferences.PageHeading = _localizer.GetString(HeadingResourceKeyConstants.UserPreferencesPageHeading); 
                userPreferences.DefaultMapProject = -1;
                userPreferences.UserPreferencesId = userPreferences.UserPreferencesId;

                List<CountryModel> countryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
                userPreferences.CountryList = countryList;
                List<LanguageModel> languageList = await _localizationClient.GetLanguageList(GetCurrentLanguage()).ConfigureAwait(false);
                userPreferences.LanguageList = languageList;
                List<MapProject> mapProjects = new();
                MapProject mapProject = new()
                {
                    MapText = "Default",
                    Value = -1
                };
                mapProjects.Add(mapProject);

                userPreferences.MapProjects = mapProjects;

                userPreferencePageViewModel = new UserPreferencePageViewModel()
                {
                    UserPreferences = userPreferences
                    
                };

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            return View(userPreferencePageViewModel);
        }

        [HttpPost]
        public async Task<IActionResult> UserPreferenceSettings(string button, UserPreferencePageViewModel userPreferencePageViewModel)
        {
            try
            {
                if (button != "Clear" && ModelState.IsValid)
                {
                    userPreferencePageViewModel.UserPreferences.UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId);

                    userPreferencePageViewModel.UserPreferences.AuditUserName = authenticatedUser.UserName;
                    var UserPreferenceSaveResponseModel=  await _preferenceClient.SetUserPreferences(userPreferencePageViewModel.UserPreferences).ConfigureAwait(false);

                    if (UserPreferenceSaveResponseModel.ReturnCode != null)
                    {
                        switch (UserPreferenceSaveResponseModel.ReturnCode)
                        {
                            // Success
                            case 0:
                                    userPreferencePageViewModel.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                                break;

                            default:
                                throw new ApplicationException("Unable to save user preferences.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save user preferences.");
                    }


                    authenticatedUser.Preferences.UserPreferencesId = UserPreferenceSaveResponseModel.UserPreferenceID;
                    await _preferenceClient.InitializeUserPreferences(Convert.ToInt64(authenticatedUser.EIDSSUserId));
                    await _iCrossCuttingService.UpdateUserPreferencesInTokenAsync(authenticatedUser);

                    Response.Cookies.Append(
                        CookieRequestCultureProvider.DefaultCookieName,
                        CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(userPreferencePageViewModel.UserPreferences.StartupLanguage)),
                        new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1), SameSite = SameSiteMode.Strict, HttpOnly = true, Secure = true }
                    );

                
                }


                if (button == "Clear")
                {
                    ModelState.Clear();
                    userPreferencePageViewModel.UserPreferences = new UserPreferences(_userConfigurationService);
                }
                userPreferencePageViewModel.UserPreferences.PageHeading = _localizer.GetString(HeadingResourceKeyConstants.UserPreferencesPageHeading);


                List<CountryModel> countryList = await _crossCuttingClient.GetCountryList(GetCurrentLanguage()).ConfigureAwait(false);
                userPreferencePageViewModel.UserPreferences.CountryList = countryList;
                List<LanguageModel> languageList = await _localizationClient.GetLanguageList(GetCurrentLanguage()).ConfigureAwait(false);
                userPreferencePageViewModel.UserPreferences.LanguageList = languageList;
                var mapProjects = new List<MapProject>();
                MapProject mapProject = new()
                {
                    MapText = "Default",
                    Value = -1
                };
                mapProjects.Add(mapProject);
                userPreferencePageViewModel.UserPreferences.MapProjects = mapProjects;
                return View(userPreferencePageViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }
}