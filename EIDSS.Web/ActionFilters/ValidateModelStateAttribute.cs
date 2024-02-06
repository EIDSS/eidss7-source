using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Routing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ActionFilters
{
    public class ValidateModelStateAttribute : ActionFilterAttribute
    {
       
         public string RedirectToController { get; set; }

        public string RedirectToAction { get; set; }

        public string RedirectToPage { get; set; }


        public override void OnActionExecuting(ActionExecutingContext context)
        {
            if (!context.ModelState.IsValid)
            {
                context.Result = new RedirectToRouteResult(ConstructRouteValueDictionary());
            }
        }

        #region Private Methods

        private RouteValueDictionary ConstructRouteValueDictionary()
        {
            var dict = new RouteValueDictionary();

            if (!string.IsNullOrWhiteSpace(RedirectToPage))
            {
                dict.Add("page", RedirectToPage);
            }
            // Assuming RedirectToController & RedirectToAction are set
            else
            {
                dict.Add("controller", RedirectToController);
                dict.Add("action", RedirectToAction);
            }

            return dict;
        }

        #endregion
    }
}