using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.ViewModels;
using EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm;
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
    public class WeeklyReportingFormController : BaseController
    {
        #region Global Values
        private readonly IWeeklyReportingFormClient _weeklyReportFormClient;

        private readonly IOrganizationClient _organizationClient;
        #endregion

        public WeeklyReportingFormController(IWeeklyReportingFormClient weeklyReportFormClient,ITokenService tokenService, ILogger<WeeklyReportingFormController> logger) : base(logger, tokenService)
        {
            _weeklyReportFormClient = weeklyReportFormClient;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        public IActionResult Index()
        {
            return View();
        }

        #region WeeklyReportingForm Details

        ///// <summary>
        ///// id
        ///// </summary>
        ///// <param name="id"></param>
        ///// <returns></returns>
        //public  IActionResult Details(long? id)
        //{
          
        //    WeeklyReportingFormDetailsViewModel model = new()
        //    {
        //        WeeklyReportFormId = id,
        //        WeeklyReportingFormDetailsSectionViewModel = new()
        //        {
                   
        //        }
        //    };

        //    return View(model);
        //}

        public IActionResult Details(long? formID, bool isReadOnly = false)
        {
            WeeklyReportingFormDetailsViewModel model = new();
            model.FormID = formID;
            model.IsReadonly = isReadOnly;
            return View(model);
        }

        public IActionResult Add()
        {
            WeeklyReportingFormDetailsViewModel model = new();
            model.WeeklyReportFormId = null;
            model.WeeklyReportingFormDetailsSectionViewModel = new();
            model.IsReadonly = false;
            return View("Details", model);
        }

        #endregion
       
    }
}
