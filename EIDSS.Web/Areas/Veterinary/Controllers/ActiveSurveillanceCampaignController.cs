using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using EIDSS.Web.Areas.Shared.ViewModels;
using EIDSS.Domain.ViewModels.Common;

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
    [Controller]
    public class ActiveSurveillanceCampaignController : BaseController
    {

        public ActiveSurveillanceCampaignController(ITokenService tokenService, ILogger<ActiveSurveillanceCampaignController> logger) : base(logger, tokenService)
        {

        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Details(long? campaignId, bool isReadOnly = false)
        {
            ActiveSurveillanceCampaignViewModel model = new();
            model.ActiveSurveillanceCampaignDetail = new ActiveSurveillanceCampaignDetailViewModel();
            model.CampaignID = campaignId;
            model.IsReadonly = isReadOnly;
            return View(model);
        }

        public IActionResult Add()
        {
            ActiveSurveillanceCampaignViewModel model = new();
            model.ActiveSurveillanceCampaignDetail = new ActiveSurveillanceCampaignDetailViewModel();
            model.CampaignID = null;
            model.IsReadonly = false;
            return View("Details", model);
        }
    }
}
