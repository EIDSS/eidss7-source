using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace EIDSS.Domain.ViewModels
{
    public class MenuByUserViewModel
    {
        public long idfEmployee { get; set; }
        public long EIDSSMenuId { get; set; }
        public string MenuName { get; set; }
        public long EIDSSParentMenuId { get; set; }
        public string strParentMenuName { get; set; }
        public string Controller { get; set; }
        public string strAction { get; set; }
        public string Area { get; set; }
        public string SubArea { get; set; }
        public int? intOrder { get; set; }

        public string DecodedController
        {
            get
            {
                if (string.IsNullOrEmpty(Controller))
                {
                    return Controller;
                }
                else
                {
                    return HttpUtility.UrlDecode(Controller);
                }
            }
        }


        public string DecodedStrAction
        {
            get
            {
                if (string.IsNullOrEmpty(strAction))
                {
                    return strAction;
                }
                else
                {
                    return HttpUtility.UrlDecode(strAction);
                }
            }
        }
    }
}
