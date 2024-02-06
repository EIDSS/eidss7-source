using EIDSS.Localization.Interfaces;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Localization
{
    public sealed class LocalizationClientHostingFactory
    {
        private static readonly Lazy<LocalizationClientHostingFactory> lazy = new(() => new LocalizationClientHostingFactory());

        public static LocalizationClientHostingFactory Instance { get { return lazy.Value; } }

        private LocalizationClientHostingFactory()
        {
        }

        public static async Task Bootstrap(IApplicationBuilder app)
        {
            try
            {
                var tasks = app.ApplicationServices.GetServices<ILocalizationStartupTask>();
                if (tasks != null && tasks.Any())
                {
                    foreach (var startupTask in tasks)
                    {
                        await startupTask.InvokeAsync(app);
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}