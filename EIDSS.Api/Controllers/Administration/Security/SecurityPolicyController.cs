using EIDSS.Api.Abstracts;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Api.Controllers.Administration.Security
{
    [Route("api/Administration/Security/SecurityPolicy")]
    [ApiController]
    public partial class SecurityPolicyController : EIDSSControllerBase
    {

        public SecurityPolicyController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }


        [HttpGet("GetSecurityPolicy")]
        [ProducesResponseType(typeof(SecurityConfigurationViewModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(SecurityConfigurationViewModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(SecurityConfigurationViewModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(SecurityConfigurationViewModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        //[SystemEventActionFilterAttribute(SystemEventEnum.DoesNotParticipate)]
        public async Task<IActionResult> GetSecurityPolicy(CancellationToken cancellationToken = default)
        {
            List<SecurityConfigurationViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {null, cancellationToken },
                    MappedReturnType = typeof(List<SecurityConfigurationViewModel>),
                    RepoMethodReturnType = typeof(List<USP_SecurityConfiguration_GetResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SecurityConfigurationViewModel>;
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

        [HttpPost("SaveSecurityPolicy")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> SaveSecurityPolicy([FromBody] SecurityPolicySaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request.Id,
                        request.MinPasswordLength,
                        request.EnforcePasswordHistoryCount,
                        request.MinPasswordAgeDays,
                        request.ForceUppercaseFlag,
                        request.ForceLowercaseFlag,
                        request.ForceNumberUsageFlag,
                        request.ForceSpecialCharactersFlag,
                        request.AllowUseOfSpaceFlag,
                        request.PreventSequentialCharacterFlag,
                        request.PreventUsernameUsageFlag,
                        request.LockoutThld,
                        request.MaxSessionLength,
                        request.SesnIdleTimeoutWarnThldMins,
                        request.SesnIdleCloseoutThldMins,
                        request.SesnInactivityTimeOutMins,
                        request.EventTypeId,
                        request.SiteId, 
                        request.UserId, 
                        request.LocationId, 
                        request.AuditUserName, 
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_SecurityConfiguration_SetResult>)
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
