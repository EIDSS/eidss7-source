using Microsoft.AspNetCore.Mvc.Routing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Helpers
{
    /// <summary>  
    /// this is simillar to this https://github.com/aspnet/Mvc/blob/dev/src/Microsoft.AspNetCore.Mvc.Core/AreaAttribute.cs  
    /// </summary>  
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public class SubAreaAttribute : RouteValueAttribute
    {
        public SubAreaAttribute(string subAreaName)
            : base("subarea", subAreaName)
        {
            if (string.IsNullOrEmpty(subAreaName))
            {
                throw new ArgumentException("Sub area name cannot be null or empty", nameof(subAreaName));
            }
        }
    }
}
