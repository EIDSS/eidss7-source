using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class StatisticalTypeSaveRequestModel : BaseSaveRequestModel
    {
        public bool? BlnRelatedWithAgeGroup { get; set; }
        public long? IdfsReferenceType { get; set; }
        public long? IdfsStatisticAreaType { get; set; }
        public long? IdfsStatisticDataType { get; set; }
        public bool DeleteAnyway { get; set; }
        public long? IdfsStatisticPeriodType { get; set; }
        public string StrDefault { get; set; }
        public string StrName { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }
}
