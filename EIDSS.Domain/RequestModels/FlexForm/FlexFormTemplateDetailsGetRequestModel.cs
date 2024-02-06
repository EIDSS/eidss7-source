using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateDetailsGetRequestModel
    {
        public string Langid { get; set; }
        public long idfsFormTemplate { get; set; }
    }
}
