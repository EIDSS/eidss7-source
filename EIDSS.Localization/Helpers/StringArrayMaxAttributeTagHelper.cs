using EIDSS.Localization.Constants;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// Customized required validator to attach the appropriate localized field name for the resource set 
    /// to the error message.
    /// 
    /// Use on the data annotation in the domain and/or view model.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property)]
    public class LocalizedStringArrayMaxAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public  int MaxSize { get; set; }

        public string ValidationMessage { get; set; }

        public LocalizedStringArrayMaxAttribute(int maxSize,string validationMessage) 
        {
            MaxSize = maxSize;
            ValidationMessage = validationMessage;
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

            string[] array = value as string[];

            if (array == null || array.Any(item => string.IsNullOrEmpty(item)) || array.Length > MaxSize)
            {

                ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, GetPropertyValue(ValidationMessage, typeof(MessageResourceKeyConstants)));

                //ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.EnterAtLeastOneParameterMessage);

                return new ValidationResult(ErrorMessage);
            }

            return ValidationResult.Success;


        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            //ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.EnterAtLeastOneParameterMessage);
            ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, GetPropertyValue(ValidationMessage, typeof(MessageResourceKeyConstants)));


            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-localizedstringarraymax", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-localizedstringarraymax-maxsize", MaxSize.ToString());


        }

        private string GetPropertyValue(string FieldName, Type src)
        {
            try
            {
                if (src.GetField(FieldName) != null)
                {
                    return src.GetField(FieldName).GetValue(src).ToString();
                }
                else
                {
                    return FieldName;
                }
            }
            catch
            {
                return FieldName;
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
