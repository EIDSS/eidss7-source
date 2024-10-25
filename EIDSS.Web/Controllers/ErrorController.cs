using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Controllers
{
    public class ErrorController : BaseController
    {
        
        public ErrorController(ILogger<ErrorController> logger) : base(logger)
        {

        }

        // GET: ErrorController
        [Route("Error/{statusCode}")]
        public ActionResult HttpStatusCodeHandler(int statusCode)
        {
            switch(statusCode)
            {
                case 404:
                    ViewBag.ErrorMessage = "The resource you requested could not be found";
                    break;
            }
            return View("NotFound");
        }

        [Route("Error")]
        [AllowAnonymous]
        public IActionResult Error()
        {
            var exceptionDetails = HttpContext.Features.Get<IExceptionHandlerPathFeature>();
            _logger.LogError(exceptionDetails.Error.Message, exceptionDetails);

            ViewBag.ExceptionPath = exceptionDetails.Path;
            ViewBag.ExceptionMessage = "Exception happened on this page";
            //ViewBag.StackTrace = exceptionDetails.Error.StackTrace;

            return View();
        }


       
    }
}
