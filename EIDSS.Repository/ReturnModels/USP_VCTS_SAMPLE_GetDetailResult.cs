﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VCTS_SAMPLE_GetDetailResult
    {
        public long? idfVector { get; set; }
        public long idfsVectorType { get; set; }
        public long idfsVectorSubType { get; set; }
        public long idfMaterial { get; set; }
        public string strBarcode { get; set; }
        public string strFieldBarcode { get; set; }
        public long idfsSampleType { get; set; }
        public string strSampleName { get; set; }
        public DateTime? datFieldCollectionDate { get; set; }
        public long? idfSendToOffice { get; set; }
        public string strSendToOffice { get; set; }
        public long? idfFieldCollectedByOffice { get; set; }
        public string strFieldCollectedByOffice { get; set; }
        public DateTime? datFieldSentDate { get; set; }
        public string strNote { get; set; }
        public DateTime? datAccession { get; set; }
        public long? idfsAccessionCondition { get; set; }
        public string strCondition { get; set; }
        public long? idfCase { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }
        public string strVectorTypeName { get; set; }
        public string strVectorSubTypeName { get; set; }
        public long? idfsRegion { get; set; }
        public string strRegionName { get; set; }
        public long? idfsRayon { get; set; }
        public string strRayonName { get; set; }
        public int intQuantity { get; set; }
        public DateTime datCollectionDateTime { get; set; }
        public string strVectorID { get; set; }
        public int Used { get; set; }
        public long? DiseaseID { get; set; }
    }
}