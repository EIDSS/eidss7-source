using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Menu;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "MenuView")]
    public class MenuViewController : BaseController
    {
        private readonly IMenuClient _menuClient;
        private readonly IOrganizationClient _organizationClient;
        internal AuthenticatedUser authenticatedUser;
        public string SessionUserName { get; set; } = "user";
        private readonly ILocalizationClient _localizationClient;
        internal CultureInfo CultureInfo = Thread.CurrentThread.CurrentCulture;
        internal IUserConfigurationService UserConfigurationService;
        private readonly IConfiguration _configuration;
        private readonly IApplicationContext ApplicationContext;

        public MenuViewController(IMenuClient menuClient, ILocalizationClient localizationClient, IUserConfigurationService configurationService, IConfiguration configuration, ITokenService tokenService, ILogger<MenuViewController> logger, IApplicationContext applicationContext, IOrganizationClient organizationClient) : base(logger, tokenService)
        {
            _menuClient = menuClient;
            _organizationClient = organizationClient;
            _localizationClient = localizationClient;
            UserConfigurationService = configurationService;
            authenticatedUser = null;
            _configuration = configuration;
            ApplicationContext = applicationContext;

            //TODO: remove commented if session-User approach works
            //////if (ApplicationContext.GetSession("UserName") == null) return;
            //////var userName = ApplicationContext.GetSession("UserName");
            ////authenticatedUser = UserConfigurationService.GetUserToken();

            if (applicationContext == null) return;
            var sessionId = applicationContext.SessionId;
            var loggedUserName = applicationContext.GetSession("UserName");
            //TODO: should it be configurationService instead of UserConfigurationService?
            authenticatedUser = UserConfigurationService.GetUserToken(sessionId, loggedUserName);
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            var dashboardVM = new DashboardViewModel
            {
                menuList = new List<MenuByUserViewModel>(),
                parentMenuList = new List<MenuByUserViewModel>(),
                LanguageModels = new List<LanguageModel>()
            };

            if (authenticatedUser != null)
            {
                //List<MenuViewModel> menuList = await _menuClient.GetMenuListAsync(Convert.ToInt64(authenticatedUser.EIDSSUserId), cultureInfo.Name);
               var menuList = await _menuClient.GetMenuByUserListAsync(Convert.ToInt64(authenticatedUser.EIDSSUserId), CultureInfo.Name, authenticatedUser.IsInArchiveMode);

               var menuIdExclusionList = authenticatedUser.IsInArchiveMode ? _configuration.GetValue<string>("ConnectToArchive:MenuIdExclusionList") : "";

               var userOrganization = await _organizationClient.GetOrganizationDetail(CultureInfo.Name, authenticatedUser.OfficeId);

               var paperFormMenuFileNames = new Dictionary<string, string>
               {
                   {"HumanDiseaseInvestigationForm", "General Case Investigation Form.pdf"},
                   {"AvianDiseaseInvestigationForm", "Investigation Form For Avian Disease Outbreaks.pdf"},
                   {"LivestockDiseaseInvestigationForm", "Investigation Form For Livestock Disease Outbreaks.pdf"}
               };

               dashboardVM = new DashboardViewModel
                {
                    userId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                    languageId = UserConfigurationService.GetUserPreferences(authenticatedUser.UserName).StartupLanguage,
                    menuList = menuList,
                    parentMenuList = menuList.Where(m => m.EIDSSParentMenuId == m.EIDSSMenuId).ToList(),
                    LanguageModels = await _localizationClient.GetLanguageList(Thread.CurrentThread.CurrentCulture.Name),
                    OrganizationName= userOrganization.AbbreviatedNameNationalValue,
                    StrOrganizationID = authenticatedUser.OfficeId.ToString(),
                    UserName=authenticatedUser.UserName,
                    OrganizationID = authenticatedUser.OfficeId,
                    UserOrganizations = authenticatedUser.UserOrganizations,
                    CanReadArchivedData = authenticatedUser.UserHasPermission(PagePermission.CanReadArchivedData, PermissionLevelEnum.Execute),
                    MenuIdExclusionList= menuIdExclusionList,
                    IsInArchiveMode = authenticatedUser.IsInArchiveMode,
                    PaperFormMenuFileNames = paperFormMenuFileNames,
                    ReadAccessToReports  = authenticatedUser.UserHasPermission(PagePermission.AccessToPaperForms, PermissionLevelEnum.Read),
                    ReadAccessToHDRData = authenticatedUser.UserHasPermission(PagePermission.AccessToHumanDiseaseReportData, PermissionLevelEnum.Read),
                    ReadAccessToVDRData = authenticatedUser.UserHasPermission(PagePermission.AccessToVeterinaryDiseaseReportsData, PermissionLevelEnum.Read)
               };
            }

            var viewData = new ViewDataDictionary<DashboardViewModel>(ViewData, dashboardVM);
            return new ViewViewComponentResult()
            {
                ViewName = "Default",
                ViewData = viewData
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public Task<IActionResult> Navigate([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                var area = jsonObject["Area"]?.ToString();
                var subArea = jsonObject["SubArea"]?.ToString();
                var controller = jsonObject["Controller"]?.ToString();
                var action = jsonObject["Action"]?.ToString();

                return Task.FromResult<IActionResult>(Json(new { redirectToUrl = Url.Action(action, controller, new {Area = area, SubArea = subArea}), changesPendingSave = authenticatedUser.ChangesPendingSave}));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public Task<IActionResult> ClearChangesPendingSave()
        {
            try
            {
                authenticatedUser.ChangesPendingSave = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
            }

            return Task.FromResult<IActionResult>(Ok(authenticatedUser.ChangesPendingSave));
        }
    }
}
