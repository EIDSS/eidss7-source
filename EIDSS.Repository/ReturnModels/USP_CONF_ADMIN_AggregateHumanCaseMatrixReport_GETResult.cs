﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GETResult
    {
        public int? TotalRowCount { get; set; }
        public int? intNumRow { get; set; }
        public long? idfHumanCaseMtx { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string strDefault { get; set; }
        public string strIDC10 { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}