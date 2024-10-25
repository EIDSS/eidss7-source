namespace EIDSS.Web.Components.Events
{
    public class Notification
    {
        public long EventId { get; set; }
        public string StrPayLoad { get; set; }
        public long NotificationObjectId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long TargetSiteId { get; set; }
        public long TargetUserId { get; set; }
        public long TargetSiteType { get; set; }
    }
}
