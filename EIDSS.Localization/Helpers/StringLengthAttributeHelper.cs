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
    public class LocalizedStringLengthAttribute : StringLengthAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public LocalizedStringLengthAttribute(int maximumLength) : base(maximumLength)
        {
        }

        /// <summary>
        /// Looks up the resource key in the localization cache for the "Field is invalid." resource value for the corresponding 
        /// property name and resource set.
        /// </summary>
        /// <param name="value">Field text the user typed in.</param>
        /// <param name="validationContext"></param>
        /// <returns><see cref="ValidationResult"/></returns>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            if (!string.IsNullOrWhiteSpace(value?.ToString()))
            {
                string val = Convert.ToString(value);
                if (val.Length < MinimumLength || val.Length > MaximumLength)
                {
                    ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);

                    return new ValidationResult(ErrorMessage);
                }
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-length", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-length-max", MaximumLength.ToString());
            MergeAttribute(context.Attributes, "data-val-length-min", MinimumLength.ToString());

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