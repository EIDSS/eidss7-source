using EIDSS.Api.Helpers;
using EIDSS.Api.Models;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace EIDSS.Api.Exceptions
{
    public class ExceptionExtensions
    {
        private readonly RequestDelegate _next;
        public ExceptionExtensions(RequestDelegate next)
        {
            _next = next;
        }
        public async Task InvokeAsync(HttpContext httpContext)
        {
            try
            {
                await _next(httpContext);
            }
            catch (Exception ex)
            {
                Log.Error($"An error occurred in the api: Message {ex.Message}  - Stack Trace { ex.StackTrace}");
                await HandleExceptionAsync(httpContext, ex);
            }
        }
        private Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";

            switch (exception)
            {
                case AppException e:
                    // custom application error
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    break;
                case KeyNotFoundException e:
                    // not found error
                    context.Response.StatusCode = (int)HttpStatusCode.NotFound;
                    break;
                default:
                    // unhandled error
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    break;
            }
            return context.Response.WriteAsync(new ErrorDetails()
            {
                StatusCode = context.Response.StatusCode,
                Message = $"An error occurred in the api: {exception.Message}" 
            }.ToString()) ;
        }
    }
}