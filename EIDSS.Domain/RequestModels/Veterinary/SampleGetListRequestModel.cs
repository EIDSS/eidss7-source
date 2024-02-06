using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class SampleGetListRequestModel : BaseGetRequestModel
    {
        public long? DiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? ParentSampleID { get; set; }
        public long? RootSampleID { get; set; }
    }
}
