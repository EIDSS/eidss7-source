using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Attributes;
using EIDSS.Localization.Extensions;
using EIDSS.Web.ActionFilters;
using EIDSS.Web.Extensions;
using EIDSS.Web.Helpers;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;
using System;
using System.Net;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.ResponseCaching;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Http.Connections;
using Microsoft.Extensions.Options;
using EIDSS.ClientLibrary.Events;

namespace EIDSS.Web
{
    public class Startup
    {
        public IWebHostEnvironment _env { get; }

        public Startup(IConfiguration configuration, IWebHostEnvironment env)
        {
            Configuration = configuration;
            _env = env;

            Log.Logger = new LoggerConfiguration()
                .ReadFrom.Configuration(Configuration)
                .CreateLogger();
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public virtual void ConfigureServices(IServiceCollection services)
        {
            services.AddEIDSSLocalization(Configuration);

            services.AddSingleton<RequestHandler>();

            //services.AddSingleton(typeof(Microsoft.Extensions.Logging.ILogger), logger);

            services.ConfigureApiClientExtensions();

            services.AddHttpContextAccessor();
            services.TryAddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            services.AddTransient<IApplicationContext, ApplicationContext>();

            services.AddSingleton<IConfiguration>(Configuration);

            services.AddScoped<ITokenService, TokenService>();

            services.AddSingleton<IValidationAttributeAdapterProvider, CustomValidationAttributeAdapterProvider>();

            services.AddScoped<LaboratoryStateContainerService>();

            services.AddScoped<ActiveSurveillanceSessionStateContainer>();
            services.AddScoped<VectorSessionStateContainer>();
            services.AddScoped<GridContainerServices>();
            services.AddScoped<HumanDiseaseReportSessionStateContainer>();
            services.AddScoped<AggregateDiseaseReportSummarySessionStateContainerService>();
            services.AddScoped<VeterinaryActiveSurveillanceSessionStateContainerService>();
            services.AddScoped<VeterinaryAggregateActionsReportStateContainer>();
            services.AddScoped<PersonDeduplicationSessionStateContainerService>();
            services.AddScoped<HumanDiseaseReportDeduplicationSessionStateContainerService>();
            services.AddScoped<FarmStateContainer>();
            services.AddScoped<PersonStateContainer>();
            services.AddScoped<FarmDeduplicationSessionStateContainerService>();
            services.AddScoped<UsersAndGroupsSessionStateContainerService>();
            services.AddScoped<VeterinaryDiseaseReportDeduplicationSessionStateContainerService>();

            services.AddScoped<LoginRedirectionAttribute>();
            services.AddScoped<CustomCookieAuthenticationEvents>();

            services.AddAuthentication("EidssCookie")
                .AddCookie("EidssCookie", options =>
                {
                    options.Cookie.Name = "__EidssCookie";
                    options.LoginPath = "/Administration/Admin/Login";
                    options.SlidingExpiration = true;
                    options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
                    options.LogoutPath = "/Administration/Admin/logout";
                    options.Cookie.HttpOnly = true;
                    options.Cookie.MaxAge = TimeSpan.FromMinutes(30);
                    options.Cookie.SameSite = SameSiteMode.Strict;
                    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
                    options.Cookie.Path = "/";
                    options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
                    //options.EventsType = typeof(CustomCookieAuthenticationEvents);
                });

            services.AddDataProtection()
                .SetApplicationName("Eidss")
                .AddKeyManagementOptions(options =>
                {
                    options.NewKeyLifetime = new TimeSpan(180, 0, 0, 0);
                    options.AutoGenerateKeys = true;
                });

            services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(30);
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
                options.Cookie.SameSite = SameSiteMode.Strict;
                options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
                options.Cookie.Name = "__EidssSession";
                options.Cookie.Path = "/";
            });

            services.Configure<RazorViewEngineOptions>(o =>
            {
                o.ViewLocationExpanders.Add(new SubAreaViewLocationExpander());
            });

            //Response caching...
            services.AddResponseCaching();

            //Blazor
            services.AddRazorPages();
            services.AddServerSideBlazor()
                .AddCircuitOptions(options =>
                    {
                        options.DetailedErrors = true;
                    })
                .AddHubOptions(options =>
                 {
                     options.MaximumReceiveMessageSize = 1024000000;
                     options.KeepAliveInterval = TimeSpan.FromMinutes(20);
                     options.ClientTimeoutInterval = TimeSpan.FromMinutes(20);
                     options.HandshakeTimeout = TimeSpan.FromMinutes(20);
                 });

            services.AddControllersWithViews();

