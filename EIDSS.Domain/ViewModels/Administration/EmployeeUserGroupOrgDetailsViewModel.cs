using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EmployeeUserGroupOrgDetailsViewModel
    {

        public long idfPerson { get; set; }
        public long? idfInstitution { get; set; }
        public string strOrganizationName { get; set; }
        public long? idfsSite { get; set; }
        public string SiteID { get; set; }
        public string SiteName { get; set; }
        public long? idfDepartment { get; set; }
        public string strDepartmentName { get; set; }
        public long? idfsStaffPosition { get; set; }
        public string strContactPhone { get; set; }
        public string strStaffPosition { get; set; }
        public string UserGroupID { get; set; }
        public string UserGroup { get; set; }
        public long idfUserID { get; set; }
    }
}
