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
    /// to the error message, as well as, determining if the field is required for the specified resource 
    /// set.
    /// 
    /// Use on the data annotation in the domain and/or view model.
    /// </summary>
    [AttributeUsage(AttributeTargets.All)]
    public class LocalizedRequiredIfTrueAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        
        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public string PropertyName { get; set; }

        public LocalizedRequiredIfTrueAttribute(string propertyName)
        {
            PropertyName = propertyName;
        }

        private string GetPropertyValue(Type src)
        {
            return src.GetField(PropertyName).GetValue(src).ToString();
        }

        /// <summary>
        /// Looks up the resource key in the localization cache for the "Required" resource value for the corresponding 
        /// property name and resource set.
        /// </summary>
        /// <param name="value">Field text the user typed in.</param>
        /// <param name="validationContext"></param>
        /// <returns><see cref="ValidationResult"/></returns>
        /// <exception cref="Exception">In the event a required resource is not "True" or "False" an exception is thrown.</exception>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));

            if (service != null)
            {
                CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

                string propertyValue = GetPropertyValue(typeof(FieldLabelResourceKeyConstants));

                if (bool.TryParse(CacheProvider.GetRequiredResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, propertyValue), out bool isRequired))
                {
                    ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

                    if (isRequired && string.IsNullOrWhiteSpace(value?.ToString()))
                    {
                        return new ValidationResult(ErrorMessage);
                    }
                }
                else
                    // Resource record should be True or False, check the entry in the database for the corresponding required resource for the interface editor set and property passed in.
                    throw new Exception(LocalizationGlobalConstants.UnableToLoadResourceValue);
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            string propertyValue = GetPropertyValue(typeof(FieldLabelResourceKeyConstants));

            if (bool.TryParse(CacheProvider.GetRequiredResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, propertyValue), out bool isRequired))
            {
                if (isRequired)
                {
                    ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

                    MergeAttribute(context.Attributes, "data-val", "true");
                    MergeAttribute(context.Attributes, "data-val-localizedrequirediftrue", ErrorMessage);
                }
            }
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