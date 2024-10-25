namespace EIDSS.Domain.ViewModels.Administration
{
    public class SubscriptionSaveRequestModel
    {
        public int RowId { get; set; }
        public long EventTypeId { get; set; }
        public long UserId { get; set; }
        public bool ReceiveAlertIndicator { get; set; }
    }

    public class SiteAlertEventSaveRequestModel
    {
        public string Subscriptions { get; set; }
        public string UserName { get; set; }
    }
}
