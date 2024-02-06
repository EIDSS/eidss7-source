using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class TabCountsGetRequestModel : BaseGetRequestModel
    {
        public int DaysFromAccessionDate { get; set; }
        public long UserID { get; set; }
        public long UserEmployeeID { get; set; }
        public long UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserSiteGroupID { get; set; }
    }
}