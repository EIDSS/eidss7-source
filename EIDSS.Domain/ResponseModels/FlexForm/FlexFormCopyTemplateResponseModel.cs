using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ResponseModels.FlexForm
{
    public class FlexFormCopyTemplateResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfsFormTemplate { get; set; }
    }
}
