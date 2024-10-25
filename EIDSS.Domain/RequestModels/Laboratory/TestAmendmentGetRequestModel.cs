using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class TestAmendmentGetRequestModel : BaseGetRequestModel
    {
        public long TestID { get; set; }
    }
}