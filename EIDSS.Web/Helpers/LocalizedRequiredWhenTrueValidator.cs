using System.Collections.Generic;
using System.Globalization;
using EIDSS.Localization.Providers;
using FluentValidation;
using FluentValidation.Validators;

namespace EIDSS.Web.Helpers
{
    public class LocalizedRequiredWhenTrueValidator<T, TProperty> : PropertyValidator<T, TProperty>
    {
        public LocalizedRequiredWhenTrueValidator()
        {

        }
        public override string Name => "LocalizedRequiredWhenTrueValidator";

        //private LocalizationMemoryCacheProvider CacheProvider;

        //protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        //private string PropertyName { get; set; }
        //public bool PropertyValue { get; set; }

        //public override string Name => throw new System.NotImplementedException();

        //public override bool IsValid(ValidationContext<T> context, IList<TCollectionElement> value)
        //{
        //    throw new System.NotImplementedException();
        //}public override string Name => throw new System.NotImplementedException();

        public override bool IsValid(ValidationContext<T> context, TProperty value)
        {
            throw new System.NotImplementedException();
        }

        protected override string GetDefaultMessageTemplate(string errorCode)=> "'{PropertyName}' must not be empty.";
    }
}
