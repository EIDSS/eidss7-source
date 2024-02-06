using System;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class SampleGetDetailViewModel
    {
        public long SampleID { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public int FavoriteIndicator { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public string ParentLaboratorySampleEIDSSID { get; set; }
        public long SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public long? HumanID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public long? SpeciesID { get; set; }
        public long? AnimalID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public long? VectorID { get; set; }
        public string PatientSpeciesVectorInformation { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? VeterinaryReportTypeID { get; set; }
        public string EIDSSReportOrSessionID { get; set; }
        public string ReportSessionTypeName { get; set; }
        public int TestCompletedIndicator { get; set; }
        public string DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }
        public long? FreezerSubdivisionID { get; set; }
        public string StorageBoxPlace { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByPersonID { get; set; }
        public string CollectedByPersonName { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public string CollectedByOrganizationName { get; set; }
        public DateTime? SentDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string SentToOrganizationName { get; set; }
        public long SiteID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string EIDSSLaboratoryOrLocalFieldSampleID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? OutOfRepositoryDate { get; set; }
        public long? MarkedForDispositionByPersonID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public int AccessionIndicator { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        public long? AccessionByPersonID { get; set; }
        public string AccessionByPersonName { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string AccessionComment { get; set; }
        public long? DestructionMethodTypeID { get; set; }
        public string DestructionMethodTypeName { get; set; }
        public DateTime? DestructionDate { get; set; }
        public long? DestroyedByPersonID { get; set; }
        public int TestAssignedCount { get; set; }
        public int? TransferredCount { get; set; }
        public string Comment { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public long? MainTestID { get; set; }
        public long? SampleKindTypeID { get; set; }
        public long? PreviousSampleStatusTypeID { get; set; }
        public int LabModuleSourceIndicator { get; set; }
        public int RowStatus { get; set; }
    }
}
