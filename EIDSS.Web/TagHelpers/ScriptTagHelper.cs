﻿using Microsoft.AspNetCore.Razor.TagHelpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.TagHelpers
{
    public class ScriptTagHelper : TagHelperComponent
    {
        private readonly string _javascript;
        public ScriptTagHelper(string javascript = "")
        {
            _javascript = javascript;
        }
        public override Task ProcessAsync(TagHelperContext context, TagHelperOutput output)
        {
            if (string.Equals(context.TagName, "body", StringComparison.Ordinal))
            {
                output.PostContent.AppendHtml($"<script type='text/javascript'>{_javascript}</script>");
            }
            return Task.CompletedTask;
        }
    }
}
