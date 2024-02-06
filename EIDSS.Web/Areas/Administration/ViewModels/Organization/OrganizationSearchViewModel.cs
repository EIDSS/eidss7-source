using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Administration.ViewModels.Organization
{
    public class OrganizationSearchViewModel
    {
        public bool ShowInModalIndicator { get; set; }
        public bool ShowSearchResults { get; set; }
        public Select2Configruation AccessoryCodeSelect { get; set; }
        public Select2Configruation OrganizationTypeSelect { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public OrganizationGetRequestModel SearchCriteria { get; set; }
        public List<OrganizationGetListViewModel> SearchResults { get; set; }
        public EIDSSGridConfiguration OrganizationGridConfiguration { get; set; }
        public string InformationalMessage { get; set; }
        public UserPermissions OrganizationPermissions { get; set; }
        public bool RecordSelectionIndicator { get; set; }
    }
}
