namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateParameterOrderRequestModel
    {
        public string LangId { get; set; }
        public long idfsFormTemplate { get; set; }
        public long idfsCurrentParameter { get; set; }
        public long idfsDestinationParameter { get; set; }
        public int? Direction { get; set; }
        public string User { get; set; } = string.Empty;
    }
}
