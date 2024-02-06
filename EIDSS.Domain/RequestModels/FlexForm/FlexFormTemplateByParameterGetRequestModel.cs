using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateByParameterGetRequestModel : BaseGetRequestModel
    {
        public long? idfsParameter { get; set; }
    }
}
