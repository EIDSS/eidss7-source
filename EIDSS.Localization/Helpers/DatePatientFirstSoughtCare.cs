#region Usings

using EIDSS.Localization.Constants;
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
    public class DatePatientFirstSoughtCareAttribute : ValidationAttribute, IClientModelValidator
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;
        public string FirstDateElement { get; private set; }
        public string SecondDateElement { get; private set; }
        public string ThirdDateElement { get; private set; }
        private PropertyInfo FirstDate { get; set; }
        private PropertyInfo SecondDate { get; set; }
        private PropertyInfo ThirdDate { get; set; }
        public string FirstDateID { get; private set; }
        public string SecondDateID { get; private set; }
        public string ThirdDateID { get; private set; }

        public DatePatientFirstSoughtCareAttribute(string firstDateID, string firstDateElement, string secondDateID, string secondDateElement, string thirdDateID, string thirdDateElement)
        {
            FirstDateElement = firstDateElement;
            SecondDateElement = secondDateElement;
            ThirdDateElement = thirdDateElement;

            FirstDateID = firstDateID;
            SecondDateID = secondDateID;
            ThirdDateID = thirdDateID;
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
            ThirdDate = validationContext.ObjectInstance.GetType().GetProperty(ThirdDateID);

            var firstDateValue = FirstDate.GetValue(validationContext.ObjectInstance, null);
            var secondDateValue = SecondDate.GetValue(validationContext.ObjectInstance, null);
            var thirdDateValue = ThirdDate.GetValue(validationContext.ObjectInstance, null);

            string ValidationMessage = string.Empty;
            bool equals = false;

            if (value is DateTime && firstDateValue is DateTime && secondDateValue is DateTime && thirdDateValue is DateTime)
            {
                ValidationMessage = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, MessageResourceKeyConstants.HumanDiseaseReportSoughtCareDateShallBeOnOrAfterDateOfSymptomOnsetAndNoLaterThanDateOfDiagnosisMessage);
                equals = (((DateTime)firstDateValue) >= ((DateTime)secondDateValue)) && (((DateTime)firstDateValue) <= ((DateTime)thirdDateValue));

                if (!equals) { return new ValidationResult(FormatErrorMessage(ValidationMessage)); }
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            IServiceProvider service = (IServiceProvider)context.ActionContext.HttpContext.RequestServices.GetService(typeof(IServiceProvider));
            CacheProvider = (LocalizationMemoryCacheProvider)service.GetService(typeof(LocalizationMemoryCacheProvider));

            ErrorMessage = MessageResourceKeyConstants.HumanDiseaseReportSoughtCareDateShallBeOnOrAfterDateOfSymptomOnsetAndNoLaterThanDateOfDiagnosisMessage;

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-datepatientfirstsoughtcare", ErrorMessage);
            MergeAttribute(context.Attributes, "data-val-datepatientfirstsoughtcare-firstdate", FirstDateElement);
            MergeAttribute(context.Attributes, "data-val-datepatientfirstsoughtcare-seconddate", SecondDateElement);
            MergeAttribute(context.Attributes, "data-val-datepatientfirstsoughtcare-thirddate", ThirdDateElement);
            //MergeAttribute(context.Attributes, "data-val-datepatientfirstsoughtcare-compare", Compare.ToString());
            MergeAttribute(context.Attributes, "data-val-datepatientfirstsoughtcare-language", CurrentCulture.TwoLetterISOLanguageName);
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
