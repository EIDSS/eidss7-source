using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormRuleDetailsViewModel : BaseModel
    {
        public long idfsRule { get; set; }
        public string defaultRuleName { get; set; }
        public string RuleName { get; set; }
        public long? idfsRuleMessage { get; set; }
        public string defaultRuleMessage { get; set; }
        public string RuleMessage { get; set; }
        public long? idfsCheckPoint { get; set; }
        public long idfsRuleFunction { get; set; }
        public bool blnNot { get; set; }
        public long? idfsRuleAction { get; set; }
        public string strActionParameters { get; set; }
        public long? idfsFunctionParameter { get; set; }
        public string FillValue { get; set; }
    }
}
