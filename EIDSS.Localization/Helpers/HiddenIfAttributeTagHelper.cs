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
    /// <see cref="ITagHelper"/> implementation targeting any element that include hidden-if elements.  
    /// </summary>
    [HtmlTargetElement(Attributes = LocalizationGlobalConstants.HiddenIfAttributeName)]
    public class HiddenIfAttributeTagHelper : TagHelper
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        private readonly IServiceProvider _serviceProvider;

        /// <inheritdoc />
        public override int Order => 100;

        protected static CultureInfo CurrentCulture => System.Threading.Thread.CurrentThread.CurrentCulture;

        public HiddenIfAttributeTagHelper(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        /// <summary>
        /// A value indicating whether to render the content inside the element.
        /// If <see cref="HiddenIf"/> is true, the content will not be rendered.
        /// </summary>
        [HtmlAttributeName(LocalizationGlobalConstants.HiddenIfAttributeName)]
        public string HiddenIf { get; set; }

        /// <inheritdoc />
        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }

            base.Process(context, output);

            CacheProvider = (LocalizationMemoryCacheProvider)_serviceProvider.GetService(typeof(LocalizationMemoryCacheProvider));

            string hiddenIfResource = HiddenIf;

            var dontRender = CacheProvider.GetHiddenResourceByLanguageCultureNameAndResourceKey(CurrentCulture.Name, hiddenIfResource);

            if (dontRender)
            {
                output.TagName = null;
                output.SuppressOutput();
            }
        }
    }
}