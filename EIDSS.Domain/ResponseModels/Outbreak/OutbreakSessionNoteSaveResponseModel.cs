namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakSessionNoteSaveResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfOutbreakNote { get; set; }
    }
}
