#region Usings

using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using Swashbuckle.AspNetCore.Annotations;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.Extensions.Caching.Memory;

#endregion

namespace EIDSS.Api.Controllers.Administration
{
    [Route("api/Administration/Organization")]
    [ApiController]
    public partial class OrganizationController : EIDSSControllerBase
    {
        #region Constructors

        public OrganizationController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        #endregion

        [HttpPost("GetOrganizationList")]
        [ProducesResponseType(typeof(List<OrganizationGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<OrganizationGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<OrganizationGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<OrganizationGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Organizations" })]
        public async Task<IActionResult> GetOrganizationList([FromBody] OrganizationGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<OrganizationGetListViewModel> results = null;
            
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.Page, request.PageSize, request.SortColumn, request.SortOrder, request.OrganizationKey, request.OrganizationID, request.AbbreviatedName, request.FullName, request.AccessoryCode, request.SiteID, request.AdministrativeLevelID, request.OrganizationTypeID, request.ShowForeignOrganizationsIndicator, null, cancellationToken },
                    MappedReturnType = typeof(List<OrganizationGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ORG_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<OrganizationGetListViewModel>;
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
        [HttpPost("GetAdvancedOrganizationList")]
        [ProducesResponseType(typeof(List<OrganizationAdvancedGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<OrganizationAdvancedGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<OrganizationAdvancedGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<OrganizationAdvancedGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Organizations" })]
        public async Task<IActionResult> GetAdvancedOrganizationList([FromBody] OrganizationAdvancedGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<OrganizationAdvancedGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LangID, request.SiteFlag, request.AccessoryCode, request.OrganizationTypeID, request.AdvancedSearch, request.RowStatus, request.LocationID, null, cancellationToken },
                    MappedReturnType = typeof(List<OrganizationAdvancedGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_LKUP_ORG_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<OrganizationAdvancedGetListViewModel>;
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

        [HttpGet("GetOrganizationDetail")]
        [ProducesResponseType(typeof(List<OrganizationGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<OrganizationGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<OrganizationGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<OrganizationGetDetailViewModel>), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Organizations" })]
        public async Task<IActionResult> GetOrganizationDetail(string languageID, long organizationID, CancellationToken cancellationToken = default)
        {
            List<OrganizationGetDetailViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { languageID, organizationID, null, cancellationToken },
                    MappedReturnType = typeof(List<OrganizationGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ORG_GETDetailResult>)
                };
                results = await _repository.Get(args) as List<OrganizationGetDetailViewModel>;
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

        [HttpPost("SaveOrganization")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Organizations" })]
        public async Task<IActionResult> SaveOrganization([FromBody] OrganizationSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] {
                        request, null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ORG_SETResult>)
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

        [HttpDelete("DeleteOrganization")]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Organizations" })]
        public async Task<IActionResult> DeleteOrganization(long organizationID, string auditUserName, CancellationToken cancellationToken = default)
        {
            List<APIPostResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { organizationID, auditUserName, null, cancellationToken },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ORG_DELResult>)
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

        [HttpPost("GetDepartmentList")]
        [ProducesResponseType(typeof(List<DepartmentGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<DepartmentGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Organizations" })]
        [ProducesResponseType(typeof(List<DepartmentGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<DepartmentGetListViewModel>), StatusCodes.Status404NotFound)]

        public async Task<IActionResult> GetDepartmentList([FromBody] DepartmentGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<DepartmentGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId,request.OrganizationID,request.DepartmentID,request.Page,request.PageSize,request.SortColumn,request.SortOrder,null,cancellationToken },
                    MappedReturnType = typeof(List<DepartmentGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_GBL_Department_GetListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<DepartmentGetListViewModel>;
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