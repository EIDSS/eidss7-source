using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormRuleSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfsFormTemplate { get; set; }
        public long? idfsCheckPoint { get; set; }
        public long? idfsRuleFunction { get; set; }
        public long? idfsRuleAction { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string MessageText { get; set; }
        public string MessageNationalText { get; set; }
        public bool? blnNot { get; set; }
        public string LangID { get; set; }
        public long? idfsRule { get; set; }
        public long? idfsRuleMessage { get; set; }
        public long? idfsFunctionParameter { get; set; }
        public long? idfsActionParameter { get; set; }
        public string strFillValue { get; set; }
        public int? intRowStatus { get; set; } = 0;
        public string strCompareValue { get; set; }
        public int? FunctionCall { get; set; }
        public int? CopyOnly { get; set; }

    }
}