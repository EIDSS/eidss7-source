using EIDSS.Domain.Attributes;
using EIDSS.Domain.ViewModels.Administration.Security;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SiteGroupSaveRequestModel
    {
        public string LanguageID { get; set; }
        public SiteGroupGetDetailViewModel SiteGroupDetails { get; set; }
        public string Sites { get; set; }
        public string AuditUserName { get; set; }
    }
}