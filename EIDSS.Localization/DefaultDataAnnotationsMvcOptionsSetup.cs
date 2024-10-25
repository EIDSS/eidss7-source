using EIDSS.Localization.Constants;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.DataAnnotations;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System;
using System.Reflection;

namespace EIDSS.Localization
{
    internal class DefaultDataAnnotationsMvcOptionsSetup : IConfigureOptions<MvcOptions>
    {
        private readonly IStringLocalizerFactory _stringLocalizerFactory;
        private readonly IValidationAttributeAdapterProvider _validationAttributeAdapterProvider;
        private readonly IOptions<MvcDataAnnotationsLocalizationOptions> _dataAnnotationLocalizationOptions;

        public DefaultDataAnnotationsMvcOptionsSetup(
            IValidationAttributeAdapterProvider validationAttributeAdapterProvider,
            IOptions<MvcDataAnnotationsLocalizationOptions> dataAnnotationLocalizationOptions)
        {
            _validationAttributeAdapterProvider = validationAttributeAdapterProvider ?? throw new ArgumentNullException(nameof(validationAttributeAdapterProvider));
            _dataAnnotationLocalizationOptions = dataAnnotationLocalizationOptions ?? throw new ArgumentNullException(nameof(dataAnnotationLocalizationOptions));
        }

        public DefaultDataAnnotationsMvcOptionsSetup(
            IValidationAttributeAdapterProvider validationAttributeAdapterProvider,
            IOptions<MvcDataAnnotationsLocalizationOptions> dataAnnotationLocalizationOptions,
            IStringLocalizerFactory stringLocalizerFactory)
            : this(validationAttributeAdapterProvider, dataAnnotationLocalizationOptions)
        {
            _stringLocalizerFactory = stringLocalizerFactory;
        }

        public void Configure(MvcOptions options)
        {
            if (options == null)
            {
                throw new ArgumentNullException(nameof(options));
            }

            var type = typeof(EIDSSEntityResource);
            var assemblyName = new AssemblyName(type.GetTypeInfo().Assembly.FullName);

            var L = _stringLocalizerFactory.Create(nameof(EIDSSEntityResource), assemblyName.Name);
            options.ModelBindingMessageProvider.SetAttemptedValueIsInvalidAccessor((x, y) => L[ModelBindingMessageConstants.AttemptedValueIsInvalidAccessor, x, y]);
            options.ModelBindingMessageProvider.SetMissingBindRequiredValueAccessor((x) => L[ModelBindingMessageConstants.MissingBindRequiredValueAccessor, x]);
            options.ModelBindingMessageProvider.SetMissingKeyOrValueAccessor(() => L[ModelBindingMessageConstants.MissingKeyOrValueAccessor]);
            options.ModelBindingMessageProvider.SetUnknownValueIsInvalidAccessor((x) => L[ModelBindingMessageConstants.UnknownValueIsInvalidAccessor, x]);
            options.ModelBindingMessageProvider.SetValueIsInvalidAccessor((x) => L[ModelBindingMessageConstants.ValueIsInvalidAccessor]);
            options.ModelBindingMessageProvider.SetValueMustBeANumberAccessor((x) => L[ModelBindingMessageConstants.ValueMustBeANumberAccessor]);
            options.ModelBindingMessageProvider.SetValueMustNotBeNullAccessor((x) => L[ModelBindingMessageConstants.ValueMustNotBeNullAccessor, x]);
        }
    }
}