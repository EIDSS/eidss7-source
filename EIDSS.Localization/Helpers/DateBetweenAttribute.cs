using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Localization.Helpers
{
    [AttributeUsage(AttributeTargets.All)]
    public class DateBetweenAttribute : ValidationAttribute, IClientModelValidator
    {

        private LocalizationMemoryCacheProvider CacheProvider;
        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;
        public string FromDate { get; private set; }
        public string ToDate { get; private set; }

        public string FromDateElement { get; private set; }
        public string ToDateElement { get; private set; }
        private PropertyInfo FromDatePropertyInfo { get; set; }
        private PropertyInfo ToDatePropertyInfo { get; set; }

        public string ValidationMessage { get; set; }

        public DateBetweenAttribute(string fromDate, string fromDateElement, string toDate, string toDateElement, string validationMessage)
        {
            FromDate = fromDate;
            FromDateElement = fromDateElement;
            ToDate = toDate;
            ToDateElement = toDateElement;
            ValidationMessage = validationMessage;
        }

        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            var result = new ValidationResult("");
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            FromDatePropertyInfo = validationContext.ObjectInstance.GetType().GetProperty(FromDate);
            ToDatePropertyInfo = validationContext.ObjectInstance.GetType().GetProperty(ToDate);
            var fromDateObject = FromDatePropertyInfo.GetValue(validationContext.ObjectInstance, null);
            var toDateObject = ToDatePropertyInfo.GetValue(validationContext.ObjectInstance, null);
            if (value is DateTime && fromDateObject is DateTime && toDateObject is DateTime)
            {
                var valueDateTime = (DateTime)value;
                var fromDateTime = (DateTime)fromDateObject;
                var toDateTime = (DateTime)value;

                if (valueDateTime <= toDateTime && valueDateTime >= fromDateTime)
                {
                    result = ValidationResult.Success;
                }
                else
                {
                    result = new ValidationResult(ValidationMessage);
                }
            }
            else
            {
                result = new ValidationResult("");
            }

            return result;
        }


        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = FormatErrorMessage(ValidationMessage);
            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-datebetween", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-datebetween-fromdate",FromDateElement);
            MergeAttribute(context.Attributes, "data-val-datebetween-todate", ToDateElement);
            MergeAttribute(context.Attributes, "data-val-datebetween-validationmessage", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-datebetween-language", CurrentCulture.TwoLetterISOLanguageName);


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

    
