using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using EIDSS.Localization.Contexts;
using EIDSS.Localization.Providers;
using EIDSS.Security.Encryption;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;

namespace EIDSS.Localization.Extensions
{
    public static class EIDSSLocalizationExtension
    {
        public static void AddEIDSSLocalization(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddMemoryCache();

            var connectionString = GetConnectionString(configuration);

            services.AddDbContext<LocalizationContext>(options =>
                options.UseSqlServer(connectionString),
                ServiceLifetime.Transient,
                ServiceLifetime.Transient);

            services.AddTransient<LocalizationMemoryCacheProvider>();
            services.AddSingleton<IStringLocalizerFactory, DatabaseStringLocalizerFactory>((provider) =>
            {
                var cacheProvider = provider.GetService<LocalizationMemoryCacheProvider>();

                return new DatabaseStringLocalizerFactory(cacheProvider);
            });

            services.AddSingleton<IConfigureOptions<MvcOptions>, DefaultDataAnnotationsMvcOptionsSetup>();

            services.AddScoped<IStringLocalizer, DatabaseStringLocalizer>((provider) =>
            {
                var cacheProvider = provider.GetService<LocalizationMemoryCacheProvider>();

                return new DatabaseStringLocalizer(cacheProvider);
            });

            // Load the list of cultures supported by this EIDSS installation.
            var supportedCultures = new List<CultureInfo>();
            RequestCulture defaultCulture = null;

            ServiceProvider serviceProvider = services.BuildServiceProvider();
            var localizeServiceProvider = serviceProvider.GetService<LocalizationMemoryCacheProvider>();

            var languageCache = localizeServiceProvider.GetAllLanguages();
            foreach (var language in languageCache)
            {
                if (defaultCulture == null && (bool)language.IsDefaultLanguage)
                    defaultCulture = new RequestCulture(language.CultureName);

                supportedCultures.Add(new CultureInfo(language.CultureName));
            }

            services.Configure<RequestLocalizationOptions>(options =>
            {
                options.DefaultRequestCulture = defaultCulture;
                options.SupportedCultures = supportedCultures;
                options.SupportedUICultures = supportedCultures;
            });
        }

        public static void UseEIDSSLocalization(this IApplicationBuilder builder)
        {
            Task.Run(() => LocalizationClientHostingFactory.Bootstrap(builder)).GetAwaiter().GetResult();

            LocalizationMemoryCacheProvider cacheProvider = builder.ApplicationServices.GetService<LocalizationMemoryCacheProvider>();

            // Load the list of cultures supported by this EIDSS installation.
            var supportedCultures = new List<CultureInfo>();
            RequestCulture defaultCulture = null;
            var languageCache = cacheProvider.GetAllLanguages();
            foreach (var language in languageCache)
            {
                if (defaultCulture == null && (bool)language.IsDefaultLanguage)
                    defaultCulture = new RequestCulture(language.CultureName);

                supportedCultures.Add(new CultureInfo(language.CultureName));
            }

            var requestLocalizationOptions = new RequestLocalizationOptions
            {
                DefaultRequestCulture = defaultCulture,
                SupportedCultures = supportedCultures,
                SupportedUICultures = supportedCultures
            };

            builder.UseRequestLocalization(requestLocalizationOptions);
        }

        private static string GetConnectionString(IConfiguration configuration)
        {
            var builder = new SqlConnectionStringBuilder(configuration.GetConnectionString("LocalizationConn"));

            if (!builder.IntegratedSecurity &&
                (string.IsNullOrEmpty(builder.UserID) ||
                string.IsNullOrEmpty(builder.Password)))
            {
                var userId = configuration.GetValue<string>("ProtectedConfiguration:LocalizationDatabaseUser");
                var password = configuration.GetValue<string>("ProtectedConfiguration:LocalizationDatabasePassword");
                builder.UserID = userId.Decrypt();
                builder.Password = password.Decrypt();
            }

            return builder.ConnectionString;
        }
    }
}