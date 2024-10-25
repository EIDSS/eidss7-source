using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ModelValidation
{
    public class ValidatableLoginModel : IValidatableObject
    {

        public string TestUserName { get; set; } = "testuser";
        public ValidatableLoginModel()
        {

        }

        [Required(ErrorMessage = "User Name is required")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (Username == TestUserName)
            {
                yield return new ValidationResult(
                    $"You can not use  {TestUserName}.",
                    new[] { nameof(Username) });
            }
        }


    }

}