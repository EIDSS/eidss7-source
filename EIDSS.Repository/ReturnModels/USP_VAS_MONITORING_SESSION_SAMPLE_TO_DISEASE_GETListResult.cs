﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VAS_MONITORING_SESSION_SAMPLE_TO_DISEASE_GETListResult
    {
        public long MonitoringSessionToMaterialID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long SampleID { get; set; }
        public long SampleTypeID { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
    }
}
