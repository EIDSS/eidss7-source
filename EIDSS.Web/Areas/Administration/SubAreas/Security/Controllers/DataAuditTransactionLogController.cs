using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    [Controller]
    public class DataAuditTransactionLogController : BaseController
    {
        public IActionResult Index()
        {
            return View();
        }

        public DataAuditTransactionLogController(ILogger<DataAuditTransactionLogController> logger) : base(logger)
        {
        }
    }
}

