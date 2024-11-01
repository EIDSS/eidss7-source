﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_LAB_TEST_GETDetailResult
    {
        public long TestID { get; set; }
        public long? TestNameTypeID { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long? TestResultTypeID { get; set; }
        public long TestStatusTypeID { get; set; }
        public long? PreviousTestStatusTypeID { get; set; }
        public long DiseaseID { get; set; }
        public long SampleID { get; set; }
        public long? BatchTestID { get; set; }
        public long? ObservationID { get; set; }
        public int? TestNumber { get; set; }
        public string Note { get; set; }
        public DateTime? StartedDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? TestedByPersonID { get; set; }
        public long? ResultEnteredByOrganizationID { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public string ResultEnteredByPersonName { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public string ValidatedByPersonName { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public bool NonLaboratoryTestIndicator { get; set; }
        public bool? ExternalTestIndicator { get; set; }
        public long? PerformedByOrganizationID { get; set; }
        public DateTime? ReceivedDate { get; set; }
        public string ContactPersonName { get; set; }
        public string DiseaseName { get; set; }
        public string TestNameTypeName { get; set; }
        public string TestStatusTypeName { get; set; }
        public string TestResultTypeName { get; set; }
        public string TestCategoryTypeName { get; set; }
        public long? TransferID { get; set; }
        public int RowStatus { get; set; }
    }
}
