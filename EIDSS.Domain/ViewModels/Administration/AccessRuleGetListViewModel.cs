using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AccessRuleGetListViewModel : BaseModel
    {
        public long AccessRuleID { get; set; }
        public string AccessRuleName { get; set; }
        public bool DefaultRuleIndicator { get; set; }
        public bool BorderingAreaRuleIndicator { get; set; }
        public bool ReciprocalRuleIndicator { get; set; }
        public string GrantingActorName { get; set; }
        public string GrantingSiteAdministrativeLevel1Name { get; set; }
        public string GrantingSiteAdministrativeLevel2Name { get; set; }
        public int? RecordCount { get; set; }
    }
}
