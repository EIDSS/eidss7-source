using Microsoft.AspNetCore.Mvc;

namespace EIDSS.Web.Areas.MapTesting.Controllers
{
    [Area("MapTesting")]
    [Controller]
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
