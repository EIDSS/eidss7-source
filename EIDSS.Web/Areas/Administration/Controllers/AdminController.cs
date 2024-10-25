using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using EIDSS.Web.ActionFilters;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration.Security;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;

namespace EIDSS.Web.Controllers
{
    [Area("Administration")]
    [Controller]
    public class AdminController : Controller
    {
        //private CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        //private CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        private readonly IPreferenceClient _preferenceClient;
        private readonly ICrossCuttingService _iCrossCuttingService;
        private readonly ITokenService _tokenService;
        private readonly IAdminClient _adminClient;
        private readonly ISecurityEventClient _securityEventClient;
        private readonly IEmployeeClient _employeeClient;
        protected internal ILogger _logger;
        protected internal IUserConfigurationService _userConfigurationService;
        private readonly IStringLocalizer _localizer;
        internal AuthenticatedUser token;
        private readonly IApplicationContext ApplicationContext;


        public AdminController(IAdminClient adminClient,
            ITokenService tokenService,
            IPreferenceClient preferenceClient,
            IEmployeeClient employeeClient,
            ICrossCuttingService crossCuttingService,
            ILogger<AdminController> logger,
            IUserConfigurationService configurationService, 
            IStringLocalizer localizer,
            ISecurityEventClient securityEventClient,
            IApplicationContext applicationContext
            )
        {
            _logger = logger;
            _adminClient = adminClient;
            _preferenceClient = preferenceClient;
            _employeeClient = employeeClient;
            _iCrossCuttingService = crossCuttingService;
            _tokenService = tokenService;
            _userConfigurationService = configurationService;
            _localizer = localizer;
            _securityEventClient = securityEventClient;
            ApplicationContext = applicationContext;
        }

        [Route("Index")]
        public ViewResult Index()
        {
            throw new Exception("Error");
        }

        [HttpGet]
        [ViewLayout("_MinLayout")]
        public async Task<IActionResult> LoginAsync()
        {
            await _preferenceClient.InitializeSystemPreferences();
            return View();
        }

        // POST: When submitting the login credentials
        [HttpPost]
        [ViewLayout("_MinLayout")]
        //[EventLogActionFilter]
        //[ValidateModelStateAttribute(RedirectToAction = "Login", RedirectToController = "Admin")]
        [AllowAnonymous]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    await _preferenceClient.InitializeSystemPreferences();
                    var response = await _adminClient.LoginAsync(model.Username, model.Password);
                    if (response.Status)
                    {
                        var sessionId = ApplicationContext.SessionId;
                        var loggedUserName = ApplicationContext.GetSession("UserName");
                        //TODO: remove commented if session-User approach works//_userConfigurationService.RemoveUserToken(loggedUserName);
                        _userConfigurationService.RemoveUserToken(sessionId, loggedUserName);
                        ApplicationContext.RemoveSession("UserName");
                        await HttpContext.SignOutAsync("EidssCookie");
                        Response.Cookies.Delete("EidssCookie");
                        token = _tokenService.CreateAuthenticatedUser(response.Token, response.RefreshToken, response.Expiration.Value);
                        //TODO: remove commented if session-User approach works//_userConfigurationService.SetUserToken(model.Username, token);
                        _userConfigurationService.SetUserToken(sessionId, model.Username, token);
                        ApplicationContext.SetSession("UserName", token.UserName);
                        ApplicationContext.SetSession("LockoutThld", token.LockoutThld);
                        ApplicationContext.SetSession("MaxSessionLength", token.MaxSessionLength);
                        ApplicationContext.SetSession("InactivityTimeOut", token.InactivityTimeOut);
                        ApplicationContext.SetSession("DisplaySessionInactivity", token.DisplaySessionInactivity);
                        ApplicationContext.SetSession("DisplaySessionCloseOut", token.DisplaySessionCloseOut);

                        await _adminClient.ConnectToArchive(false);

                        var handler = new JwtSecurityTokenHandler();
                        var readableToken = handler.CanReadToken(response.Token);
                        if (readableToken)
                        {
                            var payLoad = handler.ReadJwtToken(response.Token);
                            var claimsIdentity = new ClaimsIdentity(payLoad.Claims, "EidssCookie");
                            var authProperties = new AuthenticationProperties
                            {
                                AllowRefresh = true,
                                ExpiresUtc = DateTime.UtcNow.AddMinutes(30),
                                IsPersistent = true
                            };
                            await HttpContext.SignInAsync("EidssCookie", new ClaimsPrincipal(claimsIdentity),authProperties);
                        }
                        var claims = await _adminClient.GetUserClaims(model.Username);
                        //TODO: consider possibility to convert authenticatedUser as an input user for UpdateClaimsInAuthenticatedUser
                        token = _tokenService.UpdateClaimsInAuthenticatedUser(claims);

                        await _iCrossCuttingService.UpdateUserPreferencesInTokenAsync(token);
                        await _iCrossCuttingService.UpdateUserOrganizationInToken(Convert.ToInt64(token.PersonId), token.OfficeId, Thread.CurrentThread.CurrentCulture.Name, token);
                        var permissions = await _adminClient.GetUserRolesAndPermissions(Convert.ToInt64(token.EIDSSUserId), null);

                        if (token.UserOrganizations.Count > 0)
                        {
                            _iCrossCuttingService.RefreshToken(token.UserOrganizations.FirstOrDefault(x => x.OrganizationID == Convert.ToInt64(token.OfficeId)), permissions, token);
                        }


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
                            //var userName = ApplicationContext.GetSession("UserName");
                            SecurityEventLogSaveRequestModel securityEventLog = new()
                            {
                                IdfsAction = (long) SecurityEventActionEnum.Logon,
                                IdfsProcessType = (long) SecurityEventProcessTypeEnum.EIDSS,
                                ResultFlag = true,
                                StrDescription = "Account is locked out"
                            };

                            await AddSecurityEventLog(securityEventLog);

                            //TODO: remove commented if session-User approach works
                            ////_userConfigurationService.RemoveUserToken();
                            //////ApplicationContext.RemoveSession("UserName");

                            _userConfigurationService.RemoveUserToken(sessionId, model.Username);//TODO: replace model.Username with token.UserName ?
                            ApplicationContext.RemoveSession("UserName");


                            ModelState.AddModelError(string.Empty, "Account is locked out");
                            return View(model);

                        }

