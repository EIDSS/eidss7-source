using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    [AttributeUsage(AttributeTargets.All, AllowMultiple = false)]
    public class RequirdIfTrueAttribute : ValidationAttribute, IClientModelValidator
    {
        public string PropertyName { get; set; }
        public bool PropertyValue { get; set; }

        public RequirdIfTrueAttribute(string propertyName, string errorMessage = "")
        {
            PropertyName = propertyName;
            ErrorMessage = errorMessage;
        }

        
        protected override ValidationResult IsValid(object value, ValidationContext context)
        {
            object instance = context.ObjectInstance;
            Type type = instance.GetType();

            bool.TryParse(type.GetProperty(PropertyName).GetValue(instance)?.ToString(), out bool propertyValue);

            PropertyValue = propertyValue;

            if (propertyValue && (value == null || string.IsNullOrWhiteSpace(value.ToString())))
            {
                return new ValidationResult(ErrorMessage);
            }

            return ValidationResult.Success;
        }

        public void AddValidation(ClientModelValidationContext context)
        {
            MergeAttribute(context.Attributes, "data-val", "true");
            var errorMessage = FormatErrorMessage(context.ModelMetadata.GetDisplayName());
            MergeAttribute(context.Attributes, "data-val-requirediftrue", errorMessage);
            MergeAttribute(context.Attributes, "data-val-requirediftrue-required", PropertyName);

        }

        private bool MergeAttribute(IDictionary<string, string> attributes, string key, string value)
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
