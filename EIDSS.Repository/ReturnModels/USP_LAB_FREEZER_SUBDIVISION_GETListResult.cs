﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_LAB_FREEZER_SUBDIVISION_GETListResult
    {
        public long FreezerSubdivisionID { get; set; }
        public long? SubdivisionTypeID { get; set; }
        public string SubdivisionTypeName { get; set; }
        public long FreezerID { get; set; }
        public string FreezerName { get; set; }
        public string Building { get; set; }
        public string FreezerNote { get; set; }
        public long? StorageTypeID { get; set; }
        public string FreezerBarCode { get; set; }
        public string Room { get; set; }
        public long? ParentFreezerSubdivisionID { get; set; }
        public long OrganizationID { get; set; }
        public string EIDSSFreezerSubdivisionID { get; set; }
        public string FreezerSubdivisionName { get; set; }
        public string SubdivisionNote { get; set; }
        public int? NumberOfLocations { get; set; }
        public long? BoxSizeTypeID { get; set; }
        public string BoxSizeTypeName { get; set; }
        public string BoxPlaceAvailability { get; set; }
        public int? SampleCount { get; set; }
        public int RowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
