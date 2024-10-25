using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Globalization;

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// <see cref="ITagHelper"/> implementation targeting any element that include required-if elements.  
    /// </summary>
    [HtmlTargetElement(Attributes = LocalizationGlobalConstants.RequiredIfAttributeName)]
    public class RequiredIfAttributeTagHelper : TagHelper
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        private readonly IServiceProvider _serviceProvider;

        /// <inheritdoc />
        public override int Order => 100;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public RequiredIfAttributeTagHelper(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        /// <summary>
        /// A value indicating whether to render the content inside the element.
        /// If <see cref="HiddenIf"/> is true, the content will not be rendered.
        /// </summary>
        [HtmlAttributeName(LocalizationGlobalConstants.RequiredIfAttributeName)]
        public string RequiredIf { get; set; }

        /// <inheritdoc />
        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }

            base.Process(context, output);

            CacheProvider = (LocalizationMemoryCacheProvider)_serviceProvider.GetService(typeof(LocalizationMemoryCacheProvider));

            string requiredIfResource = RequiredIf;
            //if (RequiredIf.Contains(((long)InterfaceEditorTypeEnum.Required).ToString()) == false)
            //    requiredIfResource = RequiredIf + (long)InterfaceEditorTypeEnum.Required;

            string DontRender = CacheProvider.GetRequiredResourceValueByLanguageCultureNameAndResourceKey(CurrentCulture.Name, requiredIfResource);

            // If required resource value is not set to true, then do not render the content.
            if (DontRender != null)
            {
                if (DontRender.ToLower() != LocalizationGlobalConstants.TrueResourceValue)
                {
                    output.TagName = null;
                    output.SuppressOutput();
                }
            }
        }
    }
}