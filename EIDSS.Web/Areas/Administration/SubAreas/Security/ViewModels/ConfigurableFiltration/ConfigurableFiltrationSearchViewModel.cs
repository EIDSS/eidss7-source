using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;

namespace EIDSS.Web.Administration.Security.ViewModels
{
    public class ConfigurableFiltrationSearchViewModel
    {
        public AccessRuleGetRequestModel SearchCriteria { get; set; }
        public string InformationalMessage { get; set; }
        public EIDSSGridConfiguration AccessRulesGridConfiguration { get; set; }
        public bool ShowSearchResults { get; set; }
        public UserPermissions ConfigurableFiltrationPermissions { get; set; }
    }
}
