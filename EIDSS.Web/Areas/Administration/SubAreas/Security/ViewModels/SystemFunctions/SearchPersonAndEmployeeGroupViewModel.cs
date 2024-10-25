using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions
{
    public class SearchPersonAndEmployeeGroupViewModel
    {
        public PersonAndEmployeeGroupGetRequestModel SearchCriteria { get; set; }
        public List<SystemFunctionPersonANDEmployeeGroupViewModel>  SearchResults { get; set; }
        public List<BaseReferenceViewModel> ActorTypeList { get; set; }
        public bool ShowSearchResults { get; set; }
        public EIDSSGridConfiguration ActorsGridConfiguration { get; set; }
        public long SiteId { get; set; }
        public long SystemFunctionId { get; set; }
        public string ModalTitle { get; set; }
    }
}
