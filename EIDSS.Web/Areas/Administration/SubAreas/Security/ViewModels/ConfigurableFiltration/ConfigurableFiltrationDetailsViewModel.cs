using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;

namespace EIDSS.Web.Administration.Security.ViewModels
{
    public class ConfigurableFiltrationDetailsViewModel
    {
        public AccessRuleGetDetailViewModel AccessRuleDetails { get; set; }
        public bool DeleteVisibleIndicator { get; set; }
        public string InformationalMessage { get; set; }
        public string ErrorMessage { get; set; }
        public string ReceivingActors { get; set; }
        public EIDSSGridConfiguration ReceivingActorsGridConfiguration { get; set; }
        public SearchActorViewModel SearchActorViewModel { get; set; }
    }
}
