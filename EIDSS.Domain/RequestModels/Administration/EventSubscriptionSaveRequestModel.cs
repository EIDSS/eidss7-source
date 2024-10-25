using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EventSubscriptionSaveRequestModel
    {
        public int RowID { get; set; }
        public long EventTypeID { get; set; }
        public bool ReceiveAlertIndicator { get; set; }
        public string AlertRecipient { get; set; }
    }
}
