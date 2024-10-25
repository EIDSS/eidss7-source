using Microsoft.AspNetCore.Mvc.DataAnnotations;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using Microsoft.Extensions.Localization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    public class LoginUseNameAttributeAdapter : AttributeAdapterBase<LoginUserNameAttribute>
    {

        public LoginUseNameAttributeAdapter(LoginUserNameAttribute attribute,IStringLocalizer stringLocalizer)
        : base(attribute, stringLocalizer)
        {

        }
        public override void AddValidation(ClientModelValidationContext context)
        {
            MergeAttribute(context.Attributes, "data-val", "true");
            MergeAttribute(context.Attributes, "data-val-rulename", GetErrorMessage(context));

            var userName = Attribute.UserName.ToString(CultureInfo.InvariantCulture);
            MergeAttribute(context.Attributes, "data-val-rulename-username", userName);
            MergeAttribute(context.Attributes, "data-val-required", "User name is required");

        }

        public override string GetErrorMessage(ModelValidationContextBase validationContext) =>
         Attribute.GetErrorMessage();
    }
}
