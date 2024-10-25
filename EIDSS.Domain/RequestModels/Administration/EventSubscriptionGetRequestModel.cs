using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class EventSubscriptionGetRequestModel :BaseGetRequestModel
    {
        public string SiteAlertName { get; set; }
        public long UserId { get; set; }
    }
}
