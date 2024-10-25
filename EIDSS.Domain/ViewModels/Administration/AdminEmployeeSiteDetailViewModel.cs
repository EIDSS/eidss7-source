using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AdminEmployeeSiteDetailsViewModel 
    {
        public long idfUserID { get; set; }
        public string strIdentity { get; set; }
        public long? idfPerson { get; set; }
        public long idfsSite { get; set; }
        public string strAccountName { get; set; }
        public string strSiteID { get; set; }
        public string strSiteName { get; set; }
        public long? idfsSiteType { get; set; }
        public string strSiteType { get; set; }
        public int Locked { get; set; }
        public bool? blnDisabled { get; set; }
        public string strDisabledReason { get; set; }
        public string strLockoutReason { get; set; }
        public string UserGroupID { get; set; }
        public string UserGroup { get; set; }
        public bool PasswordResetRequired { get; set; }
        public DateTime? DateDisabled { get; set; }

    }
}
