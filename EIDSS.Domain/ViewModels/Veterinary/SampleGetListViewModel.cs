using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class SampleGetListViewModel : BaseModel
    {
        public SampleGetListViewModel ShallowCopy()
        {
            return (SampleGetListViewModel)MemberwiseClone();
        }

        public long SampleID { get; set; }
        public long? SampleIDOriginal { get; set; }
        public long SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public long? RootSampleID { get; set; }
        public long? ParentSampleID { get; set; }
        public long? HumanID { get; set; }
        public long? HumanMasterID { get; set; }
        public string EIDSSPersonID { get; set; }
        public string HumanName { get; set; }
        public string PersonAddress { get; set; }
        public long? SpeciesID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? AnimalID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public long? AnimalGenderTypeID { get; set; }
        public string AnimalGenderTypeName { get; set; }
        public long? AnimalAgeTypeID { get; set; }
        public string AnimalAgeTypeName { get; set; }
        public string AnimalColor { get; set; }
        public string AnimalName { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? CollectedByPersonID { get; set; }
        public string CollectedByPersonName { get; set; }
        public long? CollectedByOrganizationID { get; set; }
        public string CollectedByOrganizationName { get; set; }
        public long? MainTestID { get; set; }
        public string TestDiseaseName { get; set; }
        public string TestNameTypeName { get; set; }
        public string TestResultTypeName { get; set; }
        public DateTime? CollectionDate { get; set; }
        public DateTime? SentDate { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string EIDSSReportOrSessionID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public long? VectorSessionID { get; set; }
        public long? VectorID { get; set; }
        public long? FreezerID { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string SampleStatusTypeName { get; set; }
        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }
        public long? DestroyedByPersonID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? DestructionDate { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public string Comments { get; set; }
        public long SiteID { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string SentToOrganizationName { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public long? BirdStatusTypeID { get; set; }
        public string BirdStatusTypeName { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public string AccessionConditionTypeName { get; set; }
        public string AccessionComment { get; set; }
        public long? AccessionByPersonID { get; set; }
        public long? DestructionMethodTypeID { get; set; }
        public long? CurrentSiteID { get; set; }
        public long? SampleKindTypeID { get; set; }
        public string SampleKindTypeName { get; set; }
        public int AccessionedIndicator { get; set; }
        public int ShowInReportSessionListIndicator { get; set; }
        public int ShowInLaboratoryListIndicator { get; set; }
        public int ShowInDispositionListIndicator { get; set; }
        public int ShowInAccessionListIndicator { get; set; }
        public long? MarkedForDispositionByPersonID { get; set; }
        public DateTime? OutOfRepositoryDate { get; set; }
        public DateTime? SampleStatusDate { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseNames { get; set; }
        public IEnumerable<long> SelectedDiseases { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public string EIDSSFarmID { get; set; }
        public string Species { get; set; }
        public string EIDSSLaboratoryOrLocalFieldSampleID { get; set; }
        public int LabModuleSourceIndicator { get; set; }
        public bool ImportIndicator { get; set; }
        public int TotalAnimalsSampled { get; set; }
        public int TotalSamples { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
        public int TestsCount { get; set; }
    }
}