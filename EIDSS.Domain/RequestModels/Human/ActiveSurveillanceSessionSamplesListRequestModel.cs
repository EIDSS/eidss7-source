namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionSamplesListRequestModel
    {
        public string LanguageID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public string advancedSearch { get; set; }
        public int? pageNo { get; set; }
        public int? pageSize { get; set; }
        public string sortColumn { get; set; }
        public string sortOrder { get; set; }
    }
}
