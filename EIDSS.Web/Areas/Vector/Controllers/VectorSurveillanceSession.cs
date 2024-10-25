using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.Vector;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Vector.Controllers
{
    [Area("Vector")]
    [Controller]
    public class VectorSurveillanceSession : BaseController
    {
        public VectorSurveillanceSession(ILogger<VectorSurveillanceSession> logger, ITokenService tokenService) : base(logger, tokenService)
        {
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Add(long? outbreakKey, string outbreakID)
        {
            VectorSurveillancePageViewModel vectorSurveillancePageViewModel = new()
            {
                OutbreakKey = outbreakKey,
                OutbreakID = outbreakID,
                AddToOutbreakIndicator = outbreakKey is not null
            };
            return View("Details", vectorSurveillancePageViewModel);
        }

        public IActionResult Edit(long sessionKey, bool isReadOnly = false)
        {
            var vectorSurveillancePageViewModel = new VectorSurveillancePageViewModel
                {
                    idfVectorSurveillanceSession = sessionKey,
                    IsReadOnly = isReadOnly
                };
            return View("Details", vectorSurveillancePageViewModel);
        }

    }
}