using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Areas.Human.ViewModels.Human;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class HumanDiseaseReportDeduplicationController : BaseController
    {

        #region Constructors/Invocations

        public HumanDiseaseReportDeduplicationController(
            ITokenService tokenService,
            ILogger<HumanDiseaseReportDeduplicationController> logger) :
            base(logger, tokenService)
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        #endregion
        public IActionResult Index(bool showSelectedRecordsIndicator = false)
        {
            SearchHumanDiseaseReportPageViewModel model = new SearchHumanDiseaseReportPageViewModel();
            model.ShowSelectedRecordsIndicator = showSelectedRecordsIndicator;
            return View(model);
        }

        public IActionResult Details(long humanDiseaseReportID, long humanDiseaseReportID2)
        {
            HumanDiseaseReportDeduplicationDetailsViewModel model = new HumanDiseaseReportDeduplicationDetailsViewModel()
            {
                LeftHumanDiseaseReportID = humanDiseaseReportID,
                RightHumanDiseaseReportID = humanDiseaseReportID2,
                NotificationSection = new HumanDiseaseReportDeduplicationNotificationSectionViewModel(),
                SymptomsSection = new HumanDiseaseReportDeduplicationSymptomsSectionViewModel()
                //,
                //EmploymentSection = new PersonDeduplicationEmploymentSectionViewModel()
            };

            return View(model);
        }
    }
}
