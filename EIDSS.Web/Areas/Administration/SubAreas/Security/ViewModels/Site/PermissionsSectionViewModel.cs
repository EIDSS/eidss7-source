using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site
{
    public class PermissionsSectionViewModel
    {
        public EIDSSGridConfiguration ReceivingActorsGridConfiguration { get; set; }
        public List<SiteActorGetListViewModel> Actors { get; set; }
        public List<SiteActorGetListViewModel> PendingSaveActors { get; set; }
        public List<ObjectAccessGetListViewModel> PendingSaveActorPermissions { get; set; }
        public UserPermissions SiteAccessRightsUserPermissions { get; set; }
    }
}
