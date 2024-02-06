using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.Extensions.Localization;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace EIDSS.Localization
{
    public class DatabaseStringLocalizer : IStringLocalizer
    {
        private readonly LocalizationMemoryCacheProvider _cacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public DatabaseStringLocalizer(LocalizationMemoryCacheProvider cacheProvider)
        {
            _cacheProvider = cacheProvider;
        }

        public LocalizedString this[string name]
        {
            get
            {
                var value = GetString(name);
                return new LocalizedString(name, value ?? name, resourceNotFound: value == null);
            }
        }

        public LocalizedString this[string name, params object[] arguments]
        {
            get
            {
                var format = GetString(name);
                var value = string.Format(format ?? name, arguments);
                return new LocalizedString(name, value, resourceNotFound: format == null);
            }
        }

        public IStringLocalizer WithCulture(CultureInfo culture)
        {
            CultureInfo.DefaultThreadCurrentCulture = culture;
            return this;
        }

        public IEnumerable<LocalizedString> GetAllStrings(bool includeAncestorCultures)
        {
            var query = _cacheProvider.ResourceDictionary
                .Where(k => k.Value.CultureName == CurrentCulture.Name)
                .Select(r => new LocalizedString(r.Value.ResourceKey, r.Value.ResourceValue, true));

            return query;
        }

        private string GetString(string name)
        {
            var value = _cacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, name);

            if (string.IsNullOrEmpty(value))
                value = _cacheProvider.GetDefaultLanguageResourceValueByResourceKey(name);

            return value;
        }
    }
}