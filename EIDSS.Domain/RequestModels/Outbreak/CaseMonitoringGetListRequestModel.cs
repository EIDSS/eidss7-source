using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class CaseMonitoringGetListRequestModel : BaseGetRequestModel
    {
        public long? CaseId { get; set; }
    }
}