using EIDSS.Localization.Providers;
using Microsoft.Extensions.Localization;
using System;

namespace EIDSS.Localization
{
    public class DatabaseStringLocalizerFactory : IStringLocalizerFactory
    {
        private readonly LocalizationMemoryCacheProvider _cacheProvider;

        public DatabaseStringLocalizerFactory(LocalizationMemoryCacheProvider cacheProvider)
        {
            _cacheProvider = cacheProvider;
        }

        public IStringLocalizer Create(Type resourceSource)
        {
            return new DatabaseStringLocalizer(_cacheProvider);
        }

        public IStringLocalizer Create(string baseName, string location)
        {
            return new DatabaseStringLocalizer(_cacheProvider);
        }
    }
}