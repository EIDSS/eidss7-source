using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Serilog.Context;

namespace EIDSS.Api.Extensions
{
    public class LogUsernameExtension
    {
        private readonly RequestDelegate next;

        public LogUsernameExtension(RequestDelegate next) { this.next = next; }

        public async Task Invoke(HttpContext context)
        {
            using (LogContext.PushProperty("UserName", context.User.Identity.Name ?? "anonymous"))
            {
                await next(context);
            }
        }
    }

}
