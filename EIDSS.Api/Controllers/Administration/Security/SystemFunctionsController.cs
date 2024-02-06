using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration.Security;
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
    [Route("api/Administration/Security/SystemFunctions")]
    [ApiController]
    public class SystemFunctionsController : EIDSSControllerBase
    {
        public SystemFunctionsController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        [HttpPost("GetSystemFunctionsList")]
        [ProducesResponseType(typeof(List<SystemFunctionViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemFunctionViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemFunctionViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SystemFunctionViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSystemFunctionsList([FromBody] SystemFunctionsGetRequestModel request,  CancellationToken cancellationToken = default)
        {
            List<SystemFunctionViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.FunctionName,request.Page,request.PageSize,request.SortColumn,request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SYSTEMFUNCTION_GETLISTResult>)
                };
                results = await _repository.Get(args) as List<SystemFunctionViewModel>;
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


        [HttpPost("GetUserGroupAndUserList")]
        [ProducesResponseType(typeof(List<SystemFunctionUserGroupAndUserViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemFunctionUserGroupAndUserViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SystemFunctionUserGroupAndUserViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemFunctionUserGroupAndUserViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetUserGroupAndUserList(SystemFunctionsActorsGetRequestModel requestModel, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            List<SystemFunctionUserGroupAndUserViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { requestModel.LanguageId, requestModel.Id, requestModel.Name, 
                        requestModel.Page,requestModel.PageSize,requestModel.SortColumn,requestModel.SortOrder,requestModel.UserSiteID, 
                        requestModel.UserOrganizationID, requestModel.UserEmployeeID, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionUserGroupAndUserViewModel>),
                    RepoMethodReturnType = typeof(List<USP_Admin_UserGoupAndUser_GetListResult>)
                };
                results = await _repository.Get(args) as List<SystemFunctionUserGroupAndUserViewModel>;
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

        [HttpPost("GetSystemFunctionPermissionList")]
        [ProducesResponseType(typeof(List<SystemFunctionUserPermissionViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemFunctionUserPermissionViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SystemFunctionUserPermissionViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemFunctionUserPermissionViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSystemFunctionPermissionList(SystemFunctionPermissionGetRequestModel request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            List<SystemFunctionUserPermissionViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] {request.LanguageId, request.UserId,request.SystemFunctionId, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionUserPermissionViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SYSTEMFUNCTION_USERPERMISSION_GetListResult>)
                };
                results = await _repository.Get(args) as List<SystemFunctionUserPermissionViewModel>;
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

        [HttpPost("GetPersonAndEmployeeGroupList")]
        [ProducesResponseType(typeof(List<SystemFunctionPersonANDEmployeeGroupViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SystemFunctionPersonANDEmployeeGroupViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SystemFunctionPersonANDEmployeeGroupViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SystemFunctionPersonANDEmployeeGroupViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetPersonAndEmployeeGroupList(PersonAndEmployeeGroupGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SystemFunctionPersonANDEmployeeGroupViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.SystemFunctionId,request.LanguageId,request.Page,request.PageSize, 
                        request.SortColumn,request.SortOrder, request.ActorTypeID, request.ActorName, request.OrganizationName, request.Description,
                        request.UserSiteID, request.UserOrganizationID, request.UserEmployeeID, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionPersonANDEmployeeGroupViewModel>),
                    RepoMethodReturnType = typeof(List<USP_Admin_SystemFunction_PersonANDEmployeeGroup_GetListResult>)
                };
                results = await _repository.Get(args) as List<SystemFunctionPersonANDEmployeeGroupViewModel>;
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


        [HttpPost("SaveSystemFunctionUserPermission")]
        [ProducesResponseType(typeof(SystemFunctionUserPermissionSaveResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(SystemFunctionUserPermissionSaveResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(SystemFunctionUserPermissionSaveResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(SystemFunctionUserPermissionSaveResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> SaveSystemFunctionUserPermission(SystemFunctionsUserPermissionsSetParams request, CancellationToken cancellationToken = default)
        {
            // This method was auto generated!
            List<SystemFunctionUserPermissionSaveResponseModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.rolesandfunctions, request.user, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionUserPermissionSaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SETResult>)
                };
                results = await _repository.Get(args) as List<SystemFunctionUserPermissionSaveResponseModel>;
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

        [HttpPost("DeleteSystemFunctionPersonAndEmployeeGroup")]
        [ProducesResponseType(typeof(SystemFunctionPersonANDEmployeeGroupDelResponseModel), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(SystemFunctionPersonANDEmployeeGroupDelResponseModel), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(SystemFunctionPersonANDEmployeeGroupDelResponseModel), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(SystemFunctionPersonANDEmployeeGroupDelResponseModel), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> DeleteSystemFunctionPersonAndEmployeeGroup(SystemFunctionsPersonAndEmpoyeeGroupDelRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SystemFunctionPersonANDEmployeeGroupDelResponseModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.SystemFunctionId, request.UserId, null, cancellationToken },
                    MappedReturnType = typeof(List<SystemFunctionPersonANDEmployeeGroupDelResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SYSTEMFUNCTION_PersonANDEmployeeGroup_DELResult>)
                };
                results = await _repository.Get(args) as List<SystemFunctionPersonANDEmployeeGroupDelResponseModel>;
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
