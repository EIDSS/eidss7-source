using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.PersonDeduplication;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Deduplication.Controllers
{
    [Area("Administration")]
    [SubArea("Deduplication")]
    [Controller]
    public class PersonDeduplicationController : BaseController
    {

        #region Constructors/Invocations

        public PersonDeduplicationController(
            ITokenService tokenService,
            ILogger<PersonDeduplicationController> logger) :
            base(logger, tokenService)
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        #endregion
        public IActionResult Index(bool showSelectedRecordsIndicator = false)
        {
            PersonSearchPageViewModel model = new PersonSearchPageViewModel();
            model.ShowSelectedRecordsIndicator = showSelectedRecordsIndicator;
            return View(model);
        }

        public IActionResult Details(long humanMasterID, long humanMasterID2)
        {
            PersonDeduplicationDetailsViewModel model = new PersonDeduplicationDetailsViewModel()
            {
                LeftHumanMasterID = humanMasterID,
                RightHumanMasterID = humanMasterID2,
                InformationSection = new PersonDeduplicationInformationSectionViewModel(),
                AddressSection = new PersonDeduplicationAddressSectionViewModel(),
                EmploymentSection = new PersonDeduplicationEmploymentSectionViewModel()
            };

            return View(model);
        }
    }
}
