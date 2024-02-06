using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Veterinary.ViewModels.ActiveSurveillanceSession;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
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

        public IActionResult Details(long? sessionId, bool isReadOnly = false)
        {
            ActiveSurveillanceSessionDetailPageViewModel model = new()
            {
                SessionID = sessionId,
                IsReadonly = isReadOnly
            };
            return View(model);
        }

        public IActionResult Add(long? campaignId = null)
        {
            ActiveSurveillanceSessionDetailPageViewModel model = new()
            {
                CampaignId = campaignId,
                IsReadonly = false
            };
            return View("Details", model);
        }
    }
}
