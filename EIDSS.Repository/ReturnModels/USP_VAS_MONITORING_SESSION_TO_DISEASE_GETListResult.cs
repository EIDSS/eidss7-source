﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VAS_MONITORING_SESSION_TO_DISEASE_GETListResult
    {
        public long MonitoringSessionToDiseaseID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? DiseaseUsingType { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public int? AvianOrLivestock { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public int OrderNumber { get; set; }
        public int RowStatus { get; set; }
        public int? RecordCount { get; set; }
        public int RowAction { get; set; }
    }
}