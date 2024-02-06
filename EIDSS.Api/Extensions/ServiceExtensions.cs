using EIDSS.Api.Providers;
using EIDSS.Repository;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.Repositories;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using EIDSS.Api.Provider;
using Mapster;
using MapsterMapper;
using EIDSS.Api.Helpers;
using EIDSS.Api.Integrations.PIN.Georgia;
using EIDSS.Repository.Providers;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.Hosting;
using Serilog;
using Serilog.Sinks.MSSqlServer;
using System.Diagnostics;
using Serilog.Enrichers;

namespace EIDSS.Api.Extensions
{
    /// <summary>
    /// Services that  inject auto mapped classes and data repositories
    /// </summary>
    public static class ServiceExtensions
    {
        /// <summary>
        /// Registers Mapster
        /// </summary>
        /// <param name="services"></param>
        public static void ConfigureClassMappings(this IServiceCollection services)
        {
            services.AddSingleton(MapsterMapping.ModelMappingConfiguration());
            services.AddSingleton(SecurityMappingProfile.SecurityMappingConfiguration());
            services.AddScoped<IMapper, ServiceMapper>();
        }

        /// <summary>
        /// Inject repositories scoped for controllers
        /// </summary>
        /// <param name="services"></param>
        public static void ConfigureRepositories(this IServiceCollection services)
        {

            services.AddSingleton<IModelProcessHelper, ModelProcessHelper>();
            
            services.AddScoped<IDataRepository, DataRepository>();

            // Register the context without using an interface...
            services.AddScoped<EIDSSContextProcedures, EIDSSContextProcedures>();

            services.AddSingleton<IModelPropertyMapper, ModelPropertyMapper>();

        }

        /// <summary>
        /// Inject repositories scoped for controllers
        /// </summary>
        /// <param name="services"></param>
        public static void ConfigureServices(this IServiceCollection services)
        {
            services.AddScoped<IPermissionService, PermissionService>();
            services.AddSingleton<IJwtAuthManager, JwtAuthManager>();
            services.AddHostedService<JwtRefreshTokenCache>();
        }

        /// <summary>
        /// Registers each context used by the application
        /// </summary>
        /// <param name="services"></param>
        /// <param name="config"></param>
        public static void ConfigureContexts(this IServiceCollection services, Microsoft.Extensions.Configuration.IConfiguration config)
        {

            var connectionOptions = new ConnectionStringOptions();
            var connectionstringssection = config.GetSection(ConnectionStringOptions.SectionName);


            #region Development User Secrets Initialization - EIDSS...

            // Each developer uses his/her own account for the EIDSS context in development...
            var ebuilder = new SqlConnectionStringBuilder(config.GetConnectionString("EIDSSConn"));
            var ebuilderArchive = new SqlConnectionStringBuilder(config.GetConnectionString("EIDSSArchiveConn"));
#if DEBUG
            // Get username/password from user secrets only if running locally...
            if (String.IsNullOrEmpty(ebuilder.UserID) && String.IsNullOrEmpty(ebuilder.Password))
            {
                ebuilder.UserID = config["User"];
                ebuilder.Password = config["DbPassword"];
                connectionstringssection["EIDSSConn"] = ebuilder.ConnectionString;

            }

            // Get username/password from user secrets only if running locally...
            if (String.IsNullOrEmpty(ebuilderArchive.UserID) && String.IsNullOrEmpty(ebuilderArchive.Password))
            {
                ebuilderArchive.UserID = config["ArchiveUser"];
                ebuilderArchive.Password = config["ArchiveDbPassword"];
                connectionstringssection["EIDSSArchiveConn"] = ebuilder.ConnectionString;
            }

#endif

#endregion

            // bind the connection strings section...
            connectionstringssection.Bind(connectionOptions); ;

            Dictionary<string, string> connStrs = new Dictionary<string, string>
            {
                {"EIDSS", ebuilder.ConnectionString},
                {"EIDSSARCHIVE", ebuilderArchive.ConnectionString}
            };

            DbContextFactory.SetConnectionString(connStrs, services);
            DbContextFactory.Connect("EIDSS");

            // Configure Serilog...
            // A flaw in serilog requires it to be loaded after the connection strings have been configured.
 
            // Problem:  Serilog doesn't work with user secrets.  When you assign a connection string to serilog
            // for logging to the DB, it uses it as is; so during development, if using user secrets to complete
            // the connection string, Serilog won't work because it knows nothing about the update to the connection string.

            // To get around this, we load it here.
            var sinkOpts = new MSSqlServerSinkOptions();
            sinkOpts.TableName = "tauApplicationEventLog";
            sinkOpts.AutoCreateSqlTable = false;

            Log.Logger = new LoggerConfiguration()
                .Enrich.WithMachineName()
                .Enrich.WithProcessName()
                .Enrich.WithThreadName()
                .Enrich.FromLogContext()
                .MinimumLevel.Error()
                .WriteTo.MSSqlServer(
                connectionString: ebuilder.ConnectionString,
                sinkOptions: sinkOpts)
               .CreateLogger();

            Serilog.Debugging.SelfLog.Enable(msg =>{ Debug.Print(msg); });


#region Dynamically Configure xsite instance(s)...

            var xsiteOptions = new XSiteConfigurationOptions();
            config.GetSection(XSiteConfigurationOptions.SectionName).Bind(xsiteOptions);

            // One or many or all xsite contexts can be implemented, it depends on the configuration in the XSite section...
            // Currently xsite is localized for the following countries:
            // US 
            // AZ
            // GG
            foreach( var cfg in xsiteOptions.LanguageConfigurations)
            {
                var xbuilder = new SqlConnectionStringBuilder(cfg.ConnectionString);
                var langcode = cfg.CountryISOCode.Replace("-", "").ToLower();
                if (langcode == "enus")
                    services.AddDbContext<xSiteContext_enus>(options => options.UseSqlServer(xbuilder.ConnectionString));
                else if (langcode == "azl")
                    services.AddDbContext<xSiteContext_azl>(options => options.UseSqlServer(xbuilder.ConnectionString));
                else if (langcode == "kage")
                    services.AddDbContext<xSiteContext_kage>(options => options.UseSqlServer(xbuilder.ConnectionString));
            }

#endregion

            services.AddTransient<IPasswordValidator<ApplicationUser>, CustomPasswordValidator>();
            services.AddTransient<IUserValidator<ApplicationUser>, CustomUserNamePolicy>();

            // For Identity  
            services.AddIdentity<ApplicationUser, IdentityRole>()
                .AddEntityFrameworkStores<ApplicationDbContext>()
                .AddDefaultTokenProviders();
        }
    }
}
