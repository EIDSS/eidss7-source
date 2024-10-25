using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    public class SystemEventLogController : BaseController
    {
        public IActionResult Index()
        {
            return View();
        }



        public SystemEventLogController(ITokenService tokenService, ILogger<SystemEventLogController> logger) : base( logger, tokenService)
        {
        }
    }
}

