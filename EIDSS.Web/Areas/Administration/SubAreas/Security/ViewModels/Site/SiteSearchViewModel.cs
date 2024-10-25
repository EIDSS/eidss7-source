using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site
{
    public class SiteSearchViewModel : BaseModel
    {
        public bool RecordSelectionIndicator { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public bool ShowSearchResults { get; set; }
        public Select2Configruation SiteTypeSelect { get; set; }
        public Select2Configruation OrganizationSelect { get; set; }
        public SiteGetRequestModel SearchCriteria { get; set; }
        public List<SiteGetListViewModel> SearchResults { get; set; }
        public EIDSSGridConfiguration SiteGridConfiguration { get; set; }
        public string InformationalMessage { get; set; }
        public UserPermissions SitePermissions { get; set; }
    }
}