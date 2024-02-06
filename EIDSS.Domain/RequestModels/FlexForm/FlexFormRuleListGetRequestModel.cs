using System.Threading;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormRuleListGetRequestModel
    {
        public string LangID { get; set; }
        public long? idfsFormTemplate { get; set; }
    }
}
