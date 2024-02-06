using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class TabCountsGetListViewModel : BaseModel
    {
        public int SamplesTabCount { get; set; }
        public int TestingTabCount { get; set; }
        public int TransferredTabCount { get; set; }
        public int MyFavoritesTabCount { get; set; }
        public int BatchesTabCount { get; set; }
        public int ApprovalsTabCount { get; set; }
    }
}