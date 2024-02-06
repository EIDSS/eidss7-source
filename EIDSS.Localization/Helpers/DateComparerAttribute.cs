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
    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = true)]
    public class DateComparerAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;
        public string FirstDateLabel { get; private set; }
        public string SecondDateLabel { get; private set; }
        public string FirstDateElement { get; private set; }
        public string SecondDateElement { get; private set; }
        public CompareTypeEnum Compare { get; set; }
        private PropertyInfo FirstDate { get; set; }
        private PropertyInfo SecondDate { get; set; }
        public string FirstDateID { get; private set; }
        public string SecondDateID { get; private set; }

        public DateComparerAttribute(string firstDateID, string firstDateElement, string secondDateID, string secondDateElement, CompareTypeEnum type, string firstDateLabel, string secondDateLabel)
        {
            FirstDateLabel = firstDateLabel;
            FirstDateElement = firstDateElement;
            SecondDateLabel = secondDateLabel;
            SecondDateElement = secondDateElement;
            Compare = type;
            FirstDateID = firstDateID;
            SecondDateID = secondDateID;
        }

        private static string GetPropertyValue(string FieldName, Type src)
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

        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            FirstDate = validationContext.ObjectInstance.GetType().GetProperty(FirstDateID);
            SecondDate = validationContext.ObjectInstance.GetType().GetProperty(SecondDateID);
            var firstDateValue = FirstDate.GetValue(validationContext.ObjectInstance, null);
            var secondDateValue = SecondDate.GetValue(validationContext.ObjectInstance, null);

            string strFirstDate = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, GetPropertyValue(FirstDateLabel, typeof(FieldLabelResourceKeyConstants)));
            string strSecondDate = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, GetPropertyValue(SecondDateLabel, typeof(FieldLabelResourceKeyConstants)));
            
            string ValidationMessage = string.Empty;
            bool equals = false;

            if (value is DateTime && firstDateValue is DateTime && secondDateValue is DateTime)
            {
                if (Compare == CompareTypeEnum.EqualsTo)
                {
                    ValidationMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.GlobalMustBeEqualToMessage);
                    equals = ((DateTime)firstDateValue) == ((DateTime)secondDateValue);
                }
                else if (Compare == CompareTypeEnum.GreaterThan)
                {
                    ValidationMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.GlobalMustBeGreaterThanMessage);
                    equals = ((DateTime)firstDateValue) > ((DateTime)secondDateValue);
                }
                else if (Compare == CompareTypeEnum.GreaterThanOrEqualTo)
                {
                    ValidationMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.GlobalMustBeGreaterThanOrEqualToMessage);
                    equals = ((DateTime)firstDateValue) >= ((DateTime)secondDateValue);
                }
                else if (Compare == CompareTypeEnum.LessThan)
                {
                    ValidationMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.GlobalMustBeLessThanMessage);
                    equals = ((DateTime)firstDateValue) < ((DateTime)secondDateValue);
                }
                else if (Compare == CompareTypeEnum.LessThanOrEqualTo)
                {
                    ValidationMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.GlobalMustBeLessThanOrEqualToMessage);
                    equals = ((DateTime)firstDateValue) <= ((DateTime)secondDateValue);
                }

                if (!equals) { return new ValidationResult(FormatErrorMessage(string.Format(ValidationMessage, strFirstDate, strSecondDate))); }
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = FormatErrorMessage(FirstDateLabel + " must be " + Enum.GetName(typeof(CompareTypeEnum), Compare) + " " + SecondDateLabel);

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-datecomparer", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-datecomparer-firstdate", FirstDateElement);
            MergeAttribute(context.Attributes, "data-val-datecomparer-seconddate", SecondDateElement);
            MergeAttribute(context.Attributes, "data-val-datecomparer-compare", Compare.ToString());
            MergeAttribute(context.Attributes, "data-val-datecomparer-language", CurrentCulture.TwoLetterISOLanguageName);
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
