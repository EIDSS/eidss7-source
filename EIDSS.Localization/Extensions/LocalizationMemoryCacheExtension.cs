using System;
using EIDSS.Localization.Models;
using EIDSS.Localization.Providers;
using System.Collections.Generic;
using System.Linq;

namespace EIDSS.Localization.Extensions
{
    public static class LocalizationMemoryCacheExtension
    {
        public static List<USP_GBL_Resource_GETListResult> GetResourceListByLanguageID(this LocalizationMemoryCacheProvider cache, long languageID)
        {
            List<USP_GBL_Resource_GETListResult> resources = cache.GetList<USP_GBL_Resource_GETListResult>().Where(k => k.LanguageID == languageID).ToList();

            return resources;
        }

        #region ByCulture

        public static List<USP_GBL_Resource_GETListResult> GetResourceByLanguageCultureName(this LocalizationMemoryCacheProvider cache, string cultureName)
        {
            List<USP_GBL_Resource_GETListResult> resources = null;
            var languageByCultureName = cache.GetLanguage(cultureName);
            if (languageByCultureName != null)
            {
                resources = cache.GetList<USP_GBL_Resource_GETListResult>().Where(k => k.LanguageID == languageByCultureName.LanguageID).ToList();

                return resources;
            }

            resources = cache.GetList<USP_GBL_Resource_GETListResult>().Where(k => k.LanguageID == cache.DefaultLanguage.LanguageID).ToList();

            return resources;
        }

        public static USP_GBL_Resource_GETListResult GetResourceByLanguageCultureNameAndResourceKey(this LocalizationMemoryCacheProvider cache, string cultureName, string resourceKey)
        {
            var resourcesByCulture = cache.GetResourceByLanguageCultureName(cultureName);

            return resourcesByCulture?.FirstOrDefault(k => k.ResourceKey == resourceKey);
        }

        public static bool GetHiddenResourceByLanguageCultureNameAndResourceKey(this LocalizationMemoryCacheProvider cache, string cultureName, string resourceKey)
        {
            var resourcesByCulture = cache.GetResourceByLanguageCultureName(cultureName);

            return resourcesByCulture?.FirstOrDefault(k => k.ResourceKey == resourceKey)?.ResourceIsHidden ?? false;
        }

        public static bool GetRequiredResourceByLanguageCultureNameAndResourceKey(this LocalizationMemoryCacheProvider cache, string cultureName, string resourceKey)
        {
            var resourcesByCulture = cache.GetResourceByLanguageCultureName(cultureName);

            return resourcesByCulture?.FirstOrDefault(k => k.ResourceKey == resourceKey)?.ResourceIsRequired ?? false;
        }

        public static string GetResourceValueByLanguageCultureNameAndResourceKey(this LocalizationMemoryCacheProvider cache, string cultureName, string resourceKey)
        {
            var resource = cache.GetResourceByLanguageCultureNameAndResourceKey(cultureName, resourceKey);

            return resource?.ResourceValue ?? string.Empty;
        }

        public static string GetHiddenResourceValueByLanguageCultureNameAndResourceKey(this LocalizationMemoryCacheProvider cache, string cultureName, string resourceKey)
        {
            var resource = cache.GetHiddenResourceByLanguageCultureNameAndResourceKey(cultureName, resourceKey);

            return resource.ToString();
        }

        public static string GetRequiredResourceValueByLanguageCultureNameAndResourceKey(this LocalizationMemoryCacheProvider cache, string cultureName, string resourceKey)
        {
            var resource = cache.GetRequiredResourceByLanguageCultureNameAndResourceKey(cultureName, resourceKey);

            return resource.ToString();
        }

        #endregion ByCulture

        #region DefaultLanguage

        public static List<USP_GBL_Resource_GETListResult> GetDefaultLanguageResourceList(this LocalizationMemoryCacheProvider cache)
        {
            var resources = cache.GetResourceListByLanguageID(cache.DefaultLanguage.LanguageID);

            return resources;
        }

        public static USP_GBL_Resource_GETListResult GetDefaultLanguageResourceByResourceKey(this LocalizationMemoryCacheProvider cache, string resourceKey)
        {
            var resource = cache.GetDefaultLanguageResourceList();

            return resource.FirstOrDefault(k => k.ResourceKey == resourceKey);
        }

        public static string GetDefaultLanguageResourceValueByResourceKey(this LocalizationMemoryCacheProvider cache, string resourceKey)
        {
            var resource = cache.GetDefaultLanguageResourceByResourceKey(resourceKey);

            return resource?.ResourceValue;
        }

        #endregion DefaultLanguage
    }
}