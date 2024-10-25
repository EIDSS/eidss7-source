using EIDSS.CodeGenerator;
using EIDSS.Domain.RequestModels.Administration;
//using EIDSS.Infrastructure;
//using EIDSS.Infrastructure.ServiceChannels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Logging;
//using RabbitMQ.Client;
//using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Api.ActionFilters
{
    ///// <summary>
    ///// System event action filter that when decorated on an API method fires upon the successful completion of that method and inserts the associated event into the eventing tables
    ///// </summary>
    //public class SystemEventActionFilterAttribute : ResultFilterAttribute
    //{
    //    /// <summary>
    //    /// The event assocated with the call
    //    /// </summary>
    //    public readonly SystemEventEnum _eventParticipation;


    //    public SystemEventActionFilterAttribute(SystemEventEnum firesForEvent)
    //    {
    //        _eventParticipation = firesForEvent;
    //    }

    //    /// <summary>
    //    /// Called after the associated API completes.  This method calls the MQ service to insert the associated event if the API call produced a StatusCode 200.
    //    /// </summary>
    //    /// <param name="context"></param>
    //    public override void OnResultExecuted(ResultExecutedContext context)
    //    {
    //        // Get an ILogger instance...
    //        //var logger = (ILogger)context.HttpContext.RequestServices.GetService(typeof(ILogger));
    //        IEventService eventService = (IEventService)context.HttpContext.RequestServices.GetService(typeof(IEventService));

    //        SystemEventSaveRequestModel request;

    //        try
    //        {

    //            // If the call succeeded and the event's != DoesNotParticipate... 
    //            if (!context.Canceled && context.HttpContext.Response.StatusCode == 200 && this._eventParticipation != SystemEventEnum.DoesNotParticipate)
    //            {
                    
    //            }
    //        }
    //        catch (Exception ex)
    //        {
    //            //logger.LogError($"The following error occurred while attempting to log a system event: { ex.Message}");
    //        }

    //        base.OnResultExecuted(context);
    //    }


    //}

}
