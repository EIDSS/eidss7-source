﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResult
    {
        public long idfsVSSessionSummaryDiagnosis { get; set; }
        public long idfsVSSessionSummary { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public int? intPositiveQuantity { get; set; }
        public Guid rowguid { get; set; }
        public int intRowStatus { get; set; }
        public int? TotalRowCount { get; set; }
    }
}
