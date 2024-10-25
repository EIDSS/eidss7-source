using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class SiteModel : BaseModel
    {
        public string siteName { get; set; }
        public string strSiteID { get; set; }
        public long idfsSite { get; set; }
    }

}
