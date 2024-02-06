using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.Attributes
{
    // This is a class-level attribute, doesn't make sense at the property level
    [AttributeUsage(AttributeTargets.Class)]
    public class AtLeastOnePropertyAttribute : ValidationAttribute
    {
        // Have to override IsValid
        public override bool IsValid(object value)
        {
            //  Need to use reflection to get properties of "value"...
            var typeInfo = value.GetType();
            var propertyInfo = typeInfo.GetProperties();

            foreach (var property in propertyInfo)
            {
                if (property.DeclaringType.Name != "BaseGetRequestModel")
                {
                    if (property.PropertyType != typeof(bool))
                    {
                        if (null != property.GetValue(value, null))
                        {
                            // We've found a property with a value
                            return true;
                        }
                    }
                }
            }

            // All properties were null.
            return false;
        }
    }
}
