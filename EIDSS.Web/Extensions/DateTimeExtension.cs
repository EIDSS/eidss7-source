using System;

namespace EIDSS.Web.Extensions;

public static class DateTimeExtension
{
    public static bool IsLaterThan(this DateTime current, DateTime? compareDate)
    {
        return compareDate != null && current.Date > compareDate.Value.Date;
    }
    
    public static bool IsEarlierThan(this DateTime current, DateTime? compareDate)
    {
        return compareDate != null && current.Date < compareDate.Value.Date;
    }
}