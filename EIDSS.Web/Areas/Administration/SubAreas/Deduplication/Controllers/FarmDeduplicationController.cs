using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.FarmDeduplication;
using EIDSS.Web.Areas.Veterinary.ViewModels.Farm;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Administration.SubAreas.Deduplication.Controllers
{
    [Area("Administration")]
    [SubArea("Deduplication")]
    [Controller]
    public class FarmDeduplicationController : BaseController
    {

        #region Constructors/Invocations

        public FarmDeduplicationController(
            ITokenService tokenService,
            ILogger<FarmDeduplicationController> logger) :
            base(logger, tokenService)
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        #endregion
        public IActionResult Index(bool showSelectedRecordsIndicator = false)
        {
            SearchFarmPageViewModel model = new SearchFarmPageViewModel();
            model.ShowSelectedRecordsIndicator = showSelectedRecordsIndicator;
            return View(model);
        }

        public IActionResult Details(long farmMasterID, long farmMasterID2)
        {
            FarmDeduplicationDetailsViewModel model = new FarmDeduplicationDetailsViewModel()
            {
                LeftFarmMasterID = farmMasterID,
                RightFarmMasterID = farmMasterID2,
                //InformationSection = new PersonDeduplicationInformationSectionViewModel(),
                //AddressSection = new PersonDeduplicationAddressSectionViewModel(),
                //EmploymentSection = new PersonDeduplicationEmploymentSectionViewModel()
            };

            return View(model);
        }
    }
}
