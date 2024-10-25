using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EventsSaveRequestModel
    {
        public long NotificationID { get; set; }
        public long? NotificationTypeID { get; set; }
        public long? UserID { get; set; }
        public long? NotificationObjectID { get; set; }
        public long? NotificationObjectTypeID { get; set; }
        public long? TargetUserID { get; set; }
        public long? TargetSiteID { get; set; }
        public long? TargetSiteTypeID { get; set; }
        public long? SiteID { get; set; }
        public string Payload { get; set; }
        public string LoginSite { get; set; }
    }
}