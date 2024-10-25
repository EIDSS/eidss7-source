using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormRuleDetailsGetRequestModel
    {
        public string LangID { get; set; }
        public long idfsRule { get; set; }
    }
}
