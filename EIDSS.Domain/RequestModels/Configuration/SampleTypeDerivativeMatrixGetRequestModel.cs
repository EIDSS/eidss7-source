using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class SampleTypeDerivativeMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsSampleType { get; set; }
    }

    public class SampleTypeDerivativeMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfDerivativeForSampleType { get; set; }
        public long? idfsSampleType { get; set; }
        public long? idfsDerivativeType { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public bool deleteAnyway { get; set; }
    }
}
