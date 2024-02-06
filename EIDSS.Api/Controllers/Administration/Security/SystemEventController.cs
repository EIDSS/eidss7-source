using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;

namespace EIDSS.Api.Controllers.Administration.Security
{
    [Route("api/Administration/Security/SystemEvent")]
    [ApiController]
    public class SystemEventController : EIDSSControllerBase
    {
        public SystemEventController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }


        [HttpPost("GetSystemEventLogList")]
        [ProducesResponseType(typeof(List<SystemEventLogGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemEventLogGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemEventLogGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SystemEventLogGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSystemEventLogList([FromBody] SystemEventLogGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SystemEventLogGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.UserId, request.FromDate, request.ToDate, request.EventTypeId,
                        request.Page, request.PageSize, request.SortColumn,request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemEventLogGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SYSTEMEVENT_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SystemEventLogGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
            {
                Log.Error("Process was cancelled.");
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
