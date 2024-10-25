using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class ActorGetRequestModel : BaseGetRequestModel
    {
        public long? ActorTypeID { get; set; }
        public string ActorName { get; set; }
        public string OrganizationName { get; set; }
        public string UserGroupDescription { get; set; }
        public long? DiseaseID { get; set; }
        public bool DiseaseFiltrationSearchIndicator { get; set; }
        public long UserSiteID { get; set; }
        public long UserOrganizationID { get; set; }
        public long UserEmployeeID { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; }
    }
}
