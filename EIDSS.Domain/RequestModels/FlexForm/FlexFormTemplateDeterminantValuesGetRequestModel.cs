using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateDeterminantValuesGetRequestModel: BaseGetRequestModel
    {
        public long? idfsFormTemplate { get; set; }
    }
}
