using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update, DataAuditObjectTypeEnum.Sample)]
    public class SampleSaveRequestModel
    {
        [Required]
        public long SampleID { get; set; }
        public long? SampleTypeID { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public long? HumanMasterID { get; set; }
        public long? HumanID { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? SpeciesID { get; set; }
        public long? AnimalID { get; set; }
        public long? VectorID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public long? CollectedByPersonID { get; set; }
        public DateTime? SentDate { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string Comments { get; set; }
        [Required]
        public long SiteID { get; set; }
        public long? CurrentSiteID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public long? DiseaseID { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public bool? ReadOnlyIndicator { get; set; }
        public int LabModuleSourceIndicator { get; set; }
        [Required]
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}