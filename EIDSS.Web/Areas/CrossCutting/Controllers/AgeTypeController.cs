using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [Area("CrossCutting")]
    [Controller]
    public class AgeTypeController : BaseController
    {
        private readonly IAgeTypeClient _ageTypeClient;

        public AgeTypeController(
            IAgeTypeClient ageTypeClient,
            ILogger<AgeTypeController> logger,
            ITokenService tokenService)
            : base(logger, tokenService)
        {
            _ageTypeClient = ageTypeClient;
        }

        [HttpGet("CrossCutting/AgeType/GetAgeTypesAsync")]
        public async Task<JsonResult> GetAgeTypesAsync(string term)
        {
            try
            {
                var request = new GetAgeTypesRequestModel
                {
                    LanguageIsoCode = GetCurrentLanguage(),
                    AdvancedSearch = term,
                    ExcludeIds = new[] { (long)HumanAgeType.Weeks }
                };

                var list = await _ageTypeClient.GetAgeTypesAsync(request);

                var result = new Select2DataResults
                {
                    results = list.Select(x => new Select2DataItem
                    {
                        id = x.Id.ToString(),
                        text = x.Text
                    }).ToList()
                };

                return Json(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        [HttpGet]
        [Route("CrossCutting/AgeType/GetCalculatedAgeAndAgeTypeAsync")]
        public IActionResult GetCalculatedAgeAndAgeTypeAsync(DateTime dateOfBirth, DateTime D)
        {
            try
            {
                int age = 0;
                long ageType = 0;
                var result = AgeCalculationHelper.GetDOBandAgeForPerson(dateOfBirth, D, ref age, ref ageType);

                if (result)
                    return Json(new { age = age, ageType = ageType });
                else
                    return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
