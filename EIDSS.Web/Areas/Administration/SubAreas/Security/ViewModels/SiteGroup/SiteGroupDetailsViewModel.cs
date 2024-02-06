using EIDSS.Domain.ViewModels;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SiteGroup
{
    public class SiteGroupDetailsViewModel
    {
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public SiteGroupInformationSectionViewModel SiteGroupInformationSection { get; set; }
        public SitesSectionViewModel SitesSection { get; set; }
        public string Sites { get; set; }
        public UserPermissions SiteGroupPermissions { get; set; }
    }
}