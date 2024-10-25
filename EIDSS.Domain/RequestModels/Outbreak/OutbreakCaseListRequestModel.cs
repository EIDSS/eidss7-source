using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class OutbreakCaseListRequestModel : BaseGetRequestModel
    {
        public long? OutbreakID { get; set; }
        public string SearchTerm { get; set; }
        public long? HumanMasterID { get; set; }
        public long? FarmMasterID { get; set; }
        public bool? TodaysFollowUpsIndicator { get; set; }
    }
}
