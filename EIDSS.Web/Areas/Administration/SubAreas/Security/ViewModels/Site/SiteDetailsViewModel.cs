using EIDSS.Web.ViewModels;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site
{
    public class SiteDetailsViewModel
    {
        public long? SiteID { get; set; }
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public SiteInformationSectionViewModel SiteInformationSection { get; set; }
        public OrganizationsSectionViewModel OrganizationsSection { get; set; }
        public PermissionsSectionViewModel PermissionsSection { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool SiteInformationSectionValidIndicator { get; set; }
        public bool OrganizationsSectionValidIndicator { get; set; }
        public bool PermissionsSectionValidIndicator { get; set; }
        public string Permissions { get; set; }
        public string Organizations { get; set; }
        public SearchActorViewModel SearchActorViewModel { get; set; }
    }
}
