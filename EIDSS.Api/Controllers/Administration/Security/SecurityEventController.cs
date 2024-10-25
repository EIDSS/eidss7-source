using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;

namespace EIDSS.Api.Controllers.Administration.Security
{
    [Route("api/Administration/Security/SecurityEvent")]
    [ApiController]
    public class SecurityEventController : EIDSSControllerBase
    {
        public SecurityEventController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {

        }

        [HttpPost("GetSecurityEventLogList")]
        [ProducesResponseType(typeof(List<SecurityEventLogGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SecurityEventLogGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SecurityEventLogGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SecurityEventLogGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSecurityEventLogList([FromBody] SecurityEventLogGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SecurityEventLogGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.ActionStartDate, request.ActionEndDate, request.Action, request.ProcessType,
                        request.ResultType, request.ObjectId, request.UserId,request.ErrorText,request.ProcessId,request.Description,
                        request.SortColumn, request.SortOrder, request.Page, request.PageSize, null, cancellationToken },
                    MappedReturnType = typeof(List<SecurityEventLogGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_SecurityEventLog_GetListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SecurityEventLogGetListViewModel>;
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

        [AllowAnonymous]
        [HttpPost("SaveSecurityEventLog")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> SaveSecurityEventLog([FromBody] SecurityEventLogSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request.IdfUserId,
                        request.IdfsAction,
                        request.ResultFlag,
                        request.StrErrorText,
                        request.StrDescription,
                        request.IdfObjectId,
                        request.IdfsProcessType,
                        request.IdfSiteId,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_LogSecurityEvent_SETResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Save(args) as List<APISaveResponseModel>;
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

            return Ok(results.FirstOrDefault());
        }

    }
}
