namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class BaseReferenceTranslationRequestModel
    {
        public string LanguageID { get; set; }
        public long idfsBaseReference { get; set; }
    }
}
