using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormParametersGetRequestModel : BaseGetRequestModel
    {
        public long? idfsFormType { get; set; }
        public long? idfsSection { get; set; }
        public string SectionIDs { get; set; }
    }
}



