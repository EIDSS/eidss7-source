using EIDSS.Api.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
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
    [Route("api/Administration/Security/ConfigurableFiltration")]
    [ApiController]
    public partial class ConfigurableFiltrationController : EIDSSControllerBase
    {
        public ConfigurableFiltrationController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        [HttpPost("GetAccessRuleList")]
        [ProducesResponseType(typeof(List<AccessRuleGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<AccessRuleGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<AccessRuleGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<AccessRuleGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetAccessRuleList([FromBody] AccessRuleGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<AccessRuleGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.Page, request.PageSize, request.SortColumn, request.SortOrder, request.AccessRuleID, request.AccessRuleName, request.BorderingAreaRuleIndicator, request.DefaultRuleIndicator, request.ReciprocalRuleIndicator, request.AccessToPersonalDataPermissionIndicator, request.AccessToGenderAndAgeDataPermissionIndicator, request.CreatePermissionIndicator, request.DeletePermissionIndicator, request.ReadPermissionIndicator, request.WritePermissionIndicator, request.GrantingActorSiteCode, request.GrantingActorSiteHASCCode, request.GrantingActorSiteName, request.GrantingActorAdministrativeLevelID, request.ReceivingActorSiteCode, request.ReceivingActorSiteHASCCode, request.ReceivingActorSiteName, request.ReceivingActorAdministrativeLevelID, request.GrantingActorSiteGroupID, request.GrantingActorSiteID, request.ReceivingActorSiteGroups, request.ReceivingActorSites, request.ReceivingActorUserGroups, request.ReceivingActorUsers, null, cancellationToken },
                    MappedReturnType = typeof(List<AccessRuleGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ACCESS_RULE_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<AccessRuleGetListViewModel>;
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

        [HttpGet("GetAccessRuleDetail")]
        [ProducesResponseType(typeof(List<AccessRuleGetDetailViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<AccessRuleGetDetailViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<AccessRuleGetDetailViewModel>), StatusCodes.Status400BadRequest)]       
        [ProducesResponseType(typeof(List<AccessRuleGetDetailViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetAccessRuleDetail(string languageID, long accessRuleID, CancellationToken cancellationToken = default)
        {
            List<AccessRuleGetDetailViewModel> results = null;
            
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { languageID, accessRuleID, null, cancellationToken },
                    MappedReturnType = typeof(List<AccessRuleGetDetailViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ACCESS_RULE_GETDetailResult>)
                };
                results = await _repository.Get(args) as List<AccessRuleGetDetailViewModel>;
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

        [HttpPost("GetAccessRuleActorList")]
        [ProducesResponseType(typeof(List<AccessRuleActorGetListViewModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<AccessRuleActorGetListViewModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<AccessRuleActorGetListViewModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<AccessRuleActorGetListViewModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> GetAccessRuleActorList([FromBody] AccessRuleActorGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<AccessRuleActorGetListViewModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId, request.Page, request.PageSize, request.SortColumn, request.SortOrder, request.AccessRuleID, request.SiteID, null, cancellationToken },
                    MappedReturnType = typeof(List<AccessRuleActorGetListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ACCESS_RULE_ACTOR_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<AccessRuleActorGetListViewModel>;
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

        [HttpPost("SaveAccessRule")]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APISaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> SaveAccessRule([FromBody] AccessRuleSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<APISaveResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.AccessRuleDetails.AccessRuleID, 
                        request.AccessRuleDetails.AccessRuleName, 
                        request.AccessRuleDetails.NationalValue, 
                        request.LanguageId, 
                        request.AccessRuleDetails.Order,
                        request.AccessRuleDetails.BorderingAreaRuleIndicator, 
                        request.AccessRuleDetails.DefaultRuleIndicator, 
                        request.AccessRuleDetails.ReciprocalRuleIndicator, 
                        request.AccessRuleDetails.GrantingActorSiteGroupID,
                        request.AccessRuleDetails.GrantingActorSiteID,
                        request.AccessRuleDetails.AccessToGenderAndAgeDataPermissionIndicator, 
                        request.AccessRuleDetails.AccessToPersonalDataPermissionIndicator, 
                        request.AccessRuleDetails.CreatePermissionIndicator,
                        request.AccessRuleDetails.DeletePermissionIndicator, 
                        request.AccessRuleDetails.ReadPermissionIndicator, 
                        request.AccessRuleDetails.WritePermissionIndicator,
                        request.AccessRuleDetails.AdministrativeLevelTypeID,
                        request.AccessRuleDetails.RowStatus, 
                        request.ReceivingActors,
                        request.User, 
                        null, cancellationToken },
                    MappedReturnType = typeof(List<APISaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_REF_AccessRule_SETResult>)
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

        [HttpDelete("DeleteAccessRule")]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<APIPostResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Security" })]
        public async Task<IActionResult> DeleteAccessRule(long accessRuleID, CancellationToken cancellationToken = default)
        {
            List<APIPostResponseModel> results = null;

            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { accessRuleID, null, cancellationToken },
                    MappedReturnType = typeof(List<APIPostResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_ACCESS_RULE_DELResult>)
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
