namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormSectionsParametersRequestModel
    {
        public string LangId { get; set; } = "en";
        public long? idfsSection { get; set; }
        public long? idfsFormType { get; set; }
        public string parameterFilter { get; set; }
        public string sectionFilter { get; set; }
    }
}
