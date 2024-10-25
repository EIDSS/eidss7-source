namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakCaseSaveResponseModel
    {
        public long? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public string strOutbreakCaseId { get; set; }
        public long? OutbreakCaseReportUID { get; set; }
    }
}
