using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using EIDSS.Domain.ResponseModels;
using Microsoft.AspNetCore.Http;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Repository.ReturnModels;
using Serilog;
using System;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;
using EIDSS.Domain.ResponseModels.Human;

namespace EIDSS.Api.Controllers.Human
{
    [Route("api/Human/HumanDiseaseReport")]
    [ApiController]
    [Tags("Human")]
    public partial class HumanDiseaseReportController : EIDSSControllerBase
    {
        public HumanDiseaseReportController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }
        
        [HttpPost("GetHumanDiseaseReportDetailAsync")]
        public async Task<ActionResult<USP_HUM_DISEASE_GETDetailResult>> GetHumanDiseaseReportDetailAsync([FromBody] HumanDiseaseReportDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            var result = await ExecuteOnRepository<USP_HUM_DISEASE_GETDetailResult, HumanDiseaseReportDetailViewModel>(args);
            return Ok(result.FirstOrDefault());
        }
        
        [HttpPost("GetHumanDiseaseReportListAsync")]
        public async Task<ActionResult<List<HumanDiseaseReportViewModel>>> GetHumanDiseaseReportListAsync([FromBody] HumanDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            var results = await ExecuteOnRepository<USP_HUM_DISEASE_REPORT_GETListResult, HumanDiseaseReportViewModel>(args);
            return results;
        }
        
        [HttpPost("GetHumanDiseaseReportPersonInfoAsync")]
        [SwaggerOperation(Summary ="",Tags = new[] { "Human Disease Report" })]
        public async Task<ActionResult<List<DiseaseReportPersonalInformationViewModel>>> GetHumanDiseaseReportPersonInfoAsync([FromBody] HumanPersonDetailsRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            var result = await ExecuteOnRepository<USP_HUM_HUMAN_MASTER_GETDetailResult, DiseaseReportPersonalInformationViewModel>(args);
            return result;
        }

        [HttpPost("SetHumanDiseaseReportAsync")]
        [SwaggerOperation(Summary = "", Tags = new[] { "Human Disease Report" })]
        public async Task<ActionResult<List<SetHumanDiseaseReportResponseModel>>> SetHumanDiseaseReportAsync([FromBody] HumanSetDiseaseReportRequestModel request, CancellationToken cancellationToken = default)
        {
            var args = new object[] { request, null, cancellationToken };
            var result = await ExecuteOnRepository<USP_HUM_HUMAN_DISEASE_SETResult, SetHumanDiseaseReportResponseModel>(args);
            return result;
        }
    }
}
