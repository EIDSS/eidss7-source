using System.Linq;
using System.Web;

namespace EIDSS.ClientLibrary.Extensions;

public static class QueryStringObjectExtension
{
    public static string ToQueryString(this object obj)
    {
        var properties = obj.GetType().GetProperties()
            .Select(p => new { property = p, value = p.GetValue(obj) })
            .Where(x => x.value != null)
            .Select(x => x.property.Name + "=" + HttpUtility.UrlEncode(x.value.ToString()))
            .ToList();

        return properties.Any() ? $"?{string.Join("&", properties.ToArray())}" : "";
    }
}