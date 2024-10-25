using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Controllers.CrossCutting
{
    [Route("api/CrossCutting/AgeType")]
    [ApiController]
    [Tags(new[] { "Cross Cutting" })]
    public class AgeTypeController : ControllerBase
    {
        private readonly ITrtBaseReferenceRepository _trtBaseReferenceRepository;

        public AgeTypeController(ITrtBaseReferenceRepository trtBaseReferenceRepository)
        {
            _trtBaseReferenceRepository = trtBaseReferenceRepository;
        }

        [HttpPost("GetAgeTypesAsync")]
        public async Task<ActionResult<IEnumerable<AgeTypeResponseModel>>> GetAgeTypesAsync([FromBody] GetAgeTypesRequestModel request)
        {
            var result = (await _trtBaseReferenceRepository.GetAgeTypesAsync(
                request.LanguageIsoCode,
                request.AdvancedSearch,
                request.ExcludeIds))
                .Select(x => new AgeTypeResponseModel
                {
                    Id = x.IdfsBaseReference,
                    Text = x.StrDefault
                });
            return Ok(result);
        }
    }
}
