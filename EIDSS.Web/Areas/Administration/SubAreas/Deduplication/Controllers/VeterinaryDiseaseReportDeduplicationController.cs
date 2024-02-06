using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Deduplication.ViewModels.VeterinaryDiseaseReportDeduplication;
using EIDSS.Web.Areas.Veterinary.ViewModels.VeterinaryDiseaseReport;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Areas.Administration.SubAreas.Deduplication.Controllers
{
    [Area("Administration")]
    [SubArea("Deduplication")]
    [Controller]
    public class VeterinaryDiseaseReportDeduplicationController : BaseController
    {
        #region Constructors/Invocations

        public VeterinaryDiseaseReportDeduplicationController(
            ITokenService tokenService,
            ILogger<VeterinaryDiseaseReportDeduplicationController> logger) :
            base(logger, tokenService)
        {
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ShowSelectedRecordsIndicator"></param>
        /// <returns></returns>
        public IActionResult AvianDiseaseReportDeduplication(bool ShowSelectedRecordsIndicator = false)
        {
            SearchVeterinaryDiseaseReportPageViewModel model = new()
            {
                ReportType = VeterinaryReportTypeEnum.Avian,
                ShowSelectedRecordsIndicator = ShowSelectedRecordsIndicator
            };
            return View("Index", model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ShowSelectedRecordsIndicator"></param>
        /// <returns></returns>
        public IActionResult LivestockDiseaseReportDeduplication(bool ShowSelectedRecordsIndicator = false)
        {
            SearchVeterinaryDiseaseReportPageViewModel model = new()
            {
                ReportType = VeterinaryReportTypeEnum.Livestock,
                ShowSelectedRecordsIndicator = ShowSelectedRecordsIndicator
            };
            return View("Index", model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="veterinaryDiseaseReportID"></param>
        /// <param name="veterinaryDiseaseReportID2"></param>
        /// <param name="reportType"></param>
        /// <returns></returns>
        public IActionResult Details(long veterinaryDiseaseReportID, long veterinaryDiseaseReportID2, VeterinaryReportTypeEnum reportType)
        {
            var model = new VeterinaryDiseaseReportDeduplicationDetailsViewModel()
            {
                LeftVeterinaryDiseaseReportID = veterinaryDiseaseReportID,
                RightVeterinaryDiseaseReportID = veterinaryDiseaseReportID2,
                ReportType = reportType
                //InformationSection = new PersonDeduplicationInformationSectionViewModel(),
                //AddressSection = new PersonDeduplicationAddressSectionViewModel(),
                //EmploymentSection = new PersonDeduplicationEmploymentSectionViewModel()
            };

            return View(model);
        }
    }
}
