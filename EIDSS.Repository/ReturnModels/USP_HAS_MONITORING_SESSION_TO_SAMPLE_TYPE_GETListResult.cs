﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_HAS_MONITORING_SESSION_TO_SAMPLE_TYPE_GETListResult
    {
        public int? TotalRowCount { get; set; }
        public long? MonitoringSessionToSampleType { get; set; }
        public long? MonitoringSessionToDiagnosisID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public int? OrderNumber { get; set; }
        public int? RowStatus { get; set; }
        public string RowAction { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
