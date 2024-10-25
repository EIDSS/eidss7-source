using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionAggregateSummarySaveRequestModel
    {
        public long MonitoringSessionSummaryID { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? SpeciesID { get; set; }
        public long? AnimalSexID { get; set; }
        public int? SampleAnimalsQty { get; set; }
        public int? SamplesQty { get; set; }
        public DateTime? CollectionDate { get; set; }
        public long? CollectedByPersonID { get; set; }
        public int? PositiveAnimalsQty { get; set; }
        public long? DiseaseID { get; set; }
        public long? SampleTypeID { get; set; }
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }
    }
}