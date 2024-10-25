using EIDSS.Domain.Attributes;
using EIDSS.Domain.ViewModels.Administration.Security;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SiteSaveRequestModel
    {
        public string LanguageID { get; set; }
        public SiteGetDetailViewModel SiteDetails { get; set; }
        public string Permissions { get; set; }
        public string Organizations { get; set; }

        [MapToParameter("UserName")]
        public string AuditUserName { get; set; }
    }
}