namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionDetailRequestModel
    {
        public string LanguageID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public bool ApplyFiltrationIndicator { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserEmployeeID { get; set; }
    }
}