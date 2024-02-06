#region Using Statements

using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;

#endregion

namespace EIDSS.Localization.Helpers
{
    [AttributeUsage(AttributeTargets.Property)]
    public class IsValidDateAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider _cacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            var service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));
            if (service != null)
	            _cacheProvider =
		            (LocalizationMemoryCacheProvider) service.GetService(typeof(LocalizationMemoryCacheProvider));
            var cultureInfo = CultureInfo.CreateSpecificCulture(CurrentCulture.Name);

            if (value == null)
            {
                return ValidationResult.Success;
            }

            if (string.IsNullOrEmpty(value.ToString()))
            {
                return ValidationResult.Success;
            }

            var dateToParse = value.ToString();

            if (dateToParse != null)
            {
	            var parsedDate = DateTime.Parse(dateToParse, cultureInfo);
	            var jan11900 = Convert.ToDateTime("1900-01-01");

	            if (dateToParse == "")
	            {
		            ErrorMessage = _cacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);
		            return new ValidationResult(ErrorMessage);
	            }

	            if (parsedDate != DateTime.MinValue && parsedDate >= jan11900)
		            return ValidationResult.Success;
            }

            ErrorMessage = _cacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);
            return new ValidationResult(ErrorMessage);
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            var service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            if (service != null)
	            _cacheProvider =
		            (LocalizationMemoryCacheProvider) service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = _cacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.InvalidFieldMessage);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-isvaliddate", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-isvaliddate-language", CurrentCulture.TwoLetterISOLanguageName);
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
