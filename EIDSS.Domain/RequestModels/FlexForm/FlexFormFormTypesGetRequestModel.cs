using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormFormTypesGetRequestModel : BaseGetRequestModel
    {
        public long? idfsFormType { get; set; }
        public long? idfsSection { get; set; }
    }
}