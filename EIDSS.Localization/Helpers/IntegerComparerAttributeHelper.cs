#region Usings

using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Reflection;

#endregion

namespace EIDSS.Localization.Helpers
{
    [AttributeUsage(AttributeTargets.Property)]
    public class IntegerComparerAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;
        public string From { get; private set; }
        public string To { get; private set; }
        public CompareTypeEnum Compare { get; set; }
        private PropertyInfo FromPropertyInfo { get; set; }
        private PropertyInfo ToPropertyInfo { get; set; }
        public string ValidationMessage { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="from"></param>
        /// <param name="to"></param>
        /// <param name="type"></param>
        /// <param name="validationMessage"></param>
        public IntegerComparerAttribute(string from, string to, CompareTypeEnum type, string validationMessage)
        {
            From = from;
            To = to;
            Compare = type;
            ValidationMessage = validationMessage;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="validationContext"></param>
        /// <returns></returns>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            FromPropertyInfo = validationContext.ObjectInstance.GetType().GetProperty(From);
            ToPropertyInfo = validationContext.ObjectInstance.GetType().GetProperty(To);
            var fromValue = FromPropertyInfo.GetValue(validationContext.ObjectInstance, null);
            var toValue = ToPropertyInfo.GetValue(validationContext.ObjectInstance, null);
            if (value is int && fromValue is int && toValue is int)
            {
                string propertyValue = GetPropertyValue(typeof(MessageResourceKeyConstants));
                ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, propertyValue);

                if (Compare == CompareTypeEnum.EqualsTo)
                {
                    bool equals = ((int)fromValue) == ((int)toValue);
                    if (!equals)
                    {
                        return new ValidationResult(ErrorMessage);
                    }
                }
                else if (Compare == CompareTypeEnum.GreaterThan)
                {
                    bool equals = ((int)fromValue) > ((int)toValue);
                    if (!equals)
                        return new ValidationResult(ErrorMessage);
                }
                else if (Compare == CompareTypeEnum.GreaterThanOrEqualTo)
                {
                    bool equals = ((int)fromValue) >= ((int)toValue);
                    if (!equals)
                        return new ValidationResult(ErrorMessage);
                }
                else if (Compare == CompareTypeEnum.LessThan)
                {
                    bool equals = ((int)fromValue) < ((int)toValue);
                    if (!equals)
                        return new ValidationResult(ErrorMessage);
                }
                else if (Compare == CompareTypeEnum.LessThanOrEqualTo)
                {
                    bool equals = ((int)fromValue) <= ((int)toValue);
                    if (!equals)
                        return new ValidationResult(ErrorMessage);
                }
            }

            return ValidationResult.Success;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="src"></param>
        /// <returns></returns>
        private string GetPropertyValue(Type src)
        {
            return src.GetField(ValidationMessage).GetValue(src).ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="context"></param>
        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            string propertyValue = GetPropertyValue(typeof(MessageResourceKeyConstants));

            ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, propertyValue);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-integercomparer", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-integercomparer-from", From);
            MergeAttribute(context.Attributes, "data-val-integercomparer-to", To);
            MergeAttribute(context.Attributes, "data-val-integercomparer-compare", Compare.ToString());
            MergeAttribute(context.Attributes, "data-val-integercomparer-message", ErrorMessage);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <returns></returns>
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
