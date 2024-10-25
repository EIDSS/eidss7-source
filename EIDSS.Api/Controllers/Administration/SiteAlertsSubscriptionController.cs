using EIDSS.Api.Abstracts;
using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
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

namespace EIDSS.Api.Controllers.Administration
{

    [Route("api/Administration/SiteAlertsSubscription")]
    [ApiController]
    public partial class SiteAlertsSubscriptionController : EIDSSControllerBase
    {
        public SiteAlertsSubscriptionController(IDataRepository repository, IMemoryCache memoryCache) : base(repository, memoryCache)
        {
        }

        [HttpPost("GetSiteAlertsSubscriptionList")]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status401Unauthorized)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Site Alert Subscription" })]
        //[SystemEventActionFilter(SystemEventEnum.DoesNotParticipate)]
        public async Task<IActionResult> GetSiteAlertsSubscriptionList([FromBody] EventSubscriptionGetRequestModel request, CancellationToken cancellationToken = default)
        {
            List<EventSubscriptionTypeModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.LanguageId,request.SiteAlertName, request.UserId, request.Page, request.PageSize, request.SortColumn, request.SortOrder, null, cancellationToken },
                    MappedReturnType = typeof(List<EventSubscriptionTypeModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_EVENT_SUBSCRIPTION_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<EventSubscriptionTypeModel>;
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

        [HttpPost("SaveSiteAlertSubscription")]
        [ProducesResponseType(typeof(List<SitelAlertsSubcriptionSaveResponseModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<SitelAlertsSubcriptionSaveResponseModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<SitelAlertsSubcriptionSaveResponseModel>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(List<SitelAlertsSubcriptionSaveResponseModel>), StatusCodes.Status404NotFound)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Site Alert Subscription" })]
        public async Task<IActionResult> SaveSiteAlertSubscription(SiteAlertEventSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            List<SitelAlertsSubcriptionSaveResponseModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();

                DataRepoArgs args = new()
                {
                    Args = new object[] { request.Subscriptions, request.UserName, null, cancellationToken },
                    MappedReturnType = typeof(List<SitelAlertsSubcriptionSaveResponseModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_EVENT_SUBSCRIPTION_SETResult>)
                };
                results = await _repository.Get(args) as List<SitelAlertsSubcriptionSaveResponseModel>;
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

        [HttpPost("GetNeighboringSiteList")]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status404NotFound)]
        [ProducesResponseType(typeof(List<EventSubscriptionTypeModel>), StatusCodes.Status400BadRequest)]
        [SwaggerOperation(Summary = "", Tags = new[] { "Administration - Neighboring Site List" })]
        //[SystemEventActionFilter(SystemEventEnum.DoesNotParticipate)]
        public async Task<IActionResult> GetNeighboringSiteList([FromBody] NeighboringSiteGetRequestModel request, CancellationToken cancellationToken = default)
        {

            List<NeighboringSiteListViewModel> results = null;
            try
            {
                //Handled in Global cancellation handler and logs that the request was handled
                cancellationToken.ThrowIfCancellationRequested();
                DataRepoArgs args = new()
                {
                    Args = new object[] { request.SiteID,null, cancellationToken },
                    MappedReturnType = typeof(List<NeighboringSiteListViewModel>),
                    RepoMethodReturnType = typeof(List<USP_ADMIN_NEIGHBORING_SITE_GETListResult>)
                };

                // Forwards the call to context method:  
                results = await _repository.Get(args) as List<NeighboringSiteListViewModel>;
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
    }
}


