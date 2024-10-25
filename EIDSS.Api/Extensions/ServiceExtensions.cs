using EIDSS.Api.Configuration;
using EIDSS.Api.Helpers;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Repository;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.Repositories;
using EIDSS.Security.Encryption;
using MapsterMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Serilog;
using Serilog.Sinks.MSSqlServer;
using System.Collections.Generic;
using System.Diagnostics;

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
            services.AddScoped<EIDSSContextProcedures, EIDSSContextProcedures>();
            services.AddSingleton<IModelPropertyMapper, ModelPropertyMapper>();
            services.AddScoped<ITlbHumanActualRepository, TlbHumanActualRepository>();
            services.AddScoped<ITrtBaseReferenceRepository, TrtBaseReferenceRepository>();
            services.AddScoped<ITlbChangeDiagnosisHistoryRepository, TlbChangeDiagnosisHistoryRepository>();
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
        /// <param name="configuration"></param>
        public static void ConfigureContexts(this IServiceCollection services, IConfiguration configuration)
        {
            var protectedSettings = GetProtectedSettings(configuration);

            var eidssConnectionString = GetConnectionString(configuration, "EIDSSConn", protectedSettings.EIDSSDatabaseUser, protectedSettings.EIDSSDatabasePassword);
            var archiveConnectionString = GetConnectionString(configuration, "EIDSSArchiveConn", protectedSettings.EIDSSArchiveDatabaseUser, protectedSettings.EIDSSArchiveDatabasePassword);

            Dictionary<string, string> connectionStrings = new()
            {
                {"EIDSS", eidssConnectionString},
                {"EIDSSARCHIVE", archiveConnectionString}
            };

            DbContextFactory.SetConnectionString(connectionStrings, services);
            DbContextFactory.Connect("EIDSS");

            // Configure Serilog...
            // A flaw in serilog requires it to be loaded after the connection strings have been configured.

            // Problem:  Serilog doesn't work with user secrets.  When you assign a connection string to serilog
            // for logging to the DB, it uses it as is; so during development, if using user secrets to complete
            // the connection string, Serilog won't work because it knows nothing about the update to the connection string.

            // To get around this, we load it here.
            var sinkOptions = new MSSqlServerSinkOptions
            {
                TableName = "tauApplicationEventLog",
                AutoCreateSqlTable = false
            };

            Log.Logger = new LoggerConfiguration()
                .Enrich.WithMachineName()
                .Enrich.WithProcessName()
                .Enrich.WithThreadName()
                .Enrich.FromLogContext()
                .MinimumLevel.Error()
                .WriteTo.MSSqlServer(
                connectionString: eidssConnectionString,
                sinkOptions: sinkOptions)
               .CreateLogger();

            Serilog.Debugging.SelfLog.Enable(message => { Debug.Print(message); });

            AddXSiteDbContext(services, configuration);

            services.AddTransient<IPasswordValidator<ApplicationUser>, CustomPasswordValidator>();
            services.AddTransient<IUserValidator<ApplicationUser>, CustomUserNamePolicy>();

            services.AddIdentity<ApplicationUser, IdentityRole>()
                .AddEntityFrameworkStores<ApplicationDbContext>()
                .AddDefaultTokenProviders();
        }

        private static void AddXSiteDbContext(IServiceCollection services, IConfiguration configuration)
        {
            var protectedSettings = GetProtectedSettings(configuration);

            var xsiteOptions = new XSiteConfigurationOptions();
            configuration.GetSection(XSiteConfigurationOptions.SectionName).Bind(xsiteOptions);

            foreach (var languageConfiguration in xsiteOptions.LanguageConfigurations)
            {
                var langcode = languageConfiguration.CountryISOCode.Replace("-", "").ToLower();
                if (langcode == "enus")
                {
                    var connectionString = GetConnectionString(languageConfiguration.ConnectionString, protectedSettings.XSiteEnUsDatabaseUser, protectedSettings.XSiteEnUsDatabasePassword);
                    services.AddDbContext<XSiteContextEnUS>(options => options.UseSqlServer(connectionString));
                }
                else if (langcode == "azl")
                {
                    var connectionString = GetConnectionString(languageConfiguration.ConnectionString, protectedSettings.XSiteAzLDatabaseUser, protectedSettings.XSiteAzLDatabasePassword);
                    services.AddDbContext<XSiteContextAzL>(options => options.UseSqlServer(connectionString));
                }
                else if (langcode == "kage")
                {
                    var connectionString = GetConnectionString(languageConfiguration.ConnectionString, protectedSettings.XSiteKaGeDatabaseUser, protectedSettings.XSiteKaGeDatabasePassword);
                    services.AddDbContext<XSiteContextKaGe>(options => options.UseSqlServer(connectionString));
                }
            }
        }

        private static string GetConnectionString(
            string connectionString,
            string encryptedUserId,
            string encryptedPassword)
        {
            var builder = new SqlConnectionStringBuilder(connectionString);

            if (!builder.IntegratedSecurity &&
                (string.IsNullOrEmpty(builder.UserID) ||
                string.IsNullOrEmpty(builder.Password)))
            {
                builder.UserID = encryptedUserId.Decrypt();
                builder.Password = encryptedPassword.Decrypt();
            }

            return builder.ConnectionString;
        }

        private static string GetConnectionString(
            IConfiguration configuration,
            string connectionStringName,
            string encryptedUserId,
            string encryptedPassword)
        {
            var connectionString = configuration.GetConnectionString(connectionStringName);
            return GetConnectionString(connectionString, encryptedUserId, encryptedPassword);
        }

        private static ProtectedSettings GetProtectedSettings(IConfiguration configuration)
        {
            var protectedConfigSection = configuration.GetSection("ProtectedConfiguration");
            return protectedConfigSection.Get<ProtectedSettings>();
        }
    }
}
