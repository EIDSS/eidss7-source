using EIDSS.Api.ActionFilters;
using EIDSS.Api.Exceptions;
using EIDSS.Api.Extensions;
using EIDSS.Api.Integrations.PIN.Georgia;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Localization.Extensions;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.Repositories;
using EIDSS.Repository.ReturnModels;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.ResponseCaching;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Serilog;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq.Expressions;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Api.ControllerBehavior;
using EIDSS.Repository;
using EIDSS.Repository.Providers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace EIDSS.Api
{
    public class Startup
    {
        private readonly string _CORSPolicyName = "EIDSSCORSPolicy";

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
            Log.Logger = new LoggerConfiguration()
            .ReadFrom.Configuration(Configuration)
            .CreateLogger();
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddOptions();

            // Register options handler for connection strings section.  This is being used by the auditing infrastructure.
            services.Configure<ConnectionStringOptions>(Configuration.GetSection("ConnectionStrings"));

            // Register options handler for XSite section...
            services.Configure<XSiteConfigurationOptions>(Configuration.GetSection("XSite"));

            // Register db contexts...
            services.ConfigureContexts(Configuration);

            services.AddEIDSSLocalization(Configuration);

            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddHttpContextAccessor();
            // Inject Class mappings...
            services.ConfigureClassMappings();

            // Inject Repos...
            services.ConfigureRepositories();

            //Inject Services
            services.ConfigureServices();


            // Inject content negotiation...
            services.AddMvc(config =>
            {
                config.RespectBrowserAcceptHeader = true;
                config.EnableEndpointRouting = false;
                config.CacheProfiles.Add("Cache30", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 30, VaryByQueryKeys = new string[] {"*"}});
                config.CacheProfiles.Add("Cache60", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 60, VaryByQueryKeys = new string[] {"*"}});
                config.CacheProfiles.Add("Cache5Min", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 300, VaryByQueryKeys = new string[] {"*"}});
                config.CacheProfiles.Add("Cache10Min", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 600, VaryByQueryKeys = new string[] {"*"}});
                config.CacheProfiles.Add("CacheHour", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 3600, VaryByQueryKeys = new string[] {"*"}});
                config.CacheProfiles.Add("CacheInfini", new Microsoft.AspNetCore.Mvc.CacheProfile() { Duration = 31104000, VaryByQueryKeys = new string[] {"*"}});
            });


            //Add Configurations

            services.Configure<JwtTokenConfig>(Configuration.GetSection(JwtTokenConfig.JwtToken));

            // Register the XSITE context helper...
            services.AddScoped<IxSiteContextHelper, xSiteContextHelper>();

            // Hide API endpoints that don't need to be visible...
            services.AddControllers(o=>
            {
            });
            
            
            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.EnableAnnotations();
                c.OrderActionsBy((apiDesc) => apiDesc.RelativePath);

                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Version = "v1",
                    Title = "EIDSS API",
                    Description = "Electronic Integrated Disease Surveillance System Web API",

                    Contact = new OpenApiContact
                    {
                        Name = "",
                        Email = string.Empty
                    },
                    License = new OpenApiLicense
                    {
                        Name = "MIT License"
                    }
                });
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Type = SecuritySchemeType.Http,
                    BearerFormat = "JWT",
                    In = ParameterLocation.Header,
                    Scheme = "bearer",
                    Description = "Please insert JWT token into field"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        new string[] { }
                    }
                });


                // Set the comments path for the Swagger JSON and UI.
                var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
                var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
                c.IncludeXmlComments(xmlPath);
            });

            services.AddResponseCaching(options =>
            {
                options.UseCaseSensitivePaths = true;
            });

            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            })

            // Adding Jwt Bearer
            .AddJwtBearer(options =>
            {
                options.SaveToken = true;
                options.RequireHttpsMetadata = false;
                options.TokenValidationParameters = new TokenValidationParameters()
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    RequireExpirationTime = true,
                    ValidateIssuerSigningKey = true,
                    ValidAudience = Configuration["JwtToken:ValidAudience"],
                    ValidIssuer = Configuration["JwtToken:ValidIssuer"],
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["JwtToken:Secret"])),
                    ClockSkew= TimeSpan.Zero
                };
                options.Events = new JwtBearerEvents
                {
                    OnAuthenticationFailed = context =>
                    {
                        if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
                        {
                            context.Response.Headers.Add("Token-Expired", "true");
                        }
                        return Task.CompletedTask;
                    }
                };
            });

            services.AddSingleton<IPINMockDataService, PINMockDataService>();

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IOptions<IdentityOptions> identityOptions)
        {
            if (env.IsDevelopment() || env.EnvironmentName.ToLower() == "ajdevlocal")
            {
                app.UseDeveloperExceptionPage();
            }



            using (var serviceScope = app.ApplicationServices.CreateScope())
            {
                var context = serviceScope.ServiceProvider.GetService<EIDSSContextProcedures>();

                System.Threading.Tasks.Task<System.Collections.Generic.List<USP_SecurityConfiguration_GetResult>>
                    settings = context.USP_SecurityConfiguration_GetAsync();

                identityOptions.Value.Lockout.AllowedForNewUsers = true;
                identityOptions.Value.Lockout.MaxFailedAccessAttempts = settings.Result[0].LockoutThld.Value;
                identityOptions.Value.Lockout.DefaultLockoutTimeSpan =
                    TimeSpan.FromMinutes(settings.Result[0].LockoutDurationMinutes.Value);
                identityOptions.Value.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@._-";
                    
            }

            app.ConfigureExceptionMiddleware();

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            // using Serilog
            app.UseSerilogRequestLogging();
            app.UseRouting();

            //  UseCors must be called before UseResponseCaching...
            app.UseCors( _CORSPolicyName);

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

            app.UseAuthentication();
            app.UseAuthorization();
            
            // Register our middleware that adds the username to the log...
            app.UseMiddleware<LogUsernameExtension>();

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.),
            // specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.DisplayRequestDuration();
                c.DisplayOperationId();
                c.DocExpansion(Swashbuckle.AspNetCore.SwaggerUI.DocExpansion.None);
                c.EnableFilter();
                c.DefaultModelsExpandDepth(-1); // Disable swagger schemas at bottom

#if DEBUG
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "EIDSS API V1");
#else

                // if hosting in IIS we need the endpoint configured like this...
                // =================================================================
                c.SwaggerEndpoint("../swagger/v1/swagger.json", "EIDSS API V1");
#endif

            });
            app.UseHttpsRedirection();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });


        }

    }
}