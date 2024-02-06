using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Serilog;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;

namespace EIDSS.Api.Controllers.Administration
{
    [Route("api/Administration/BaseReferenceEditor")]
    [ApiController]
    public partial class BaseReferenceEditorController : EIDSSControllerBase
    {
        public BaseReferenceEditorController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        [HttpPost("GetBaseReferenceList")]
        [ProducesResponseType(typeof(List<BaseReferenceEditorsViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<BaseReferenceEditorsViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<BaseReferenceEditorsViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<BaseReferenceEditorsViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Base Reference Editors" })]
        public async Task<IActionResult> GetBaseReferenceList([FromBody] BaseReferenceEditorGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<BaseReferenceEditorsViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request, null, cancellationToken },
                    MappedReturnType = typeof(List<BaseReferenceEditorsViewModel>),
                    RepoMethodReturnType = typeof(List<USP_REF_BASEREFERENCE_Filtered_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<BaseReferenceEditorsViewModel>;
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
