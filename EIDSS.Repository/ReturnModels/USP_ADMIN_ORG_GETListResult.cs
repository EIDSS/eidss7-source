﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_ADMIN_ORG_GETListResult
    {
        public long OrganizationKey { get; set; }
        public string OrganizationID { get; set; }
        public string AbbreviatedName { get; set; }
        public string FullName { get; set; }
        public int? Order { get; set; }
        public string AddressString { get; set; }
        public string OrganizationTypeName { get; set; }
        public int? AccessoryCode { get; set; }
        public long? SiteID { get; set; }
        public int RowStatus { get; set; }
        public int? RowCount { get; set; }
        public int? TotalRowCount { get; set; }
        public int? CurrentPage { get; set; }
        public int? TotalPages { get; set; }
    }
}