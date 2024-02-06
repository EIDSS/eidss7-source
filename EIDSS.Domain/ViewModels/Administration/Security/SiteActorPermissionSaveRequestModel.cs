using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SiteActorPermissionSaveRequestModel
    {
        public long AccessRuleActorID { get; set; }
        public long? AccessRuleID { get; set; }
        public bool GrantingActorIndicator { get; set; }
        public bool ExternalActorIndicator { get; set; }
        public string ActorName { get; set; }
        public string ActorDefaultName { get; set; }
        public string ActorDescription { get; set; }
        public long? ActorSiteGroupID { get; set; }
        public long? ActorSiteID { get; set; }
        public long? ActorEmployeeGroupID { get; set; }
        public long? ActorUserID { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}
