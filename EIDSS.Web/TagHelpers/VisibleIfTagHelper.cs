using Microsoft.AspNetCore.Razor.TagHelpers;
using System;

namespace EIDSS.Web.TagHelpers
{
    /// <summary>
    /// <see cref="ITagHelper"/> implementation targeting any element that include visible-if attributes.  
    /// </summary>
    [HtmlTargetElement(Attributes = "visible-if")]
    public class VisibleIfTagHelper : TagHelper
    {
        /// <inheritdoc />
        public override int Order => -200;

        /// <summary>
        /// A value indicating whether to render the content inside the element.
        /// If <see cref="Visible"/> is false, the content will not be rendered.
        /// </summary>
        [HtmlAttributeName("visible-if")]
        public string Visible { get; set; }

        /// <inheritdoc />
        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }

            if (output == null)
            {
                throw new ArgumentNullException(nameof(output));
            }

            output.Attributes.RemoveAll("visible-if");

            if (DontRender)
            {
                //TODO: make this an option?
                output.TagName = null;
                output.SuppressOutput();
            }
        }

        private bool DontRender => Visible == "False";
    }
}