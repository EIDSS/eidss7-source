using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.ViewModels.Administration
{
    public class SearchEmployeeActorViewModel
    {
        public EmployeesForUserGroupGetRequestModel SearchCriteria { get; set; }
        public List<EmployeesForUserGroupViewModel> SearchResults { get; set; }
        public List<BaseReferenceViewModel> ActorTypeList { get; set; }
        public bool IncludeEmployeeTypes { get; set; }
        public bool IncludeOrganizationTypes { get; set; }
        public bool ShowSearchResults { get; set; }
        public bool SelectVisibleIndicator { get; set; }
        public bool SelectAllVisibleIndicator { get; set; }
        public long? DiseaseID { get; set; }
        public string ModalTitle { get; set; }
        public EIDSSGridConfiguration ActorsGridConfiguration { get; set; }
        public long SiteID { get; set; }
        public UserPermissions Permissions { get; set; }
    }
}
