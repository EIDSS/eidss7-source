namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionDiseaseSampleTypeResponseModel
    {
        public long MonitoringSessionToDiseaseID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public long? SampleID { get; set; }
        public int OrderNumber { get; set; }
    }
}