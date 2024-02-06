using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class TestNameTestResultsMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsTestResultRelation { get; set; }
        public long? idfsTestName { get; set; }
    }

    public class TestNameTestResultsMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfsTestResultRelation { get; set; }
        public long? idfsTestName { get; set; }
        public long? idfsTestResult { get; set; }
        public bool blnIndicative { get; set; }
        public bool DeleteAnyway { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
