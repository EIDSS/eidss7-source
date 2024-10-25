using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SiteGroup
{
    public class SiteGroupSearchViewModel
    {
        public bool ShowSearchResults { get; set; }
        public Select2Configruation SiteGroupTypeSelect { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public SiteGroupGetRequestModel SearchCriteria { get; set; }
        public List<SiteGroupGetListViewModel> SearchResults { get; set; }
        public EIDSSGridConfiguration SiteGroupGridConfiguration { get; set; }
        public string InformationalMessage { get; set; }
        public UserPermissions SiteGroupPermissions { get; set; }
    }
}
