using EIDSS.Api.Abstracts;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
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
    [Route("api/Administration/Security/UserGroup")]
    [ApiController]
    public partial class UserGroupController : EIDSSControllerBase
    {
        public UserGroupController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        //[HttpGet("GetUserGroupDetail")]
        //[ProducesResponseType(typeof(UserGroupDetailViewModel[]), StatusCodes.Status200OK)]
        //[ProducesResponseType(typeof(UserGroupDetailViewModel[]), StatusCodes.Status401Unauthorized)]
        //public async Task<IActionResult> GetUserGroupDetail(long? idfEmployeeGroup, string langId, string user, CancellationToken cancellationToken = default)
        //{
        //    // This method was auto generated!
        //    UserGroupDetailViewModel[] results = null;
        //    try
        //    {
        //        //Handled in Global cancellation handler and logs that the request was handled
        //        cancellationToken.ThrowIfCancellationRequested();

        //        DataRepoArgs args = new()
        //        {
        //            Args = new object[] { idfEmployeeGroup, langId, user, null, cancellationToken },
        //            MappedReturnType = typeof(UserGroupDetailViewModel[]),
        //            RepoMethodReturnType = typeof(USP_ADMIN_EMPLOYEEGROUP_GETDETAILResult[])
        //        };
        //        results = await _repository.Get(args) as UserGroupDetailViewModel[];
        //    }
        //    catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
        //    {
        //        Log.Error("Process was cancelled");
        //    }
        //    catch (Exception ex)
        //    {
        //        Log.Error(ex.Message);
        //        throw;
        //    }
        //    return Ok(results.FirstOrDefault());
        //}

        //[HttpPost("GetUserGroupList")]
        //[ProducesResponseType(typeof(UserGroupViewModel), StatusCodes.Status200OK)]
        //[ProducesResponseType(typeof(UserGroupViewModel), StatusCodes.Status401Unauthorized)]
        //public async Task<IActionResult> GetUserGroupList([FromBody] UserGroupGetRequestModel request, CancellationToken cancellationToken = default)
        //{
        //    // This method was auto generated!
        //    UserGroupViewModel[] results = null;
        //    try
        //    {
        //        //Handled in Global cancellation handler and logs that the request was handled
        //        cancellationToken.ThrowIfCancellationRequested();
        //        DataRepoArgs args = new()
        //        {
        //            Args = new object[] {request.strName, request.strDescription, request.LanguageId, request.user, request.Page, request.PageSize, request.SortColumn, request.SortOrder, null, cancellationToken },
        //            MappedReturnType = typeof(UserGroupViewModel[]),
        //            RepoMethodReturnType = typeof(USP_ADMIN_EMPLOYEEGROUP_GETLISTResult[])
        //        };

        //        // Forwards the call to context method:  
        //        var _ = await _repository.Get(args) as UserGroupViewModel[];

        //        if (_ != null && _.Length > 0)
        //            results = _;
        //    }
        //    catch (Exception ex) when (ex is TaskCanceledException || ex is OperationCanceledException)
        //    {
        //        Log.Error("Process was cancelled.");
        //    }
        //    catch (Exception ex)
        //    {
        //        Log.Error(ex.Message);
        //        throw;
        //    }

        //    return Ok(results);
        //}
    }
}
