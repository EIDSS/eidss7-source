using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.Web.Areas.Human.Person.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.Abstracts;
using Microsoft.Extensions.Logging;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;

namespace EIDSS.Web.Controllers.Human
{
    [Area("Human")]
    [Controller]
    public class PersonSearchPageController : BaseController
    {
        //PersonSearchPageViewModel _personSearchPageViewModel;

        public PersonSearchPageController( ITokenService tokenService, ILogger<PersonSearchPageController> logger) : base(logger, tokenService)
        {

        }

        public async Task<IActionResult> Index()
        {
            //MJK - view model generated inside blazor component now
            //_personSearchPageViewModel = new PersonSearchPageViewModel();

            //_personSearchPageViewModel.eidssGridConfiguration = new EIDSSGridConfiguration();
            //_personSearchPageViewModel.Select2Configurations = new List<Select2Configruation>();
            //_personSearchPageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            //return View(_personSearchPageViewModel);
            return View();
        }
    }
}
