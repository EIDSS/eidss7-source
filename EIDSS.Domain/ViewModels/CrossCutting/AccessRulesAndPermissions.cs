using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class AccessRulesAndPermissions: BaseModel
    {
        public long AccessRuleID { get; set; }
        public long? SiteID { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
    }
}
