using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Dashboard
{
    public class DashboardUsersGetRequestModel : BaseGetRequestModel
    {
        public string SiteList { get; set; }        
    }
}
