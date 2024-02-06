using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class PensideTestGetListRequestModel : BaseGetRequestModel
    {
        public long? DiseaseReportID { get; set; }
        public long? SampleID { get; set; }
    }
}
