using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.Areas.Human.ViewModels.Person;
using EIDSS.Web.Controllers.Human;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class PersonController : BaseController
    {
        #region Global Values

        PersonSearchPageViewModel _personSearchPageViewModel;

        #endregion

        #region Constructors
        public PersonController(ITokenService tokenService, ILogger<PersonSearchPageController> logger) : base(logger, tokenService)
        {

        }

        #endregion

        #region Search Person

        public IActionResult Index()
        {
            _personSearchPageViewModel = new PersonSearchPageViewModel();

            //_personSearchPageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            //_personSearchPageViewModel.Select2Configurations = new List<Select2Configruation>();
            //_personSearchPageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            return View(_personSearchPageViewModel);
        }

        #endregion

        #region Person Details

        /// <summary>
        /// 
        /// </summary>
        /// <param name="id"></param>
        /// <param name="isReview"></param>
        /// <returns></returns>
        public IActionResult Details(long? id, bool isReview = false)
        {
            PersonDetailsViewModel model = new();
            model.HumanMasterID = id;
            model.IsReview = isReview;

            return View(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public IActionResult DetailsReviewPage(long id,int reviewPageNo)
        {
            PersonDetailsViewModel model = new();
            model.HumanMasterID = id;
            model.StartIndex = reviewPageNo;
            model.IsReview = true;

            return View("Details", model);
        }

        #endregion
    }
}

