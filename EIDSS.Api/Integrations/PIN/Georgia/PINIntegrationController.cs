using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Security;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.PIN;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Swashbuckle.AspNetCore.Annotations;

namespace EIDSS.Api.Integrations.PIN.Georgia
{
    /// <summary>
    /// This controller mocks the production API in country.  It is not intended for production use and is only used
    /// for development and testing.
    /// </summary>
    [Route("api/PIN")]
    [Authorize]
    [ApiController]
    public class PINIntegrationController : ControllerBase
    {
        private ILogger _logger;


        public PINIntegrationController(ILogger<PINIntegrationController> logger)
        {
            _logger = logger;
        }

        [AllowAnonymous]
        [HttpGet("Login")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "Georgia PIN System Login", Tags = new[] { "Georgia PIN System" })]
        public async Task<IActionResult>Login(string loginName, string password, [FromHeader] string LoginToken = null)
        {
            return Ok(Guid.NewGuid().ToString());
        }

        [HttpGet("GetPersonData")]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(PersonalDataModel), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "Georgia PIN System Get Person Data", Tags = new[] {"Georgia PIN System"}) ]
        public async Task<IActionResult> GetPersonData(string personalID, string birthYear, [FromHeader] string LoginToken,
            [FromServices] IPINMockDataService pinmockdataService)
        {
            var ret = pinmockdataService.GetDataModel(personalID, birthYear);
            if (ret == null)
            {
                ret = new PersonalDataModel();
                return NoContent();
            }
            return Ok(ret);
        }

    }


    /// <summary>
    /// This data collection exists to mimic inputs passed to the real testing API at the MOH.
    /// </summary>
    internal class PINGetDataResponse
    {
        public string PersonalID { get; set; }
        public string Year { get; set; }
        public PersonalDataModel PersonalDataModel { get; set; } = new();
    }


}
