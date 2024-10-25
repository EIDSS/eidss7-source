#region Usings

using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
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

#endregion

namespace EIDSS.Api.Controllers.Administration.Security
{
    [Route("api/Administration/Security/Site")]
    [ApiController]
    public partial class SiteController : EIDSSControllerBase
    {
        public SiteController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        /// <summary>
        /// Gets a site detail record.
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="siteId"></param>
        /// <param name="userId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpGet("GetSiteDetails")]
        [ProducesResponseType(typeof(List<SiteGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SiteGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SiteGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SiteGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<ActionResult> GetSiteDetails(string languageId, long siteId, long userId, CancellationToken cancellationToken = default)
        {
            List<SiteGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId,siteId, userId, null, cancellationToken },
                    MappedReturnType = typeof(List<SiteGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SITE_GETDetailResult>)
                };

                results = await _repository.Get(args) as List<SiteGetDetailViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetSiteList")]
        [ProducesResponseType(typeof(List<SiteGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SiteGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SiteGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SiteGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSiteList([FromBody] SiteGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SiteGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SiteID, request.EIDSSSiteID, request.SiteTypeID, request.SiteName, request.HASCSiteID, request.OrganizationID, request.AdministrativeLevelID, request.SiteGroupID, null, request.Page, request.PageSize, request.SortColumn, request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<SiteGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SITE_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SiteGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("GetSiteActorList")]
        [ProducesResponseType(typeof(List<SiteActorGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SiteActorGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SiteActorGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SiteActorGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSiteActorList([FromBody] SiteActorGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SiteActorGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.Page, request.PageSize, request.SortColumn, request.SortOrder, request.SiteID, null, cancellationToken },
                    MappedReturnType = typeof(List<SiteActorGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SITE_ACTOR_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SiteActorGetListViewModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
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
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpPost("SaveSite")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> SaveSite([FromBody] SiteSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SITE_SETResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Save(args) as List<APISaveResponseModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="siteId"></param>
        /// <param name="auditUserName"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        [HttpDelete("DeleteSite")]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> DeleteSite(long siteId, string auditUserName, CancellationToken cancellationToken = default)
        {
            List<APIPostResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { siteId, auditUserName, null, cancellationToken },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_SITE_DELResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Delete(args) as List<APIPostResponseModel>;
            }
            catch (Exception ex) when (ex is TaskCanceledException or OperationCanceledException)
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