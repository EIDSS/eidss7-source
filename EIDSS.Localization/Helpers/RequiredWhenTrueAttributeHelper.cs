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
    [AttributeUsage(AttributeTargets.Property)]
    public class LocalizedRequiredWhenTrueAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        private string PropertyName { get; set; }
        public bool PropertyValue { get; set; }

        public LocalizedRequiredWhenTrueAttribute(string propertyName, bool propertyValue)
        {
            PropertyName = propertyName;
            PropertyValue = propertyValue;
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
            if (service is not null)
            {
                CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

                object instance = validationContext.ObjectInstance;
                Type type = instance.GetType();
                bool.TryParse(type.GetProperty(PropertyName).GetValue(instance)?.ToString(), out bool propertyValue);
                PropertyValue = propertyValue;

                if (string.IsNullOrEmpty(PropertyValue.ToString()))
                {
                    ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

                    return new ValidationResult(ErrorMessage);
                }
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            var elementIdArr = context.Attributes["id"].Split("_");
            if (elementIdArr.Length > 1)
            {
                var prefixHtmlTag = context.Attributes["id"].Replace(elementIdArr[elementIdArr.Length - 1], "");
                var propertyArr = PropertyName.Split("_");
                if (propertyArr.Length >= 1)
                {
                    PropertyName = string.Format("{0}{1}", prefixHtmlTag, propertyArr[propertyArr.Length - 1]);
                }
            } 
            else if (elementIdArr.Length == 1)
            {
                var prefixHtmlTag = context.Attributes["id"].Replace(elementIdArr[elementIdArr.Length - 1], "");
                var propertyArr = PropertyName.Split("_");
                if (propertyArr.Length >= 1)
                {
                    PropertyName =propertyArr[propertyArr.Length - 1];
                }
            }


            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));

            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));
            ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.FieldIsRequiredMessage);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-localizedrequiredwhentrue", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-localizedrequiredwhentrue-otherproperty", PropertyName);
            MergeAttribute(context.Attributes, "data-val-localizedrequiredwhentrue-otherpropertyvalue", PropertyValue.ToString());
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