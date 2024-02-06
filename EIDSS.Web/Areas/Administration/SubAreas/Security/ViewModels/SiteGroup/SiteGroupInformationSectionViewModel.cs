using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SiteGroup
{
    public class SiteGroupInformationSectionViewModel
    {
        public Select2Configruation SiteGroupTypeSelect { get; set; }
        public EIDSSModalConfiguration SiteGroupTypeModal { get; set; }
        public Select2Configruation CentralSiteSelect { get; set; }
        public SiteGroupGetDetailViewModel SiteGroupDetails { get; set; }
        public LocationViewModel DetailsLocationViewModel { get; set; }
        public UserPermissions LoggedInUserPermissions { get; set; }
    }
}