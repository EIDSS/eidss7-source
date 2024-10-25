using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateGetRequestModel : BaseGetRequestModel
    {
        public long? idfsFormTemplate { get; set; }
        public long? idfsFormType { get; set; }
        public long? idfOutbreak { get; set; }
    }
}
