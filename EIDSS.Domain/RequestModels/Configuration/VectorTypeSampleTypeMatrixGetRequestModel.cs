using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class VectorTypeSampleTypeMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsVectorType { get; set; }
    }

    public class VectorTypeSampleTypeMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfSampleTypeForVectorType { get; set; }
        public long? idfsVectorType { get; set; }
        public long? idfsSampleType { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
