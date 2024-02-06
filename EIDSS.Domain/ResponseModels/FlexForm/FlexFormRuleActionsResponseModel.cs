namespace EIDSS.Domain.ResponseModels.FlexForm
{
    public class FlexFormRuleActionsResponseModel
    {
        public long idfParameterForAction { get; set; }
        public long idfsRule { get; set; }
        public long? idfsRuleAction { get; set; }
        public long idfsParameter { get; set; }
        public long idfsFormTemplate { get; set; }
    }
}
