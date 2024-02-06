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
    /// <see cref="ITagHelper"/> implementation targeting any element that include field-label-for elements.  
    /// </summary>
    [HtmlTargetElement(Attributes = LocalizationGlobalConstants.FieldLabelForAttributeName)]
    public class FieldLabelForTagHelper : TagHelper
    {
        private LocalizationMemoryCacheProvider CacheProvider;
        private readonly IServiceProvider _serviceProvider;

        /// <inheritdoc />
        public override int Order => -100;

        public string FieldLabelFor { get; set; }

        public FieldLabelForTagHelper(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            base.Process(context, output);

            CacheProvider = (LocalizationMemoryCacheProvider)_serviceProvider.GetService(typeof(LocalizationMemoryCacheProvider));
            string cultureName = Thread.CurrentThread.CurrentCulture.Name;
            string fieldLabelResource;

            // Check if the language is passed in from a reports page;
            if (FieldLabelFor.Contains(","))
            {
                string[] fieldLabelForSplit = FieldLabelFor.Split(",");
                fieldLabelResource = fieldLabelForSplit[0];
            }
            else
                fieldLabelResource = FieldLabelFor;

            string toolTipResource;
            if (fieldLabelResource.Contains(((long)InterfaceEditorTypeEnum.FieldLabel).ToString()) == false)
            {
                fieldLabelResource += (long)InterfaceEditorTypeEnum.FieldLabel;
                toolTipResource = fieldLabelResource + (long)InterfaceEditorTypeEnum.ToolTip;
            }
            else
                toolTipResource = fieldLabelResource.Replace(((long)InterfaceEditorTypeEnum.FieldLabel).ToString(), ((long)InterfaceEditorTypeEnum.ToolTip).ToString());

            string title = CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(cultureName, toolTipResource);
            if (title != string.Empty)
                output.Attributes.SetAttribute("title", title);

            output.Content.SetContent(CacheProvider.GetResourceValueByLanguageCultureNameAndResourceKey(cultureName, fieldLabelResource));
        }
    }
}