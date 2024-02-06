using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormParameterInUseRequestModel : BaseGetRequestModel
    {
        public long? idfsParameter { get; set; }
        public long? idfsFormTemplate { get; set; }
    }
}
