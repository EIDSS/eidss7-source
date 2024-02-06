using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;


namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class SettlementTypesController : BaseController
    {
        public SettlementTypesController(ILogger<SettlementTypesController> logger) : base(logger)
        {

        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
