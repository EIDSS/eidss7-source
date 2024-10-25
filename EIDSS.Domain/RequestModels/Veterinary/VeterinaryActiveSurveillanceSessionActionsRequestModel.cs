using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionActionsRequestModel : BaseGetRequestModel
    {
        public long? MonitoringSessionID { get; set; }
        public string advancedSearch { get; set; }
        
    }
}
