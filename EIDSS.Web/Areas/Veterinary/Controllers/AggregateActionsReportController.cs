#region Usings

using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Veterinary.ViewModels.AggregateActionsReport;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

#endregion

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
    [Controller]
    public class AggregateActionsReportController : BaseController
    {
        public AggregateActionsReportController(ITokenService tokenService, ILogger<AggregateActionsReportController> logger) : base(logger, tokenService)
        {
        }

        /// <summary>
        /// </summary>
        /// <param name="refreshResultsIndicator"></param>
        /// <returns></returns>
        public IActionResult Index(bool refreshResultsIndicator = false)
        {
            SearchAggregateActionsReportPageViewModel model = new()
            {
                RefreshResultsIndicator = refreshResultsIndicator
            };
            return View("Index", model);
        }

        /// <summary>
        /// </summary>
        /// <param name="id"></param>
        /// <param name="isReadOnly"></param>
        /// <returns></returns>
        public IActionResult Details(long? id, bool isReadOnly = false)
        {
            var model = new AggregateActionsReportDetailPageViewModel
            {
                ReportKey = id,
                IsReadonly = isReadOnly
            };
            return View(model);
        }
    }
}