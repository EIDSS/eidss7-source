using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class HumanAggregateDiseasesReportSummaryController : BaseController
    {
        #region Global Values

        #endregion

        #region Constructors/Invocations

        public HumanAggregateDiseasesReportSummaryController(
            ITokenService tokenService,
            ILogger<HumanAggregateDiseasesReportSummaryController> logger) :
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
