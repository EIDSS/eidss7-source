namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class OutbreakHeatMapRequestModel
    {
        public long? OutbreakId { get; set; }
        public string CaseType { get; set; }
        public long? DiseaseReportI { get; set; }
    }
}
