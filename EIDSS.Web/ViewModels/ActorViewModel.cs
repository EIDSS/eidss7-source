using EIDSS.Web.TagHelpers.Models.EIDSSGrid;

namespace EIDSS.Web.ViewModels
{
    public class ActorViewModel
    {
        public EIDSSGridConfiguration ActorsGridConfiguration { get; set; }
        public long? AccessRuleID { get; set; }
        public long? DiseaseID { get; set; }
        public bool Search { get; set; } = false;
    }
}
