using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class SampleIDsGetListViewModel : BaseModel
    {
        public long SampleID { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public bool? ProcessedIndicator { get; set; }
    }
}
