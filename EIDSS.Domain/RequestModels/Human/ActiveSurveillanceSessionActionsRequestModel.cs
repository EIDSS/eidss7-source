using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionActionsRequestModel : BaseGetRequestModel
    {
        public long? MonitoringSessionID { get; set; }
        public string advancedSearch { get; set; }
    }
}
