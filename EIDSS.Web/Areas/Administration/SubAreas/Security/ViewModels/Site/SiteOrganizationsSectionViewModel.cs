using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site
{
    public class OrganizationsSectionViewModel
    {
        public UserPermissions OrganizationPermissions { get; set; }
        public List<OrganizationGetListViewModel> Organizations { get; set; }
        public List<OrganizationGetListViewModel> PendingSaveOrganizations { get; set; }
        public bool RecordSelectionIndicator { get; set; }
    }
}