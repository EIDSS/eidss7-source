using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Localization.Constants;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]


    public class SecurityController : BaseController
    {
        private readonly IAdminClient _adminClient;
        private readonly IStringLocalizer _localizer;
        protected internal IUserConfigurationService _userConfigurationService;
        private ICrossCuttingService _iCrossCuttingService;
        private readonly IApplicationContext ApplicationContext;


        public IActionResult Index()
        {
            return View();
        }

        public SecurityController(
            IAdminClient adminClient,
            IStringLocalizer localizer,
            IUserConfigurationService configurationService,
            ICrossCuttingService crossCuttingService,
            ITokenService tokenService,
            ILogger<SecurityController> logger,
            IApplicationContext applicationContext) : base(logger, tokenService)
        {
            _localizer = localizer;
            _adminClient = adminClient;
            _userConfigurationService = configurationService;
            _iCrossCuttingService = crossCuttingService;
            ApplicationContext = applicationContext;
        }

        [HttpGet]
        public IActionResult ChangePassword()
        {
            ResetPasswordViewModel resetPasswordViewModel = new ResetPasswordViewModel();
            resetPasswordViewModel.ShowUserName = true;
            resetPasswordViewModel.FirstTimeLogin = true;
            var userName = ApplicationContext.GetSession("UserName");
            resetPasswordViewModel.UserName = userName;
            return View("ChangePassword", resetPasswordViewModel);
        }


        [HttpPost]
        public async Task<IActionResult> ChangePassword(ResetPasswordViewModel resetPasswordViewModel)
        {

            if (ModelState.IsValid)
            {
                var resetPassword = new ResetPasswordByUserParams()
                {

                    UserName = resetPasswordViewModel.UserName,
                    CurrentPassword = resetPasswordViewModel.CurrentPassword,
                    NewPassword = resetPasswordViewModel.NewPassword,
                    ConfirmNewPassword = resetPasswordViewModel.ConfirmNewPassword,
                    PasswordResetRequired = false,
                    UpdatingUser = resetPasswordViewModel.UserName,
                    ChkPasswordHistory = true

                };

                var result = await _adminClient.ResetPasswordByUser(resetPassword);

                if (string.Equals(result.Status, "SUCCESS", StringComparison.OrdinalIgnoreCase))
                {
                    var response = await _adminClient.LoginAsync(resetPassword.UserName, resetPassword.NewPassword);
                    if (response.Status)
                    {
                        var sessionId = ApplicationContext.SessionId;
                        //TODO: remove commented if session-User approach works//_userConfigurationService.RemoveUserToken(resetPassword.UserName);
                        _userConfigurationService.RemoveUserToken(sessionId, resetPassword.UserName);
                        ApplicationContext.RemoveSession("UserName");

                        var token = _tokenService.CreateAuthenticatedUser(response.Token, response.RefreshToken, response.Expiration.Value);

                        //TODO: remove commented if session-User approach works//_userConfigurationService.SetUserToken(resetPassword.UserName, token);
                        _userConfigurationService.SetUserToken(sessionId, resetPassword.UserName, token);
                        ApplicationContext.SetSession("UserName", token.UserName);
                        var claims = await _adminClient.GetUserClaims(token.UserName);
                        //TODO: consider possibility to convert authenticatedUser as an input user for UpdateClaimsInAuthenticatedUser
                        token =  _tokenService.UpdateClaimsInAuthenticatedUser(claims);
                        await _iCrossCuttingService.UpdateUserPreferencesInTokenAsync(token);
                        await _iCrossCuttingService.UpdateUserOrganizationInToken(Convert.ToInt64(token.PersonId), token.OfficeId, Thread.CurrentThread.CurrentCulture.Name, token);
                      
                        var valid = true;
                        if (token.UserOrganizations.Count == 0)
                        {
                            valid = false;
                        }
                        else if (token.UserOrganizations.Any(o => o.SiteID != 0))
                        {
                            valid = true;
                        }
                        else
                        {
                            valid = false;
                        }

                        if (!valid)
                        {
                            var userName = ApplicationContext.GetSession("UserName");
                            //TODO: remove commented if session-User approach works//_userConfigurationService.RemoveUserToken(userName);
                            _userConfigurationService.RemoveUserToken(sessionId, userName);
                            ApplicationContext.RemoveSession("UserName");

                            var model = new LoginViewModel();

                            ModelState.AddModelError(string.Empty, "Account is locked out");
                            return RedirectToAction("login","Admin", new { Area = "Administration",model = new LoginViewModel() });

                        }
                        Response.Cookies.Append(
                            CookieRequestCultureProvider.DefaultCookieName,
                            CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(token.Preferences.ActiveLanguage)),
                            new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1), SameSite = SameSiteMode.Strict, HttpOnly = true, Secure = true }
                        );

                        ResetSearchCookies();

                        //TODO: remove commented if session-User approach works//_userConfigurationService.SetUserToken(resetPassword.UserName, token);
                        _userConfigurationService.SetUserToken(sessionId, resetPassword.UserName, token);
                        ApplicationContext.SetSession("idfUserID", token.EIDSSUserId);
                        ApplicationContext.SetSession("UserSite", token.SiteId);

                        resetPasswordViewModel.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                        ViewBag.JavaScriptFunction = string.Format("showSuccessMessage()");
                        //return View("ChangePassword", resetPasswordViewModel);
                    }
                }
                else
                {

                    resetPasswordViewModel.ErrorMessage = String.Join(Environment.NewLine, result.Errors);

                }

            }
            //ViewBag.JavaScriptFunction = string.Format("showErrorMessage()");


            return View("ChangePassword", resetPasswordViewModel);

        }

        private void ResetSearchCookies()
        {
            Response.Cookies.Append("OrganizationSearchPerformedIndicator", "false");
            Response.Cookies.Append("SiteSearchPerformedIndicator", "false");
            Response.Cookies.Append("SiteGroupSearchPerformedIndicator", "false");
        }

    }
}
