using System;
using System.Collections.Generic;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionAggregateViewModel : BaseModel
    {
        public VeterinaryActiveSurveillanceSessionAggregateViewModel ShallowCopy() => (VeterinaryActiveSurveillanceSessionAggregateViewModel)this.MemberwiseClone();

        public long MonitoringSessionSummaryID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public string EIDSSFarmID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string Species { get; set; }
        public long? SpeciesID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? AnimalID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public string AnimalName { get; set; }
        public long? AnimalGenderTypeID { get; set; }
        public string AnimalGenderTypeName { get; set; }
        public int? SampledAnimalsQuantity { get; set; }
        public int? SamplesQuantity { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByPersonID { get; set; }
        public int? PositiveAnimalsQuantity { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public bool? SampleCheckedIndicator { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public bool? DiseaseCheckedIndicator { get; set; }
        public IEnumerable<long> SelectedDiseases { get; set; }
        public long? SentToOrganizationID { get; set; }
        public string SentToOrganizationName { get; set; }
        public long SiteID { get; set; }
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public int RowAction { get; set; } = (int)RowActionTypeEnum.Insert;
    }
}