#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

#endregion

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class SiteAlertsSubscriptionController : BaseController
    {
        private readonly UserPermissions _siteAlertPermissions;

        public SiteAlertsSubscriptionController(ITokenService tokenService, ILogger<SiteAlertsSubscriptionController> logger) : base(logger, tokenService)
        {
            _siteAlertPermissions = GetUserPermissions(PagePermission.CanManageSiteAlertsSubscriptions);
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public IActionResult Index()
        {
            return View("Index");
        }
    }
}