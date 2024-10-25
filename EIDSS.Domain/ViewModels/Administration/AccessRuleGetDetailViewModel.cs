using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AccessRuleGetDetailViewModel : BaseModel
    {
        public long? AccessRuleID { get; set; }

        [LocalizedRequired()]
        public string AccessRuleName { get; set; }
        public string NationalValue { get; set; }
        public int Order { get; set; }
        public bool BorderingAreaRuleIndicator { get; set; }
        public bool DefaultRuleIndicator { get; set; }
        public bool ReciprocalRuleIndicator { get; set; }
        public long? GrantingActorSiteGroupID { get; set; }
        public long? GrantingActorSiteID { get; set; }
        public string GrantingActorName { get; set; }
        public string GrantingActorSiteGroupName { get; set; }
        public string GrantingActorSiteName { get; set; }
        public string GrantingActorSiteHASCCode { get; set; }
        public string GrantingActorSiteCode { get; set; }
        public long? GrantingActorAdministrativeLevel1ID { get; set; }
        public string GrantingSiteAdministrativeLevel1Name { get; set; }
        public long? GrantingActorAdministrativeLevel2ID { get; set; }
        public string GrantingSiteAdministrativeLevel2Name { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public long? AdministrativeLevelTypeID { get; set; }
        public int RowStatus { get; set; }
    }
}
