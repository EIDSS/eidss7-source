using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
    [Controller]
    public class VeterinaryAggregateActionSummaryController : BaseController
    {
        #region Constructors/Invocations

        public VeterinaryAggregateActionSummaryController(
            ITokenService tokenService,
            ILogger<VeterinaryAggregateActionSummaryController> logger) :
            base(logger, tokenService)
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        #endregion
        public IActionResult Index()
        {
            return View();
        }
    }
}
