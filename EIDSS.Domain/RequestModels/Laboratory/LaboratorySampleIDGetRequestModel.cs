namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class LaboratorySampleIDRequestModel
    {
        public long SampleID { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public bool ProcessedIndicator { get; set; }
    }
}
