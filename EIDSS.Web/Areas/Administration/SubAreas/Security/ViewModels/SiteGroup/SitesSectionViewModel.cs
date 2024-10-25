using EIDSS.Domain.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SiteGroup
{
    public class SitesSectionViewModel
    {
        public EIDSSGridConfiguration SiteGridConfiguration { get; set; }
        public UserPermissions SiteGroupPermissions { get; set; }
    }
}
