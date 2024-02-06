using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    /// <summary>
    /// 
    /// </summary>
    [Area("Administration")]
    [SubArea("Security")]
    [Controller]
    public class SecurityEventLogController : BaseController
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="logger"></param>
        public SecurityEventLogController(ITokenService tokenService , ILogger<SecurityEventLogController> logger) : base(logger, tokenService)
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public IActionResult Index()
        {
            return View();
        }
    }
}
