﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_GBL_SecurityEventLog_GetListResult
    {
        public long idfSecurityAudit { get; set; }
        public long idfsAction { get; set; }
        public string strActionDefaultName { get; set; }
        public string strActionNationalName { get; set; }
        public long idfsResult { get; set; }
        public string strResultDefaultName { get; set; }
        public string strResultNationalName { get; set; }
        public long idfsProcessType { get; set; }
        public string strProcessTypeDefaultName { get; set; }
        public string strProcessTypeNationalName { get; set; }
        public long idfAffectedObjectType { get; set; }
        public long idfObjectID { get; set; }
        public long? idfUserID { get; set; }
        public long idfPerson { get; set; }
        public string strAccountName { get; set; }
        public string strPersonName { get; set; }
        public long? idfDataAuditEvent { get; set; }
        public DateTime? datActionDate { get; set; }
        public string strErrorText { get; set; }
        public string strProcessID { get; set; }
        public string strDescription { get; set; }
        public int? TotalRowCount { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
