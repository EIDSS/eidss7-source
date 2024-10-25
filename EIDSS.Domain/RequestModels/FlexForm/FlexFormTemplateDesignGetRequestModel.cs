using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateDesignGetRequestModel : BaseGetRequestModel
    {
        public long? idfsFormTemplate { get; set; }
        public string User { get; set; }
    }
}
