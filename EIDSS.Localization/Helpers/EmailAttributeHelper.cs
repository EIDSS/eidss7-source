using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using System;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Text.RegularExpressions;

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// Customized email validator to attach the appropriate localized field name for the resource set 
    /// to the error message.
    /// 
    /// Use on the data annotation in the domain and/or view model.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property)]
    public class LocalizedEmailValidator : ValidationAttribute
    {
        private LocalizationMemoryCacheProvider CacheProvider;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        private string PropertyName { get; set; }

        public LocalizedEmailValidator(string propertyName)
        {
            PropertyName = propertyName;
        }

        /// <summary>
        /// Looks up the resource key in the localization cache for the "Field Text" resource value for the corresponding 
        /// property name and resource set.
        /// </summary>
        /// <param name="value">Field text the user typed in.</param>
        /// <param name="validationContext"></param>
        /// <returns><see cref="ValidationResult"/></returns>
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            if (value != null)
            {
                IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));

                CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

                object instance = validationContext.ObjectInstance;
                Type type = instance.GetType();

                string resourceKey = type.GetProperty(LocalizationGlobalConstants.ResourceSet).GetValue(instance)?.ToString() + PropertyName + InterfaceEditorTypeEnum.FieldLabel;

                if (Regex.IsMatch(value.ToString(), @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}", RegexOptions.IgnoreCase,TimeSpan.FromMilliseconds(5)))
                {
                    return ValidationResult.Success;
                }
                else
                {
                    ErrorMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, resourceKey + " " + CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, AttributeMessageConstants.InvalidEmail));

                    return new ValidationResult(ErrorMessage);
                }
            }
            else
            {
                return ValidationResult.Success;
            }
        }
    }
}