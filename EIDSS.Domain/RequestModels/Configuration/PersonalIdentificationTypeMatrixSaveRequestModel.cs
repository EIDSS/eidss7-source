using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class PersonalIdentificationTypeMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long IdfPersonalIDType { get; set; }
        public string StrFieldType { get; set; }
        public int Length { get; set; }
        public int IntOrder { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
