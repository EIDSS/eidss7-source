namespace EIDSS.Domain.ResponseModels.CrossCutting
{
    public class AggregateReportSaveResponseModel : APIPostResponseModel
    {
        public long? AggregateReportID { get; set; }
        public long? Version { get; set; }
        public string EIDSSAggregateReportID { get; set; }
        public string DuplicateMessage { get; set; }
    }
}
