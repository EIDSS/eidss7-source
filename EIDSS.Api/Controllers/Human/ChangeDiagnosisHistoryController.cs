using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Repository.Interfaces;
using MapsterMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Api.Controllers.Human;

[Route("api/Human/ChangeDiagnosisHistory")]
[ApiController]
[Authorize]
[Tags("Human")]
public class ChangeDiagnosisHistoryController(
    ITlbChangeDiagnosisHistoryRepository tlbChangeDiagnosisHistoryRepository,
    IMapper mapper) : ControllerBase
{
    private readonly ITlbChangeDiagnosisHistoryRepository _tlbChangeDiagnosisHistoryRepository = tlbChangeDiagnosisHistoryRepository;
    private readonly IMapper _mapper = mapper;

    [HttpGet("GetChangeDiagnosisHistoryAsync")]
    public async Task<ActionResult<IEnumerable<ChangeDiagnosisHistoryResponseModel>>> GetChangeDiagnosisHistoryAsync(long humanCaseId, string languageIsoCode)
    {
        var history = await _tlbChangeDiagnosisHistoryRepository.GetChangeDiagnosisHistoryAsync(humanCaseId, languageIsoCode);
        var result = _mapper.Map<IEnumerable<ChangeDiagnosisHistoryResponseModel>>(history);
        return Ok(result);
    }
}
