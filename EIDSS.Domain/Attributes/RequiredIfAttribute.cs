using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Field, AllowMultiple = false)]
    public class RequiredIfAttribute : ValidationAttribute
    {

        public string PropertyName { get; set; }
        public object Value { get; set; }

        public RequiredIfAttribute(string propertyName, string errorMessage = "")
        {
            PropertyName = propertyName;
            ErrorMessage = errorMessage;
        }

        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            IServiceProvider service = (IServiceProvider)validationContext.GetService(typeof(IServiceProvider));

            var instance = validationContext.ObjectInstance;
            var type = instance.GetType();
            var propertyvalue = type.GetProperty(PropertyName).GetValue(instance, null);
            if (Convert.ToBoolean(propertyvalue))
            {
                return new ValidationResult(ErrorMessage);
            }
            return ValidationResult.Success;
        }


    }
}
