using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class AgeGroupSaveRequestModel
    {
        public long? IdfsAgeGroup{get; set;}

        public bool DeleteAnyway { get; set; }
        
        public long? IdfsAgeType { get; set; }
        
        public int? IntLowerBoundary { get; set; }
        
        public int? IntOrder { get; set; }
        
        public int? IntUpperBoundary { get; set; }

        [MapToParameter("langID")]
        public string LanguageId { get; set; }
        public string StrDefault { get; set; }
        public string StrName { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }
}
