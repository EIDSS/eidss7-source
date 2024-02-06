using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.TagHelpers.Models
{
    public enum EditType
    {
        [Description("In line Edidt")]
        None,
        [Description("In line Edidt")]
        Inline,
        [Description("Page Redirect for Record Details View")]
        PageRedirect,
        [Description("Popup Edit")]
        Popup,
        [Description(" Edit Page Redirect for Record Details View")]
        EditPageRedirect,
    }
}
