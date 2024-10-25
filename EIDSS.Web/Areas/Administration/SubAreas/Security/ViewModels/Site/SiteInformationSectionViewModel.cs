using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site
{
    public class SiteInformationSectionViewModel
    {
        public Select2Configruation SiteTypeSelect { get; set; }
        public Select2Configruation ParentSiteSelect { get; set; }
        public EIDSSModalConfiguration SiteTypeModal { get; set; }
        public Select2Configruation OrganizationSelect { get; set; }
        public SiteGetDetailViewModel SiteDetails { get; set; }
        public UserPermissions LoggedInUserPermissions { get; set; }
    }
}
