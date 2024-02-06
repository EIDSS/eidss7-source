using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormRulesGetRequestModel 
    {
        [MapToParameter("LanguageId")]
        public string LangID { get; set; } = "en";
        public long? idfsFunctionParameter { get; set; }
    }
}
