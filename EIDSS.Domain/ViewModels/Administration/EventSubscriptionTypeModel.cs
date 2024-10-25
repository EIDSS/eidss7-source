using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EventSubscriptionTypeModel: BaseModel
    {
        public int RowId { get; set; }
        public long EventNameId { get; set; }
        public long EventTypeId { get; set; }
        public string EventTypeName { get; set; }
        public bool ReceiveAlertIndicator { get; set; }
        public string AlertRecipient { get; set; }
        public long UserId { get; set; }
        public int RowStatus { get; set; }
    }
}
