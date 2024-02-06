using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class VectorTypeCollectionMethodMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsVectorType { get; set; }
        public long? idfsCollectionMethod { get; set; }
    }

    public class VectorTypeCollectionMethodMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfCollectionMethodForVectorType { get; set; }
        public long? idfsVectorType { get; set; }
        public long? idfsCollectionMethod { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}

