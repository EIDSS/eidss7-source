namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormCopyTemplateRequestModel
    {
        public string LangId { get; set; }
        public long idfsFormTemplate { get; set; }
        public string User { get; set; } = "";
        public long? idfsSite { get; set; }
        public long? idfsNewFormType { get; set; }
    }
}
