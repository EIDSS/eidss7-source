using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Administration.Controllers
{

    [Area("Administration")]
    [Controller]
    public class DashboardController : BaseController
    {
        AuthenticatedUser _authenticatedUser;

        public DashboardController(ILogger<DashboardController> logger, ITokenService tokenService) : base(logger, tokenService)
        {
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
        }


        // GET: DashboardController
        public ActionResult Index()
        {
            var dashboardPageViewModel = new DashboardPageViewModel()
            {
                isConnectToArchive = _tokenService.GetAuthenticatedUser().IsInArchiveMode
            };

            return View(dashboardPageViewModel);
        }
    }
}
