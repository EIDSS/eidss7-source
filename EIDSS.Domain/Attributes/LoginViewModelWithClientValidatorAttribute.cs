using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using Microsoft.AspNetCore.Mvc.Rendering;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    [AttributeUsage(AttributeTargets.All, AllowMultiple = false)]
    public class LoginViewModelWithClientValidatorAttribute : ValidationAttribute, IClientModelValidator
    {
        public string UserName { get; set; }

        public LoginViewModelWithClientValidatorAttribute(string userName)
        {
            UserName = userName;
        }

        public void AddValidation(ClientModelValidationContext context)
        {

            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-rulename", GetErrorMessage());

            var user = UserName.ToString(CultureInfo.InvariantCulture);
            MergeAttribute(context.Attributes, "data-val-rulename-userName", user);
            MergeAttribute(context.Attributes, "data-val-required", "This fields is required");
        }

        public string GetErrorMessage() =>
            $" {UserName} user name is not valid.";

        protected override ValidationResult IsValid(object value,
            ValidationContext validationContext)
        {
            var movie = (LoginViewModel)validationContext.ObjectInstance;
            var user_name = (string)value;

            if (user_name == UserName)
            {
                return new ValidationResult(GetErrorMessage());
            }

            return ValidationResult.Success;
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