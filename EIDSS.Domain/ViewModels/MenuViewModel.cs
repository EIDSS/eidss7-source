using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace EIDSS.Domain.ViewModels
{
    public class MenuViewModel : BaseModel
    {
        public long idfsBaseReference { get; set; }
        public string MenuName { get; set; }
        public long idfsReferenceType { get; set; }
        public long EIDSSMenuId { get; set; }
        public long EIDSSParentMenuId { get; set; }
        public string PageName { get; set; }
        public long? PageTitleID { get; set; }
        public string PageLink { get; set; }
        public string ExceptionControlList { get; set; }
        public int? DisplayOrder { get; set; }
        public string IsOpenInNewWindow { get; set; }
        public string AppModuleGroupList { get; set; }
        public string Controller { get; set; }
        public string strAction { get; set; }
        public string Area { get; set; }
        public string SubArea { get; set; }

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


        public string DecodedStrAction {
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
