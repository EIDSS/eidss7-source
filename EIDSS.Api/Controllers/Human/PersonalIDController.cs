using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace EIDSS.Api.Controllers.Human
{
    [Route("api/Human/PersonalID")]
    [ApiController]
    [Tags(new[] { "Human" })]
    public class PersonalIDController : ControllerBase
    {
        private readonly ITlbHumanActualRepository _tlbHumanActualRepository;

        public PersonalIDController(ITlbHumanActualRepository tlbHumanActualRepository)
        {
            _tlbHumanActualRepository = tlbHumanActualRepository;
        }

        [HttpGet("IsPersonalIDExistsAsync")]
        public async Task<ActionResult<bool>> IsPersonalIDExistsAsync(string personalID, long? humanActualId)
        {
            if (string.IsNullOrEmpty(personalID))
            {
                return Ok(false);
            }

            var result = await _tlbHumanActualRepository.IsPersonIDExistsAsync(personalID, humanActualId);
            return Ok(result);
        }
    }
}