            //Configuration
            services.Configure<EidssApiOptions>(Configuration.GetSection(EidssApiOptions.EidssApi));
            services.Configure<EidssApiConfigurationOptions>(Configuration.GetSection(EidssApiConfigurationOptions.EidssApiConfiguration));
            services.Configure<ProtectedConfigurationSettings>(
                Configuration.GetSection(ProtectedConfigurationSettings.ProtectedConfigurationSection));
            services.AddMemoryCache();

            services.AddMvc(options =>
                {
                    options.EnableEndpointRouting = false;
                    options.CacheProfiles.Add("Cache30", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 30, VaryByQueryKeys = new string[] { "*" } });
                    options.CacheProfiles.Add("Cache60", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 60, VaryByQueryKeys = new string[] { "*" } });
                    options.CacheProfiles.Add("Cache5Min", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 300, VaryByQueryKeys = new string[] { "*" } });
                    options.CacheProfiles.Add("Cache10Min", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 600, VaryByQueryKeys = new string[] { "*" } });
                    options.CacheProfiles.Add("CacheHour", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 3600, VaryByQueryKeys = new string[] { "*" } });
                    options.CacheProfiles.Add("CacheInfini", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 31104000, VaryByQueryKeys = new string[] { "*" } });
                }).AddViewLocalization();
            services.AddTransient<IAppVersionService, AppVersionService>();

            // Configuration service.  This service replaces the ConfigFactory.
            services.AddSingleton<IUserConfigurationService, UserConfigurationService>();

            services.AddScoped<TimeZoneService>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILoggerFactory loggerFactory)
        {
            if (env.IsEnvironment("Development") || env.IsEnvironment("QA-GG Local Debug") ||
                env.IsEnvironment("QA-AJ Local Debug") || env.IsEnvironment("AJDEVLocal"))
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                app.UseStatusCodePagesWithRedirects("/Error/{0}");
            }

            //if (env.IsDevelopment())
            //{
            //    app.UseDeveloperExceptionPage();
            //}
            //else
            //{
            //    app.UseExceptionHandler("/Error");
            //    app.UseStatusCodePagesWithRedirects("/Error/{0}");
            //}

            app.UseEIDSSLocalization();

            app.UseStaticFiles();

            app.UseRouting();

            //var cookiePolicyOptions = new CookiePolicyOptions
            //{
            //    MinimumSameSitePolicy = SameSiteMode.Strict,
            //    HttpOnly = Microsoft.AspNetCore.CookiePolicy.HttpOnlyPolicy.Always,
            //    Secure = CookieSecurePolicy.None,
            //};

            app.UseAuthentication();

            app.UseStatusCodePages(context =>
            {
                var response = context.HttpContext.Response;
                Log.Information($"Response Status {response.StatusCode}");
                if (response.StatusCode == (int)HttpStatusCode.Unauthorized ||
                    response.StatusCode == (int)HttpStatusCode.Forbidden)
                    response.Redirect("/Administration/Admin/Login");
                return Task.CompletedTask;
            });

            app.UseAuthorization();

            app.UseCookiePolicy();

            app.UseSession();

            //ApplicationContext.Configure(app.ApplicationServices.GetRequiredService<IHttpContextAccessor>());

            // using Serilog
            app.UseSerilogRequestLogging();

            // Response caching...
            app.UseResponseCaching();
            app.Use(async (context, next) =>
            {
                context.Response.GetTypedHeaders().CacheControl =
                    new Microsoft.Net.Http.Headers.CacheControlHeaderValue()
                    {
                        Public = true,
                        NoStore = true
                    };

                var responseCachingFeature = context.Features.Get<IResponseCachingFeature>();

                if (responseCachingFeature != null)
                {
                    responseCachingFeature.VaryByQueryKeys = new[] { "*" };
                }

                context.Response.Headers[Microsoft.Net.Http.Headers.HeaderNames.Vary] =
                    new string[] { "Accept-Encoding" };

                await next();
            });

            app.Use(async (context, next) =>
            {
                var routeData = context.GetRouteData();
                var tenant = routeData?.Values["menuId"]?.ToString();
                if (!string.IsNullOrEmpty(tenant))
                    context.Items["menuId"] = tenant;

                await next();
            });

            //Blazor
            app.UseEndpoints(endpoints =>
            {
                //endpoints.MapRazorPages();
                endpoints.MapControllerRoute("subarearoute", "{area:exists}/{subarea:exists}/{controller=Home}/{action=Index}/{id?}");
                endpoints.MapControllerRoute("areaRoute", "{area:exists}/{controller=Home}/{action=Index}/{id?}");
                endpoints.MapControllerRoute("default", "{controller=Home}/{action=Index}/{id?}");
                endpoints.MapBlazorHub(options =>
                    {
                        options.WebSockets.CloseTimeout = new TimeSpan(0, 20, 0);
                       // options.Transports = HttpTransportType.LongPolling;
                    });
            });
        }
    }
}