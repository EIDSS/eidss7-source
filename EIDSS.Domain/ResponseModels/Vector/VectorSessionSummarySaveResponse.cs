namespace EIDSS.Domain.ResponseModels.Vector
{
    public class VectorSessionSummarySaveResponse
    {
        public int? ReturnCode { get; set; }
        public string ReturnMesssage { get; set; }
        public long? idfsVSSessionSummary { get; set; }
        public string strVSSessionSummaryID { get; set; }
    }
}
