namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakSessionDetailsSaveResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfOutbreak { get; set; }
        public string strOutbreakID { get; set; }
    }
}
