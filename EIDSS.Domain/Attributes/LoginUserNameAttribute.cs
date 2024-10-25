using EIDSS.Domain.ViewModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    [AttributeUsage(AttributeTargets.All, AllowMultiple = false)]
    public class LoginUserNameAttribute:ValidationAttribute
    {
        public string UserName { get; set; }

        public LoginUserNameAttribute(string userName) :base()
        {
            UserName = userName;

            ErrorMessage = $"{UserName} is an invalid";

        }


        public string GetErrorMessage() =>
            $"User Name can not be  {UserName}.";

        protected override ValidationResult IsValid(object value,
            ValidationContext validationContext)
        {
            var loginvViewModel = (LoginViewModel)validationContext.ObjectInstance;
            var user_name = (string) value;

            if (user_name == UserName)
            {
                return new ValidationResult(GetErrorMessage());
            }

            return ValidationResult.Success;
        }
    }
}
