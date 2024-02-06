using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class PersonAndEmployeeGroupGetRequestModel: BaseGetRequestModel
    {
        public long SystemFunctionId { get; set; }
        public long? ActorTypeID { get; set; }  //Employee group or Employee type
        public string ActorName { get; set; }
        public string OrganizationName { get; set; }
        public string Description { get; set; }
        public long? UserSiteID { get; set; }
        public long UserOrganizationID { get; set; }
        public long UserEmployeeID { get; set; }
    }
}
