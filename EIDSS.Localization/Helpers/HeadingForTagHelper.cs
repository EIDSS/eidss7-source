#region Using Statements

using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Threading;

#endregion

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// <see cref="ITagHelper"/> implementation targeting any element that include heading-for elements.  
    /// </summary>
    [HtmlTargetElement(Attributes = LocalizationGlobalConstants.HeadingForAttributeName)]
    public class HeadingForTagHelper : TagHelper
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        private readonly IServiceProvider _serviceProvider;

        public string HeadingFor { get; set; }

        public HeadingForTagHelper(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            base.Process(context, output);

            CacheProvider = (LocalizationMemoryCacheProvider)_serviceProvider.GetService(typeof(LocalizationMemoryCacheProvider));
            string cultureName = Thread.CurrentThread.CurrentCulture.Name;
            string headingResource;

            // Check if the language is passed in from a reports page;
            if (HeadingFor.Contains(","))
            {
                string[] headingForSplit = HeadingFor.Split(",");
                headingResource = headingForSplit[0];
            }
            else
                headingResource = HeadingFor;

            string toolTipResource;
            if (headingResource.Contains(((long)InterfaceEditorTypeEnum.Heading).ToString()) == false)
            {
                headingResource += (long)InterfaceEditorTypeEnum.Heading;
                toolTipResource = headingResource + (long)InterfaceEditorTypeEnum.ToolTip;
            }
            else
                toolTipResource = headingResource.Replace(((long)InterfaceEditorTypeEnum.Heading).ToString(), ((long)InterfaceEditorTypeEnum.ToolTip).ToString());

            string title = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(cultureName, toolTipResource);
            if (title != string.Empty)
                output.Attributes.SetAttribute("title", title);

            output.Content.SetContent(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(cultureName, headingResource));
        }
    }
}