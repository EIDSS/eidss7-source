using EIDSS.Web.Enumerations;
using System.ComponentModel;

namespace EIDSS.Web.Extensions
{
    /// <summary>
    /// Extension that allows the caller to get the enum description.
    /// </summary>
    public static class DocumentContainerTypeEnumExtension
    {
        public static string ToEnumString(this DocumentContainerTypeEnum val)
        {
            DescriptionAttribute[] attributes = (DescriptionAttribute[])val
               .GetType()
               .GetField(val.ToString())
               .GetCustomAttributes(typeof(DescriptionAttribute), false);
            return attributes.Length > 0 ? attributes[0].Description : string.Empty;
        }
    }

    /// <summary>
    /// Extension that allows the caller to get the enum description.
    /// </summary>
    public static class ParentDocumentContainerTypeEnumExtension
    {
        public static string ToEnumString(this ParentDocumentContainerTypeEnum val)
        {
            DescriptionAttribute[] attributes = (DescriptionAttribute[])val
               .GetType()
               .GetField(val.ToString())
               .GetCustomAttributes(typeof(DescriptionAttribute), false);
            return attributes.Length > 0 ? attributes[0].Description : string.Empty;
        }
    }
}
