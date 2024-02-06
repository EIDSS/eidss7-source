using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Dashboard
{
    public class DashboardCollectionsGetRequestModel : BaseGetRequestModel
    {
        public long PersonID { get; set; }
    }
}
