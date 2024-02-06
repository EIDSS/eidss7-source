using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EmployeeUserGroupsAndPermissionsViewModel
    {
        public long? Row { get; set; }
        public long? idfsSite { get; set; }
        public string SiteID { get; set; }
        public string SiteName { get; set; }
        public long? OrganizationID { get; set; }
        public string Organization { get; set; }
        public string OrganizationFullName { get; set; }
        public string UserGroupID { get; set; }
        public string UserGroup { get; set; }
        public long? idfEmployee { get; set; }
        public int STATUS { get; set; }
        public bool? Active { get; set; }
        public bool? IsDefault { get; set; }
        public long idfUserID { get; set; }
        public long? SiteTypeID { get; set; }
        public int? SiteGroupID { get; set; }
        public string SiteGroupList { get; set; }

    }
}
