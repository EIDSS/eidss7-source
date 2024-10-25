namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormTemplateSectionOrderRequestModel
    {
        public string LangId { get; set; }
        public long? idfsFormTemplate { get; set; }
        public long? idfsCurrentSection { get; set; }
        public long? idfsDestinationSection { get; set; }
        public string User { get; set; }
    }
}
