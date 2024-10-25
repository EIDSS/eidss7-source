namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class GetAgeTypesRequestModel
    {
        public string LanguageIsoCode { get; set; }

        public long[] ExcludeIds { get; set; }

        public string AdvancedSearch { get; set; }
    }
}
