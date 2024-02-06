using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EventSaveRequestModel : BaseSaveRequestModel
    {
        public long? EventId { get; set; }
        public long? EventTypeId { get; set; }
        public long? UserId { get; set; }
        public long? SiteId { get; set; }
        public long? LoginSiteId { get; set; }
        public long? ObjectId { get; set; }
        public long? DiseaseId { get; set; }
        public long? LocationId {get; set; }
        public string InformationString { get; set; }
        //public string Note { get; set; }
    }
}
