﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_GBL_BASE_REFERENCE_GETListResult
    {
        public long idfsBaseReference { get; set; }
        public long idfsReferenceType { get; set; }
        public string strBaseReferenceCode { get; set; }
        public string strDefault { get; set; }
        public string name { get; set; }
        public int? intHACode { get; set; }
        public int? intOrder { get; set; }
        public int intRowStatus { get; set; }
        public bool? blnSystem { get; set; }
        public long? intDefaultHACode { get; set; }
        public string strHACode { get; set; }
        public long? EditorSettings { get; set; }
    }
}
