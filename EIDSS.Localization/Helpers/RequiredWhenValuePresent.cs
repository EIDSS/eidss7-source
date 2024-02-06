using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Reflection;

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// Customized required validator to attach the appropriate localized field name for the resource set 
    /// to the error message, as well as, determining if the field is required for the specified resource 
    /// set.
    /// 
    /// Use on the data annotation in the domain and/or view model.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property)]
    public class LocalizedRequiredWhenOtherValuePresentAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;
        public string OtherPropertyName { get; set; }
        public object OtherPropertyValue { get; set; }

        public LocalizedRequiredWhenOtherValuePresentAttribute(string otherPropertyName, object otherPropertyValue)
        {
            OtherPropertyName = otherPropertyName;
            OtherPropertyValue = otherPropertyValue;
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
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            PropertyInfo otherProperty = validationContext.ObjectType.GetProperty(OtherPropertyName);
            if (otherProperty == null)
                return new ValidationResult(string.Format(CultureInfo.CurrentCulture, "Could not find a property named '{0}'.", OtherPropertyName));

            object otherValue = otherProperty.GetValue(validationContext.ObjectInstance);

            if ((otherValue == null && OtherPropertyValue == null) || (otherValue.Equals(OtherPropertyValue)))
            {
                if (string.IsNullOrEmpty(value.ToString()))
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
            MergeAttribute(context.Attributes, "data-val-localizedrequiredwhenvaluepresent", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-localizedrequiredwhenvaluepresent-otherproperty", OtherPropertyName);
            MergeAttribute(context.Attributes, "data-val-localizedrequiredwhenvaluepresent-otherpropertyvalue", OtherPropertyValue.ToString());
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