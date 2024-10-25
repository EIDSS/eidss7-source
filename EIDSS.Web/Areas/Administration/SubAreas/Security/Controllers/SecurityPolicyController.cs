using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SecurityPolicy;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    [Controller]
    public class SecurityPolicyController : BaseController
    {

        private readonly ISecurityPolicyClient _securityPolicyClient;
        private readonly IStringLocalizer _localizer;
        private readonly UserPermissions _siteAlertPermissions;
        private readonly IAdminClient _adminClient;
        private readonly IApplicationContext ApplicationContext;

        public SecurityPolicyController(ISecurityPolicyClient securityPolicyClient, IStringLocalizer localizer, ITokenService tokenService,
          ILogger<SecurityPolicyController> logger,IAdminClient adminClient, IApplicationContext applicationContext) :  base(logger, tokenService)
        {
            _securityPolicyClient = securityPolicyClient;
            _siteAlertPermissions = GetUserPermissions(PagePermission.AccessToSecurityPolicy);
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _localizer = localizer;
            _adminClient = adminClient;
            ApplicationContext = applicationContext;
        }

        public async Task<IActionResult> Index()
        {
            var model = new SecurityPolicyDetailsViewModel()
            {
                WriteAccessToSecurityPolicy = _siteAlertPermissions.Write,
                ReadAccessToSecurityPolicy = _siteAlertPermissions.Read,
                SecurityConfigurationViewModel = await _securityPolicyClient.GetSecurityPolicy()
            };

            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Index(SecurityPolicyDetailsViewModel model)
        {
            try
            {
                if (TryValidateModel(model.SecurityConfigurationViewModel))
                {
                    //save
                    var request = new SecurityPolicySaveRequestModel()
                    {
                        Id = model.SecurityConfigurationViewModel.SecurityPolicyConfigurationUID,
                        MinPasswordLength = model.SecurityConfigurationViewModel.MinPasswordLength,
                        EnforcePasswordHistoryCount =
                            model.SecurityConfigurationViewModel.EnforcePasswordHistoryCount.Value,
                        MinPasswordAgeDays = model.SecurityConfigurationViewModel.MinPasswordAgeDays.Value,
                        ForceUppercaseFlag = model.SecurityConfigurationViewModel.ForceUppercaseFlag,
                        ForceLowercaseFlag = model.SecurityConfigurationViewModel.ForceLowercaseFlag,
                        ForceNumberUsageFlag = model.SecurityConfigurationViewModel.ForceNumberUsageFlag,
                        ForceSpecialCharactersFlag = model.SecurityConfigurationViewModel.ForceSpecialCharactersFlag,
                        AllowUseOfSpaceFlag = model.SecurityConfigurationViewModel.AllowUseOfSpaceFlag,
                        PreventSequentialCharacterFlag =
                            model.SecurityConfigurationViewModel.PreventSequentialCharacterFlag,
                        PreventUsernameUsageFlag = model.SecurityConfigurationViewModel.PreventUsernameUsageFlag,
                        LockoutThld = model.SecurityConfigurationViewModel.LockoutThld,
                        SesnInactivityTimeOutMins = model.SecurityConfigurationViewModel.SesnInactivityTimeOutMins,
                        MaxSessionLength = model.SecurityConfigurationViewModel.MaxSessionLength,
                        SesnIdleTimeoutWarnThldMins = model.SecurityConfigurationViewModel.SesnIdleTimeoutWarnThldMins,
                        SesnIdleCloseoutThldMins = model.SecurityConfigurationViewModel.SesnIdleCloseoutThldMins,
                        EventTypeId = (long) SystemEventLogTypes.SecurityPolicyChange,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        LocationId = authenticatedUser.RayonId,
                        AuditUserName = authenticatedUser.UserName
                    };
                    var response = await _securityPolicyClient.SaveSecurityPolicy(request);
                    if (response.ReturnMessage == "SUCCESS")
                    {

                        ApplicationContext.SetSession("InactivityTimeOut", request.SesnInactivityTimeOutMins.ToString());
                        ApplicationContext.SetSession("MaxSessionLength", request.MaxSessionLength.ToString());
                        ApplicationContext.SetSession("DisplaySessionInactivity", request.SesnIdleTimeoutWarnThldMins.ToString());
                        ApplicationContext.SetSession("DisplaySessionCloseOut", request.SesnIdleCloseoutThldMins.ToString());


                        var result = await _adminClient.UpdateIdentityOptions();

                        model = new SecurityPolicyDetailsViewModel()
                        {
                            WriteAccessToSecurityPolicy = _siteAlertPermissions.Write,
                            ReadAccessToSecurityPolicy = _siteAlertPermissions.Read,
                            SecurityConfigurationViewModel = await _securityPolicyClient.GetSecurityPolicy(),
                            InformationalMessage =
                                _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)
                        };
                    }
                    else
                    {
                        throw new ApplicationException("Error Saving Security Policy");
                    }
                }

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }
}
