﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VCTS_LABTEST_GetListResult
    {
        public long idfTesting { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public string strFieldSampleID { get; set; }
        public string strSampleTypeName { get; set; }
        public string strSpeciesName { get; set; }
        public string strTestName { get; set; }
        public string strTestResultName { get; set; }
        public DateTime? datConcludedDate { get; set; }
        public string strDiseaseName { get; set; }
        public int? TotalRowCount { get; set; }
    }
}
