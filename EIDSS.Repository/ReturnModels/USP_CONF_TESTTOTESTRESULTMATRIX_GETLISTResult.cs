﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_CONF_TESTTOTESTRESULTMATRIX_GETLISTResult
    {
        public int? TotalRowCount { get; set; }
        public long? idfsTestName { get; set; }
        public string strTestNameDefault { get; set; }
        public string strTestName { get; set; }
        public long? idfsTestResult { get; set; }
        public string strTestResultDefault { get; set; }
        public string strTestResultName { get; set; }
        public bool? blnIndicative { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}