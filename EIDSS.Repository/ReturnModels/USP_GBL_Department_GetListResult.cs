﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_GBL_Department_GetListResult
    {
        public int? TotalRowCount { get; set; }
        public long? DepartmentID { get; set; }
        public long? OrganizationID { get; set; }
        public string DepartmentNameDefaultValue { get; set; }
        public string DepartmentNameNationalValue { get; set; }
        public int? Order { get; set; }
        public int? RowStatus { get; set; }
        public string RowAction { get; set; }
        public int? RecordCount { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
