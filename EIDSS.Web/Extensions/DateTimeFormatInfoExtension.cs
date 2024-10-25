using System.Globalization;

namespace EIDSS.Web.Extensions;

public static class DateTimeFormatInfoExtension
{
    public static string ToJavascriptShortDatePattern(this DateTimeFormatInfo dateTimeFormat)
    {
        return dateTimeFormat.ShortDatePattern
            .Replace("M", "m")
            .Replace("yy", "y");
    }
}