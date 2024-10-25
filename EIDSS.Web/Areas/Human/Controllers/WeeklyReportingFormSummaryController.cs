using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingSummary;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.Controllers
{

    [Area("Human")]
    [Controller]
    public class WeeklyReportingFormSummaryController : BaseController
    {
        public long  MinimumTimeInterval { get; set; }


        public WeeklyReportingFormSummaryController(
            ILogger<WeeklyReportingFormSummaryController> logger) :
            base(logger)
        {

            MinimumTimeInterval = (long)TimePeriodTypes.Month;
         
        }

        public IActionResult Index()
        {
            return View();
        }

    }
}
