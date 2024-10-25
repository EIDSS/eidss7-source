using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class AnimalGetListRequestModel : BaseGetRequestModel
    {
        public long? DiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
    }
}
