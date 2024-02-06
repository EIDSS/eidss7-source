using EIDSS.Domain.ViewModels.Administration;

namespace EIDSS.Web.Areas.Administration.ViewModels.Organization
{
    public class OrganizationDetailsViewModel
    {
        public bool DeleteVisibleIndicator { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public long? OrganizationKey { get; set; }
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public OrganizationInfoSectionViewModel OrganizationInfoSection { get; set; }
        public string Departments { get; set; }
        public DepartmentsSectionViewModel DepartmentsSection { get; set; }
    }
}
