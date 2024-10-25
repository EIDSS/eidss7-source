using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class LaboratoryTestGetListRequestModel : BaseGetRequestModel
    {
        public long? DiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
    }
}
