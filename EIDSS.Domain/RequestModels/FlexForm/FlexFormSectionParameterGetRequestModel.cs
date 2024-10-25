using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormSectionParameterGetRequestModel: BaseGetRequestModel
    {
        public long? idfsSection { get; set; }
        public long? idfsFormType { get; set; }
        public string parameterFilter { get; set; }
        public string sectionFilter { get; set; }

    }
}
