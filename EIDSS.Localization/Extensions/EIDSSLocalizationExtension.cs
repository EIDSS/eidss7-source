using EIDSS.Localization.Contexts;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

namespace EIDSS.Localization.Extensions
{
    public static class EIDSSLocalizationExtension
    {
        public static void AddEIDSSLocalization(this IServiceCollection services, IConfiguration config)
        {
            services.AddMemoryCache();
            var ebuilder = new SqlConnectionStringBuilder(config.GetConnectionString("LocalizationConn"));


#if DEBUG || QA_GG_LOCAL_DEBUG || QA_AJ_LOCAL_DEBUG || AJDEVLocal || Perf
            // Get username/password from user secrets only if running locally...
            if (string.IsNullOrEmpty(ebuilder.UserID) && string.IsNullOrEmpty(ebuilder.Password))
            {
                ebuilder.UserID = config["User"];
                ebuilder.Password = config["DbPassword"];
            }
#endif

            services.AddDbContext<LocalizationContext>(options =>
                options.UseSqlServer(ebuilder.ConnectionString),
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
            var localizeServiceProvider =  serviceProvider.GetService<LocalizationMemoryCacheProvider>();

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
    }
}