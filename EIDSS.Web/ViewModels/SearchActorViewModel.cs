using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels
{
    public class SearchActorViewModel
    {
        public ActorGetRequestModel SearchCriteria { get; set; }
        public List<ActorGetListViewModel> SearchResults { get; set; }
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
    }
}