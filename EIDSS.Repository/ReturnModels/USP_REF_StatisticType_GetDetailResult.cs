﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_REF_StatisticType_GetDetailResult
    {
        public long? intRowNumber { get; set; }
        public long idfsBaseReference { get; set; }
        public long? idfsReferenceType { get; set; }
        public string strDisplayNameEnglish { get; set; }
        public string strDisplayNameNational { get; set; }
        public string strParameterTypeInfo { get; set; }
        public int? blnStatisticalAgeGroup { get; set; }
        public long idfsStatisticPeriodType { get; set; }
        public string strDisplayPeriodTypeEnglish { get; set; }
        public string strDisplayPeriodTypeNational { get; set; }
        public long idfsStatisticAreaType { get; set; }
        public string strDisplayAreaTypeEnglish { get; set; }
        public string strDisplayAreaTypeNational { get; set; }
        public bool? blnSystem { get; set; }
        public int intRowStatus { get; set; }
    }
}
