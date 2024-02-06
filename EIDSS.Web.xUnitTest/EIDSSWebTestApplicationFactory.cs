using Castle.Core.Configuration;
using EIDSS.ClientLibrary.Services;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Hosting;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest
{
    /// <summary>
    /// Web application factory that provides integration test mechanism with a custom web host builder that uses the custom test 
    /// startup class.
    /// </summary>
    /// <typeparam name="TEntryPoint"></typeparam>
    public class EIDSSWebTestApplicationFactory<TStartup> : WebApplicationFactory<Startup> where TStartup : class
    {

        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
  
            base.ConfigureWebHost(builder);
        }
        protected override IHostBuilder CreateHostBuilder()
        {
            return Host.CreateDefaultBuilder().ConfigureWebHost((builder) =>
            {
                builder.UseStartup<TestStartup>();
            });
        }
    }
}
