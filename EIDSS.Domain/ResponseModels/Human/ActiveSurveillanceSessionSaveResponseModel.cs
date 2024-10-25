namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionSaveResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? MonitoringSessionID { get; set; }
        public string EIDSSSessionID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
    }
}
