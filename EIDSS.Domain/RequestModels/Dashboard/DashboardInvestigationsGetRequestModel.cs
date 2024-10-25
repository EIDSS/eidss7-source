using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Dashboard
{
    public class DashboardInvestigationsGetRequestModel : BaseGetRequestModel
    {
        public string SiteList { get; set; }
        public long PersonID { get; set; }
    }    
}
