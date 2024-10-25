using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class VectorTypeFieldTestMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsVectorType { get; set; }

    }

    public class VectorTypeFieldTestMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfPensideTestTypeForVectorType { get; set; }
        public long? idfsVectorType { get; set; }
        public long? idfsPensideTestName { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
