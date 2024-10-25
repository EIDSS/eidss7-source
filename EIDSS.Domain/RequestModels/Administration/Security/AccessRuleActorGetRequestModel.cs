using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class AccessRuleActorGetRequestModel : BaseGetRequestModel
    {
        public long? AccessRuleID { get; set; }
        public long? SiteID { get; set; }
    }
}
