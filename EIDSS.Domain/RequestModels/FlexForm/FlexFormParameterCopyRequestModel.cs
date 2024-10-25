namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormParameterCopyRequestModel
    {
        public string LangId { get; set; }
        public long? idfsParameterSource { get; set; }
        public long? idfsSectionDestination { get; set; }
        public long? idfsFormTypeDestination { get; set; }
        public string User { get; set; }
    }
}
