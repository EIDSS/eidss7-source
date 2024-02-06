using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using System;
using System.IO;
using Microsoft.AspNetCore.Hosting.StaticWebAssets;

namespace EIDSS.Web
{
    public class Program
    {
        public static void Main(string[] args)
        {
            //CreateHostBuilder(args).Build().Run();
            var host = CreateHostBuilder(args).Build();

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                var env = services.GetRequiredService<IWebHostEnvironment>();

                var config = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true)
                    //.AddJsonFile("esettings.json", false, true)
                    //.AddJsonFile($"esettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true)
                    .AddEnvironmentVariables()
                    .Build();

                var builder = CreateHostBuilder(args);
                try
                {
                    builder.Build().Run();
                    //CreateHostBuilder(args).Build().Run();

                    Log.Write(Serilog.Events.LogEventLevel.Information, "EIDSS Web Site is starting");
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
            .ConfigureLogging(logging =>
            {
                //logging.AddSerilog();
            })
            .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();

                    webBuilder.ConfigureAppConfiguration((hostContext, builder) =>
                    {
                        // Add the encrypted settings json file...
                        builder.AddJsonFile("esettings.json", false, true);
                        builder.AddJsonFile($"esettings.{hostContext.HostingEnvironment.EnvironmentName}.json",
                            optional: true, reloadOnChange: true);

                        if (hostContext.HostingEnvironment.IsEnvironment("Development") ||
                            hostContext.HostingEnvironment.IsEnvironment("QA-GG Local Debug") ||
                            hostContext.HostingEnvironment.IsEnvironment("QA-AJ Local Debug") ||
                            hostContext.HostingEnvironment.IsEnvironment("AJDev") ||
                            hostContext.HostingEnvironment.IsEnvironment("AJDevLocal") ||
                            hostContext.HostingEnvironment.IsEnvironment("Perf"))
                        {
                            builder.AddUserSecrets<Program>();
                            builder.AddEnvironmentVariables();
                        }

                        if (!hostContext.HostingEnvironment.IsDevelopment())
                        {
                            // 👇 This call inserts "StaticWebAssetsFileProvider" into
                            //    the static file middleware.
                            StaticWebAssetsLoader.UseStaticWebAssets(
                                hostContext.HostingEnvironment,
                                hostContext.Configuration);
                        }
                    });

                }).UseSerilog();
    }
}