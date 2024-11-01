﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_LAB_TRANSFER_ADVANCED_SEARCH_GETListResult
    {
        public long TransferID { get; set; }
        public string EIDSSTransferID { get; set; }
        public long TransferredOutSampleID { get; set; }
        public long? TransferredInSampleID { get; set; }
        public int FavoriteIndicator { get; set; }
        public string EIDSSReportOrSessionID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public long? TransferredToOrganizationID { get; set; }
        public string TransferredToOrganizationName { get; set; }
        public long? TransferredFromOrganizationID { get; set; }
        public DateTime? TransferDate { get; set; }
        public string TestRequested { get; set; }
        public long? TestID { get; set; }
        public long? TestNameTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public long? TestResultTypeID { get; set; }
        public string TestResultTypeName { get; set; }
        public long? TestStatusTypeID { get; set; }
        public string TestStatusTypeName { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long? TestDiseaseID { get; set; }
        public DateTime? StartedDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public string ContactPersonName { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string SampleTypeName { get; set; }
        public string DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }
        public int AccessionIndicator { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        public string AccessionComment { get; set; }
        public string PurposeOfTransfer { get; set; }
        public long TransferredFromOrganizationSiteID { get; set; }
        public long? SentToOrganizationID { get; set; }
        public long? SentByPersonID { get; set; }
        public long TransferStatusTypeID { get; set; }
        public int RowStatus { get; set; }
        public string EIDSSAnimalID { get; set; }
        public int TestAssignedIndicator { get; set; }
        public int NonEIDSSLaboratoryIndicator { get; set; }
        public bool? ReadPermissionindicator { get; set; }
        public bool? AccessToPersonalDataPermissionIndicator { get; set; }
        public bool? AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool? WritePermissionIndicator { get; set; }
        public bool? DeletePermissionIndicator { get; set; }
        public int RowAction { get; set; }
        public int RowSelectionIndicator { get; set; }
        public int? InProgressCount { get; set; }
        public int TotalRowCount { get; set; }
    }
}
