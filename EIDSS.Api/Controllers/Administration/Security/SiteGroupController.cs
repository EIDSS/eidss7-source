#region Using Statements

using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
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
    [Route("api/Administration/Security/SiteGroup")]
    [ApiController]
    public class SiteGroupController : EIDSSControllerBase
    {
        #region Constructors

        public SiteGroupController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        #endregion

        /// <summary>
        /// Retrieves a site group detail record. 
        /// </summary>
        /// <returns></returns>
        [HttpGet("GetSiteGroupDetails")]
        [ProducesResponseType(typeof(List<SiteGroupGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SiteGroupGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SiteGroupGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SiteGroupGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<ActionResult> GetSiteGroupDetails(string languageId, long siteGroupID, CancellationToken cancellationToken = default)
        {
            List<SiteGroupGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { languageId, siteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<SiteGroupGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_SITE_GROUP_GETDetailResult>)
                };

                results = await _repository.Get(args) as List<SiteGroupGetDetailViewModel>;
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

        [HttpPost("GetSiteGroupList")]
        [ProducesResponseType(typeof(List<SiteGroupGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SiteGroupGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SiteGroupGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SiteGroupGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetSiteGroupList([FromBody] SiteGroupGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SiteGroupGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.SiteGroupTypeID, request.SiteGroupName, request.AdministrativeLevelID, request.CentralSiteID, request.SiteID, request.EIDSSSiteID, request.Page, request.PageSize, request.SortColumn, request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<SiteGroupGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_SITE_GROUP_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<SiteGroupGetListViewModel>;
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

        [HttpPost("SaveSiteGroup")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> SaveSiteGroup([FromBody] SiteGroupSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request.LanguageID,
                        request.SiteGroupDetails.SiteGroupID,
                        request.SiteGroupDetails.LocationID,
                        request.SiteGroupDetails.SiteGroupName,
                        request.SiteGroupDetails.SiteGroupTypeID,
                        request.SiteGroupDetails.CentralSiteID,
                        request.SiteGroupDetails.SiteGroupDescription,
                        request.SiteGroupDetails.RowStatus,
                        request.AuditUserName,
                        request.Sites,
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_SITE_GROUP_SETResult>)
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

        [HttpDelete("DeleteSiteGroup")]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> DeleteSiteGroup(long siteGroupID, CancellationToken cancellationToken = default)
        {
            List<APIPostResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { siteGroupID, null, cancellationToken },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_SITE_GROUP_DELResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Delete(args) as List<APIPostResponseModel>;
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