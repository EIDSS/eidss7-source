using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Controllers
{
    public class ValidatorController : Controller
    {
        public ValidatorController()
        {

        }
        public IActionResult Index()
        {
            return View();
        }
    }
}
