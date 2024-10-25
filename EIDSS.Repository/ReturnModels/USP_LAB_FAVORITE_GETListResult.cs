using System;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_LAB_FAVORITE_GETListResult
    {
        public long SampleID { get; set; }
        public long SiteID { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? TestID { get; set; }
        public long? TransferID { get; set; }
        public string? EIDSSReportOrSessionID { get; set; }
        public string? PatientOrFarmOwnerName { get; set; }
        public long SampleTypeID { get; set; }
        public string? SampleTypeName { get; set; }
        public string? DiseaseID { get; set; }
        public string? DiseaseName { get; set; }
        public string? DisplayDiseaseName { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public string? EIDSSLaboratorySampleID { get; set; }
        public string? EIDSSLocalOrFieldSampleID { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByPersonID { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public DateTime? SentDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public long? TestNameTypeID { get; set; }
        public string? TestNameTypeName { get; set; }
        public long? TestStatusTypeID { get; set; }
        public string? TestStatusTypeName { get; set; }
        public DateTime? StartedDate { get; set; }
        public long? TestResultTypeID { get; set; }
        public string? TestResultTypeName { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public string? TestCategoryTypeName { get; set; }
        public int AccessionIndicator { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string? FunctionalAreaName { get; set; }
        public long? FreezerSubdivisionID { get; set; }
        public string? StorageBoxPlace { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? OutOfRepositoryDate { get; set; }
        public long? MarkedForDispositionByPersonID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string? AccessionConditionOrSampleStatusTypeName { get; set; }
        public long? AccessionedInByPersonID { get; set; }
        public DateTime? SampleStatusDate { get; set; }
        public string? AccessionComment { get; set; }
        public string? Comment { get; set; }
        public string? EIDSSAnimalID { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public long? MainTestID { get; set; }
        public long? SampleKindTypeID { get; set; }
        public long? BatchStatusTypeID { get; set; }
        public bool? TestAssignedIndicator { get; set; }
        public long? ActionRequestedID { get; set; }
        public string? ActionRequested { get; set; }
        public bool? TestCompletedIndicator { get; set; }
        public long? PreviousSampleStatusTypeID { get; set; }
        public long? PreviousTestStatusTypeID { get; set; }
        public int LabModuleSourceIndicator { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? VectorID { get; set; }
        public bool? ReadPermissionindicator { get; set; }
        public bool? AccessToPersonalDataPermissionIndicator { get; set; }
        public bool? AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool? WritePermissionIndicator { get; set; }
        public bool? DeletePermissionIndicator { get; set; }
        public int RowAction { get; set; }
        public int RowSelectionIndicator { get; set; }
        public int? TotalRowCount { get; set; }
        public int? FavoriteCount { get; set; }
    }
}
