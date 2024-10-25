namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class OutbreakSessionDetailRequestModel
    {
        public string LanguageID { get; set; }
        public long idfsOutbreak { get; set; }
        public long? HumanMasterID { get; set; }
    }
}
