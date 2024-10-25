using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class AccessRuleGetRequestModel : BaseGetRequestModel
    {
        public long? AccessRuleID { get; set; }
        [StringLength(255)]
        public string AccessRuleName { get; set; }
        public bool BorderingAreaRuleIndicator { get; set; }
        public bool DefaultRuleIndicator { get; set; }
        public bool ReciprocalRuleIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool CreatePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        [StringLength(36)]
        public string GrantingActorSiteCode { get; set; }
        [StringLength(50)]
        public string GrantingActorSiteHASCCode { get; set; }
        public string GrantingActorSiteName { get; set; }
        public long? GrantingActorAdministrativeLevelID { get; set; }
        public string ReceivingActorSiteCode { get; set; }
        public string ReceivingActorSiteHASCCode { get; set; }
        public string ReceivingActorSiteName { get; set; }
        public long? ReceivingActorAdministrativeLevelID { get; set; }
        public long? GrantingActorSiteGroupID { get; set; }
        public long? GrantingActorSiteID { get; set; }
        public string ReceivingActorSiteGroups { get; set; }
        public string ReceivingActorSites { get; set; }
        public string ReceivingActorUserGroups { get; set; }
        public string ReceivingActorUsers { get; set; }
    }
}