﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VET_PENSIDE_TEST_GETListResult
    {
        public long PensideTestID { get; set; }
        public long SampleID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string SampleTypeName { get; set; }
        public long? SpeciesID { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? AnimalID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public long? PensideTestResultTypeID { get; set; }
        public long? OriginalPensideTestResultTypeID { get; set; }
        public string PensideTestResultTypeName { get; set; }
        public long? PensideTestNameTypeID { get; set; }
        public string PensideTestNameTypeName { get; set; }
        public int RowStatus { get; set; }
        public long? TestedByPersonID { get; set; }
        public string TestedByPersonName { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseIDC10Code { get; set; }
        public DateTime? TestDate { get; set; }
        public long? PensideTestCategoryTypeID { get; set; }
        public string PensideTestCategoryTypeName { get; set; }
        public string Species { get; set; }
        public int RowAction { get; set; }
        public int? RowCount { get; set; }
        public int? TotalRowCount { get; set; }
        public int? CurrentPage { get; set; }
        public int? TotalPages { get; set; }
    }
}
