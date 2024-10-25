using Microsoft.AspNetCore.Mvc;
using EIDSS.ClientLibrary.Services;
using Microsoft.Extensions.Logging;
using EIDSS.Web.Abstracts;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class ActiveSurveillanceSessionController : BaseController
    {
        public ActiveSurveillanceSessionController(ITokenService tokenService, ILogger<ActiveSurveillanceSessionController> logger) : base(logger, tokenService)
        {

        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Create()
        {
            return View();
        }
    }
}
