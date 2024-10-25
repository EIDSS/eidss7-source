#region Using Statements

using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Extensions;
using EIDSS.Localization.Providers;
using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Globalization;
using System.Threading;

#endregion

namespace EIDSS.Localization.Helpers
{
    /// <summary>
    /// <see cref="ITagHelper"/> implementation targeting any element that include button-for elements.  
    /// </summary>
    [HtmlTargetElement(Attributes = LocalizationGlobalConstants.ButtonForAttributeName)]
    public class ButtonForTagHelper : TagHelper
    {
        /// <inheritdoc />
        public override int Order => -300;

        private LocalizationMemoryCacheProvider CacheProvider;
        private readonly IServiceProvider _serviceProvider;

        public string ButtonFor { get; set; }

        public ButtonForTagHelper(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            base.Process(context, output);

            CacheProvider = (LocalizationMemoryCacheProvider)_serviceProvider.GetService(typeof(LocalizationMemoryCacheProvider));
            string buttonTextResource;
            string cultureName = Thread.CurrentThread.CurrentCulture.Name;
            string toolTipResource;

            // Check if the language is passed in from a reports page;
            if (ButtonFor.Contains(","))
            {
                string[] buttonForSplit = ButtonFor.Split(",");
                buttonTextResource = buttonForSplit[0];
            }
            else
                buttonTextResource = ButtonFor;

            if (buttonTextResource.Contains(((long)InterfaceEditorTypeEnum.ButtonText).ToString()) == false)
            {
                buttonTextResource += (long)InterfaceEditorTypeEnum.ButtonText;
                toolTipResource = buttonTextResource + (long)InterfaceEditorTypeEnum.ToolTip;
            }
            else
                toolTipResource = buttonTextResource.Replace(((long)InterfaceEditorTypeEnum.ButtonText).ToString(), ((long)InterfaceEditorTypeEnum.ToolTip).ToString());

            string title = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(cultureName, toolTipResource);
            if (title != string.Empty)
                output.Attributes.SetAttribute("title", title);

            output.Content.SetContent(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(cultureName, buttonTextResource));
        }
    }
}