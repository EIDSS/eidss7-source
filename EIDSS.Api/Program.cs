using EIDSS.Repository;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api
{
    public class Program
    {

        static public IConfigurationRoot Configuration { get; set; }

        public static void Main(string[] args)
        {
            var host = CreateHostBuilder(args).Build();

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;

                var env = services.GetRequiredService<IWebHostEnvironment>();

                //Read Configuration from appSettings
                var config = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true)
                    .AddEnvironmentVariables()
                    .Build();

                var builder = CreateHostBuilder(args);

                try
                {
                    Log.Write(Serilog.Events.LogEventLevel.Information, "EIDSS Web API is starting");
                    builder.Build().Run();
                }
                catch (Exception ex)
                {
                    Log.Fatal(ex, "Application start-up failed");
                }
                finally
                {
                    Log.CloseAndFlush();
                }
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                }).ConfigureAppConfiguration((hostContext, builder) =>
                {

                    if (hostContext.HostingEnvironment.IsDevelopment() || hostContext.HostingEnvironment.IsEnvironment("AJDevLocal") || hostContext.HostingEnvironment.IsEnvironment("Perf"))
                    {
                        builder.AddUserSecrets<Program>();
                    }
                }).UseSerilog(); 
    }
}
