using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.CrossCutting.Controllers;
using EIDSS.Web.TagHelpers.Models;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Controllers
{
    public class HomeController : Controller
    {

        internal AuthenticatedUser authenticatedUser;
        internal UserPermissions userPermission;
        private readonly ITokenService _tokenService;


        public HomeController( ITokenService tokenService)
        {
            _tokenService = tokenService;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }
    

        public IActionResult Index()
        {
            //return View();
            return RedirectToAction("login", "Admin", new { area = "Administration" });

        }

        public IActionResult MockUpTest()
        {
            return View();

        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        [HttpPost]
        public IActionResult SetLanguage(string culture, string returnUrl)
        {
            Response.Cookies.Append(
                CookieRequestCultureProvider.DefaultCookieName,
                CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(culture)),
                new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1), SameSite = SameSiteMode.Strict, HttpOnly = true, Secure = true }
            );

            //Set the actively selected language in the user preference collection.
            if (authenticatedUser != null)
            {
                authenticatedUser.Preferences.ActiveLanguage = culture;
            }


            return LocalRedirect(returnUrl);


        }
    }
}



