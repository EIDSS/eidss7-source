using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AccessRuleActorGetListViewModel : BaseModel
    {
        public AccessRuleActorGetListViewModel ShallowCopy()
        {
            return (AccessRuleActorGetListViewModel)MemberwiseClone();
        }

        public long AccessRuleActorID { get; set; }
        public long? AccessRuleID { get; set; }
        public long ActorTypeID { get; set; }
        public string ActorTypeName { get; set; }
        public string ActorName { get; set; }
        public long? ActorSiteGroupID { get; set; }
        public string SiteGroupName { get; set; }
        public long? ActorSiteID { get; set; }
        public string SiteName { get; set; }
        public long? ActorEmployeeGroupID { get; set; }
        public string EmployeeGroupName { get; set; }
        public long? ActorUserID { get; set; }
        public string UserFullName { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public int RowStatus { get; set; }
        public bool ExternalActorIndicator { get; set; }
        public int RowAction { get; set; }
        public int? RecordCount { get; set; }
        public string ActorDefaultName { get; set; }
        public string ActorDescription { get; set; }
    }
}