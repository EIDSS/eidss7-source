using Microsoft.AspNetCore.Mvc;

namespace EIDSS.Web.Areas.GridTesting.Controllers
{
    [Area("GridTesting")]
    [Controller]
    public class GridTestingController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
