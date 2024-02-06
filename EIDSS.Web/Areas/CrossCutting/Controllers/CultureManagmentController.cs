using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [Area("CrossCutting")]
    [Controller]
    public class CultureManagmentController : Controller
    {

        internal AuthenticatedUser authenticatedUser;
        internal UserPermissions userPermission;
        private readonly ITokenService _tokenService;


        public CultureManagmentController(ITokenService tokenService)
        {
            _tokenService = tokenService;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public IActionResult SetLanguage(string culture, string returnUrl)
        {
            Response.Cookies.Append(
                CookieRequestCultureProvider.DefaultCookieName,
                CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(culture)),
                new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1) ,SameSite=SameSiteMode.Strict, HttpOnly=true,Secure=true}
            );

            //Set the actively selected language in the user preference collection.
            if (authenticatedUser  != null)
            {
                authenticatedUser.Preferences.ActiveLanguage = culture;
            }
           

            return LocalRedirect(returnUrl);


        }


    }
}
