using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Dashboard
{
    public class DashboardLinksGetRequestModel
    {
        public string LanguageID { get; set; }
        public long PersonID { get; set; }
	    public string DashboardItemType { get; set; }    
    }
}
