using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Dashboard
{
    public class DashboardLinksListViewModel : BaseModel
    {
        public long BaseReferenceId { get; set; }
        public string BaseReferenceCode { get; set; }
        public string Default { get; set; }
        public string Name { get; set; }
        public string PageLink { get; set; }
    }
}
