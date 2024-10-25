using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class VectorGetListRequestModel : BaseGetRequestModel
    {
        public long OutbreakKey { get; set; }
        public string SearchTerm { get; set; }
    }
}
