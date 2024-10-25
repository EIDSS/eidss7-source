using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.ActionFilters
{
    public class OperationCancelledExceptionFilter : ExceptionFilterAttribute
    {
        public OperationCancelledExceptionFilter()
        {
        }
        public override void OnException(ExceptionContext context)
        {
            if (context.Exception is OperationCanceledException)
            {
                Log.Information("Request was cancelled");
                context.ExceptionHandled = false;
                context.Result = new StatusCodeResult(400);
            }
        }
    }
}
