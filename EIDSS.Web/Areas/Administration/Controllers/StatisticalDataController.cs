using Microsoft.AspNetCore.Mvc;
using EIDSS.Web.ViewModels.Administration;
namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class StatisticalDataController : Controller
    {
        SearchStatisticalDataViewModel searchStatisticalDataViewModel;
        AddStatisticalDataViewModel addStatisticalDataViewModel;
        public IActionResult Index()
        {
            searchStatisticalDataViewModel = new SearchStatisticalDataViewModel();
            return View(searchStatisticalDataViewModel);
        }

      
        public IActionResult Add(long? id)
        {
            addStatisticalDataViewModel = new AddStatisticalDataViewModel();
            if (id != null)
            {
                addStatisticalDataViewModel.idfStatistic = id.Value;
            }
            return View(addStatisticalDataViewModel);
        }
    }
}
