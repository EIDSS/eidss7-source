using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using Microsoft.Extensions.Caching.Memory;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Api.Controllers.Administration
{
    [Route("api/Administration/Settlement")]
    [ApiController]
    public partial class SettlementController : EIDSSControllerBase
    {
        public SettlementController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }


        /// <summary>
        /// Retrieves a GetSettlmentTypeList
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetSettlementTypeList")]
        [ProducesResponseType(typeof(List<SettlementTypeModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SettlementTypeModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SettlementTypeModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<SettlementTypeModel>), StatusCodes.Status400BadRequest)]
        public async Task<ActionResult> GetSettlementTypeList(string languageId, CancellationToken cancellationToken = default)
        {

            List<SettlementTypeModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<SettlementTypeModel>),
                    RepoMethodReturnType = typeof(List<usp_SettlementType_GetLookupResult>)
                };

                results = await _repository.Get(args) as List<SettlementTypeModel>;

            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

        [HttpPost("SaveSettlementType")]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(APISaveResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Base Reference Editors" })]
        public async Task<IActionResult> SaveSettlementType([FromBody] SettlementTypeSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            APISaveResponseModel results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<usp_SettlementType_SetResult>)
                };

                // Forwards the call to context method:  
                var _ = await _repository.Save(args) as List<APISaveResponseModel>;

                if (_ != null)
                    results = _.FirstOrDefault();
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled");
            }
            catch (Exception ex)
            {
                Log.Error(ex.Message);
                throw;
            }

            return Ok(results);
        }

    }
}
