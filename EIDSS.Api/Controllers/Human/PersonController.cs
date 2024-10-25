using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

// Below usings are used in Generated Code
using EIDSS.Domain.ResponseModels;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;

namespace EIDSS.Api.Controllers.Human
{
    [Route("api/Human/Person")]
    [ApiController]
    [Tags("Human")]
    public partial class PersonController : EIDSSControllerBase
    {
        private readonly ITlbHumanActualRepository _tlbHumanActualRepository;

        public PersonController(
            ITlbHumanActualRepository tlbHumanActualRepository,
            IDataRepository dataRepository,
            IMemoryCache memoryCache)
            : base(dataRepository, memoryCache)
        {
            _tlbHumanActualRepository = tlbHumanActualRepository;
        }

        [HttpPost("SavePerson")]
        public async Task<ActionResult<PersonSaveResponseModel>> SavePerson([FromBody] PersonSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            var results = await ExecuteOnRepository<USP_HUM_HUMAN_MASTER_SETResult, PersonSaveResponseModel>(args);
            return results.FirstOrDefault();
        }

        [HttpPost("GetPersonListAsync")]
        public async Task<ActionResult<List<PersonViewModel>>> GetPersonListAsync([FromBody] HumanPersonSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            var results = await ExecuteOnRepository<USP_HUM_HUMAN_MASTER_GETListResult, PersonViewModel>(args);
            return results;
        }

        [HttpPost("UpdatePersonAsync")]
        public async Task<ActionResult<int>> UpdatePersonAsync([FromBody]UpdateHumanActualRequestModel request)
        {
            var result = await _tlbHumanActualRepository.UpdateAsync(request);
            return Ok(result);
        }
    }
}
