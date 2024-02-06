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
	[AttributeUsage(AttributeTargets.Property)]

    public class DateIsNotGreaterThanAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        private string PropertyName { get; set; }


        public DateIsNotGreaterThanAttribute(string propertyName)
        {
            PropertyName = propertyName;
        }

        private string GetPropertyValue(Type src)
        {
            return src.GetField(PropertyName).GetValue(src).ToString();
        }


        // <summary>
        /// <summary>
        /// 
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

            object instance = validationContext.ObjectInstance;
            Type type = instance.GetType();


            if (!DateTime.TryParseExact(type.GetProperty(value.ToString()).GetValue(instance)?.ToString(), "MM/dd/yyyy", System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out DateTime PropertyValue))
            {
                ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);

                return new ValidationResult(ErrorMessage);
            }
            var parsedDate = new DateTime();

            if (string.IsNullOrEmpty(type.GetProperty(PropertyName).GetValue(instance)?.ToString()))
            {
                return ValidationResult.Success;
            }

           
            DateTime.TryParseExact(type.GetProperty(PropertyName).GetValue(instance)?.ToString(), "MM/dd/yyyy", System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out parsedDate);

            if (PropertyValue.Date > parsedDate.Date )
            {
                ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);

                return new ValidationResult(ErrorMessage);
            }
            return ValidationResult.Success;

        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-dateisnotgreaterthan", ErrorMessage);

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