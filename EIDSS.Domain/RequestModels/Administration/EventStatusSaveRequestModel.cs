using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EventStatusSaveRequestModel : BaseSaveRequestModel
    {
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long? EventId { get; set; }
        public int StatusValue { get; set; }
    }
}
