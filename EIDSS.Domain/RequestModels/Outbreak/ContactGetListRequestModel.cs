using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class ContactGetListRequestModel : BaseGetRequestModel
    {
        public long? CaseId { get; set; }
        public long? OutbreakId { get; set; }
        public string SearchTerm { get; set; }
        public bool TodaysFollowUpsIndicator { get; set; }
    }
}
