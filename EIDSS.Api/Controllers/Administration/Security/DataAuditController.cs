using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration;
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
    [Route("api/Administration/Security/DataAudit")]
    [ApiController]
    public class DataAuditController : EIDSSControllerBase
    {
        public DataAuditController(IDataRepository genericRepository, IMemoryCache memoryCache) : base(genericRepository, memoryCache)
        {
        }

        [HttpPost("GetTransactionLog")]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetTransactionLog([FromBody] DataAuditLogGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<DataAuditTransactionLogGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.StartDate, request.EndDate, request.IdfUserId, request.IdfSiteId, request.IdfActionId, request.IdfObjetType, request.IdfObjectId, request.SortColumn, request.SortOrder, request.Page, request.PageSize, null, cancellationToken },
                    MappedReturnType = typeof(List<DataAuditTransactionLogGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_DATAAUDITLOG_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<DataAuditTransactionLogGetListViewModel>;
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

        /// <summary>
        /// Retrieves a GetTransactionLogDetail 
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetTransactionLogDetailRecords")]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<DataAuditTransactionLogGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<ActionResult> GetTransactionLogDetailRecords(string languageId, long dataAuditEventId,  CancellationToken cancellationToken = default)
        {
            List<DataAuditTransactionLogGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { dataAuditEventId, languageId, null, cancellationToken },
                    MappedReturnType = typeof(List<DataAuditTransactionLogGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_DATAAUDITLOG_GETDetailResult>)
                };

                results = await _repository.Get(args) as List<DataAuditTransactionLogGetDetailViewModel>;
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

        [HttpPost("Restore")]
        [ProducesResponseType(typeof(List<DataAuditRestoreResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<DataAuditRestoreResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<DataAuditRestoreResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<DataAuditRestoreResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> Restore([FromBody] AuditRestoreRequestModel request, CancellationToken cancellationToken = default)
        {
            List<DataAuditRestoreResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        
                        request,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<DataAuditRestoreResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_DataAuditEvent_RestoreResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Save(args) as List<DataAuditRestoreResponseModel>;
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
