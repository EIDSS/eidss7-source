﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_EMPLOYEESFOREMPLOYEEGROUP_GETLISTResult
    {
        public int? TotalRowCount { get; set; }
        public long? idfEmployeeGroup { get; set; }
        public long? idfEmployee { get; set; }
        public long TypeID { get; set; }
        public string TypeName { get; set; }
        public string Name { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public long? idfUserID { get; set; }
        public string UserName { get; set; }
        public int? RowStatus { get; set; }
        public string RowAction { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
