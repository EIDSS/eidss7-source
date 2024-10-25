using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class UserGroupDashboardViewModel
    {
        public long idfsBaseReference { get; set; }
        public string strBaseReferenceCode { get; set; }
        public string strDefault { get; set; }
        public string strName { get; set; }
        public string PageLink { get; set; }
        public string IconFileName { get; set; }
        public bool Selected { get; set; } = false;
        public bool ShowLink { get; set; } = true;
    }
}
