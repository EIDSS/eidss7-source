﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_EMP_ORGANIZATION_USER_GROUP_GETDetailResult
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
