using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class WHOExportController : BaseController
    {
        public WHOExportController(ILogger<WHOExportController> logger) : base(logger)
        {

        }
        public IActionResult Index()
        {
            return View();
        }
    }
}