                        Response.Cookies.Append(
                            CookieRequestCultureProvider.DefaultCookieName,
                            CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(token.Preferences.ActiveLanguage)),
                            new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1), SameSite = SameSiteMode.Strict, HttpOnly = true, Secure = true }
                        );

                        ResetSearchCookies();

                        //TODO: remove commented if session-User approach works//_userConfigurationService.SetUserToken(model.Username, token);
                        _userConfigurationService.SetUserToken(sessionId, model.Username, token);
                        ApplicationContext.SetSession("idfUserID", token.EIDSSUserId);
                        ApplicationContext.SetSession("UserSite", token.SiteId);

                        //SecurityEventLogSaveRequestModel securityEventLog = new()
                        //    {
                        //        IdfUserId = Convert.ToInt64(token.EIDSSUserId),
                        //        IdfsAction = (long) SecurityEventActionEnum.Logon,
                        //        IdfsProcessType = (long) SecurityEventProcessTypeEnum.EIDSS,
                        //        IdfSiteId =  Convert.ToInt64(token.SiteId),
                        //        ResultFlag = true,
                        //        StrDescription = "Login Successful",
                        //        IdfObjectId = 0

                        //    };

                        //await _securityEventClient.SaveSecurityEventLog(securityEventLog);
                        if (token.PasswordResetRequired)
                        {
                            _logger.LogInformation("redirect to  resetpassword");
                            return RedirectToAction("resetpassword", "Admin");
                        }
                        else
                        {
                            _logger.LogInformation("redirect to Dashboard");
                            return RedirectToAction("index", "Dashboard");
                        }
                    }
                    if (response.Message == "DISABLED")
                    {
                        SecurityEventLogSaveRequestModel securityEventLog = new()
                        {
                            IdfsAction = (long)SecurityEventActionEnum.Logon,
                            IdfsProcessType = (long)SecurityEventProcessTypeEnum.EIDSS,
                            ResultFlag = false,
                            StrDescription = _localizer.GetString(FieldLabelResourceKeyConstants.AccountIsDisabledFieldLabel)
                        };

                        await AddSecurityEventLog(securityEventLog);

                        _logger.LogInformation("Account is disabled");
                        ModelState.AddModelError(string.Empty, String.Join(Environment.NewLine, response.Errors));
                    }
                    else if (response.Message == "LOCKEDOUT")
                    {
                        SecurityEventLogSaveRequestModel securityEventLog = new()
                        {
                            IdfsAction = (long)SecurityEventActionEnum.Logon,
                            IdfsProcessType = (long)SecurityEventProcessTypeEnum.EIDSS,
                            ResultFlag = false,
                            StrDescription =    _localizer.GetString(FieldLabelResourceKeyConstants.EmployeeLockedFieldLabel)
                    };

                        await AddSecurityEventLog(securityEventLog);

                        _logger.LogInformation("Account is LOCKEDOUT");
                        ModelState.AddModelError(string.Empty, String.Join(Environment.NewLine, response.Errors));
                    }
                    else
                    {

                        SecurityEventLogSaveRequestModel securityEventLog = new()
                        {
                            IdfsAction = (long)SecurityEventActionEnum.Logon,
                            IdfsProcessType = (long)SecurityEventProcessTypeEnum.EIDSS,
                            ResultFlag = false,
                            StrDescription = "User with such login/password is not found"
                        };
                        await AddSecurityEventLog(securityEventLog);

                        _logger.LogInformation("login combination is correct");
                        ModelState.AddModelError(string.Empty, _localizer.GetString(MessageResourceKeyConstants.LoginCombinationOfUserPasswordYouEnteredIsNotCorrectMessage));
                    }
                }
                else
                {
                    _logger.LogInformation("Model status is not valid");
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e.StackTrace);
            }
            
            return View(model);
        }

        private async Task AddSecurityEventLog(SecurityEventLogSaveRequestModel securityEventLog)
        {
            //TODO: remove commented if session-User approach works
            ////// var userName = ApplicationContext.GetSession("UserName");
            ////AuthenticatedUser userToken = null;
            ////userToken = _userConfigurationService.GetUserToken();

            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            var userToken = _userConfigurationService.GetUserToken(sessionId, loggedUserName);

            long? userId = null;
            long siteId = 0;

            if (userToken != null)
            {
                userId = Convert.ToInt64(userToken.EIDSSUserId);
                siteId = Convert.ToInt64(userToken.SiteId);
            }
            securityEventLog.IdfUserId = userId;
            securityEventLog.IdfSiteId = siteId;
            securityEventLog.IdfObjectId = 0;

            await _securityEventClient.SaveSecurityEventLog(securityEventLog);
        }

        [HttpGet]
        [Route("Logout")]
        public async Task<IActionResult> Logout()
        {
            try
            {
                var sessionId = ApplicationContext.SessionId;
                var loggedUserName = ApplicationContext.GetSession("UserName");

                //TODO: remove commented if session-User approach works
                //////if (ApplicationContext.GetSession("UserName") != null)
                //////{
                await _adminClient.ConnectToArchive(false);

                    SecurityEventLogSaveRequestModel securityEventLog = new()
                    {
                        IdfsAction = (long)SecurityEventActionEnum.Logoff,
                        IdfsProcessType = (long)SecurityEventProcessTypeEnum.EIDSS,
                        ResultFlag = true,
                        StrDescription = "Logoff Successful"
                    };
                    await AddSecurityEventLog(securityEventLog);

                //TODO: remove commented if session-User approach works
                //////var userName = ApplicationContext.GetSession("UserName");
                ////_userConfigurationService.RemoveUserToken();
                //////  ApplicationContext.RemoveSession("UserName");

                _userConfigurationService.RemoveUserToken(sessionId, loggedUserName);
                ApplicationContext.RemoveSession("UserName");


                TempData["ResetSearchSessionsScript"] = string.Format("resetSearchSessionStorage()");

                await HttpContext.SignOutAsync();

                HttpContext.Session.Clear();
                DeleteAllCookies();


                //////}
            }
            catch (Exception e)
            {
                _logger.LogError(e.StackTrace);
                throw;
            }
           

            //await _adminClient.LogOutAsync(userName);
            return RedirectToAction("Login", "Admin");
        }

        private void DeleteAllCookies()
        {
            foreach(var cookie in Request.Cookies.Keys)
            {
                Response.Cookies.Delete(cookie, new CookieOptions()
                {
                    Secure = true
                });

            }
        }

        [HttpGet]
        [ViewLayout("_MinLayout")]
        public async Task<IActionResult> ResetPassword()
        {
            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            ResetPasswordViewModel resetPasswordViewModel = new()
            {
                ShowUserName = true,
                FirstTimeLogin = true,
                // var userName = ApplicationContext.GetSession("UserName");
                //TODO: remove commented if session-User approach works//UserName = _userConfigurationService.GetUserToken().UserName
                UserName = loggedUserName
            };

            //TODO: remove commented if session-User approach works
            ////_userConfigurationService.RemoveUserToken();
            //////ApplicationContext.RemoveSession("UserName");
            _userConfigurationService.RemoveUserToken(sessionId, loggedUserName);
            ApplicationContext.RemoveSession("UserName");


            await HttpContext.SignOutAsync();
            return View("ResetPassword", resetPasswordViewModel);
        }

        [HttpPost]
        [ViewLayout("_MinLayout")]
        public async Task<IActionResult> ResetPassword(ResetPasswordViewModel resetPasswordViewModel)
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
                        var authenticatedUser = _tokenService.CreateAuthenticatedUser(response.Token, response.RefreshToken, response.Expiration.Value);
                        //TODO: remove commented if session-User approach works//_userConfigurationService.SetUserToken(resetPassword.UserName, authenticatedUser);
                        _userConfigurationService.SetUserToken(sessionId, resetPassword.UserName, authenticatedUser);
                        // ApplicationContext.SetSession("UserName", authenticatedUser.UserName);
                        var claims = await _adminClient.GetUserClaims(resetPassword.UserName);
                        //TODO: consider possibility to convert authenticatedUser as an input user for UpdateClaimsInAuthenticatedUser
                        authenticatedUser = _tokenService.UpdateClaimsInAuthenticatedUser(claims);
                        await _iCrossCuttingService.UpdateUserPreferencesInTokenAsync(authenticatedUser);

                        Response.Cookies.Append(
                            CookieRequestCultureProvider.DefaultCookieName,
                            CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(authenticatedUser.Preferences.ActiveLanguage)),
                            new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1), SameSite = SameSiteMode.Strict, HttpOnly = true, Secure = true }
                        );

                        ResetSearchCookies();
                        resetPasswordViewModel.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                        ViewBag.JavaScriptFunction = string.Format("showSuccessMessage()");
                        return View("ResetPassword", resetPasswordViewModel);

                        // return RedirectToAction("index", "Dashboard");
                    }

                }
                else
                {

                    resetPasswordViewModel.ErrorMessage = String.Join(Environment.NewLine, result.Errors);

                }

            }
            ViewBag.JavaScriptFunction = string.Format("showErrorMessage()");


            return View("ResetPassword", resetPasswordViewModel);

        }

        //[AcceptVerbs("GET", "POST")]
        [Route("IsUserExists")]
        public IActionResult IsUserExists(string userName)
        {
            //if (await _adminClient.UserExists(userName))
            //{
            //    return Json($"User {userName} is already there.");
            //}

            return Json(false);
        }

        [HttpPost]
        public async Task<IActionResult> RefreshUserMenu(string StrOrganizationID, string returnUrl)
        {
            //TODO: remove commented if session-User approach works//_userConfigurationService.RemoveUserToken(loggedUserName);
            //// var userName = ApplicationContext.GetSession("UserName");
            //token = _userConfigurationService.GetUserToken();

            var sessionId = ApplicationContext.SessionId;
            var loggedUserName = ApplicationContext.GetSession("UserName");
            token = _userConfigurationService.GetUserToken(sessionId, loggedUserName);


            await _iCrossCuttingService.UpdateUserOrganizationInToken(Convert.ToInt64(token.PersonId), Convert.ToInt64(StrOrganizationID), Thread.CurrentThread.CurrentCulture.Name, token);

            var permissions = await _adminClient.GetUserRolesAndPermissions(Convert.ToInt64(token.EIDSSUserId), null);

            _iCrossCuttingService.RefreshToken(token.UserOrganizations.FirstOrDefault(x => x.OrganizationID == Convert.ToInt64(StrOrganizationID)), permissions, token);

            return RedirectToAction("index", "Dashboard");
            //return LocalRedirect(returnUrl);
        }

        [HttpPost]
        public JsonResult KeepSessionAlive()
        {
            return this.Json(new { Data = "Beat Generated" }); 
        }

        /// <summary>
        /// Reset cookies created from user searches in the Administration module.
        /// </summary>
        private void ResetSearchCookies()
        {
            Response.Cookies.Append("OrganizationSearchPerformedIndicator", "false");
            Response.Cookies.Append("SiteSearchPerformedIndicator", "false");
            Response.Cookies.Append("SiteGroupSearchPerformedIndicator", "false");
        }
    }
}
