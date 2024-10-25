using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SamplesSaveRequestModel
    {
        public long SampleID { get; set; }
        public long SampleTypeID { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public long? HumanMasterID { get; set; }
        public long? HumanID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? FarmID { get; set; }
        public long? SpeciesID { get; set; }
        public long? AnimalID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? CollectedByPersonID { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public long? MainTestID { get; set; }
        public DateTime? CollectionDate { get; set; }
        public DateTime? SentDate { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? VectorID { get; set; }
        public long? FreezerSubdivisionID { get; set; }
        public string StorageBoxPlace { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public long? PreviousSampleStatusTypeID { get; set; }
        public long? FunctionalAreaID { get; set; }
        public long? DestroyedByPersonID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? DestructionDate { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public string Comment { get; set; }
        public long? SiteID { get; set; }
        public int RowStatus { get; set; }
        public long? SentToOrganizationID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public string AccessionComment { get; set; }
        public long? AccessionByPersonID { get; set; }
        public long? DestructionMethodTypeID { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? SampleKindTypeID { get; set; }
        public long? MarkedForDispositionByPersonID { get; set; }
        public DateTime? OutOfRepositoryDate { get; set; }
        public long? DiseaseID { get; set; }
        public long? VectorTypeID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public bool FavoriteIndicator { get; set; }
        public int RowAction { get; set; }
    }
}