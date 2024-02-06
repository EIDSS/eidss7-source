using Microsoft.AspNetCore.Razor.TagHelpers;


namespace EIDSS.Web.TagHelpers
{
    [HtmlTargetElement(Attributes = nameof(Condition))]
    public class AuthoringTagHelpers : TagHelper
    {
        public bool Condition { get; set; }

        public override void Process(TagHelperContext context, TagHelperOutput output)
        {
            if (!Condition)
            {
                output.SuppressOutput();
            }
        }
    }
}
