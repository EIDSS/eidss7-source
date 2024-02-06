using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// Customized required validator to attach the appropriate localized field name for the resource set 
    /// to the error message.
    /// 
    /// Use on the data annotation in the domain and/or view model.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property)]
    public class LocalizedRequiredAttribute : RequiredAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public LocalizedRequiredAttribute()
        {
        }

        /// <summary>
        /// Looks up the resource key in the localization cache for the "Required" resource value for the corresponding 
        /// property name and resource set.
        /// </summary>
        /// <param name="value">Field text the user typed in.</param>
        /// <param name="validationContext"></param>
        /// <returns><see cref="ValidationResult"/></returns>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));

            if (service != null)
            {
                CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

                if (string.IsNullOrWhiteSpace(value?.ToString()))
                {
                    ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

                    return new ValidationResult(ErrorMessage);
                }
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-required", ErrorMessage);
        }

        private static bool MergeAttribute(IDictionary<string, string> attributes, string key, string value)
        {
            if (attributes.ContainsKey(key))
            {
                return false;
            }

            attributes.Add(key, value);
            return true;
        }
    }
}