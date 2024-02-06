using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionDetailedInformationRequestModel : BaseGetRequestModel
    {
        public long? idfMonitoringSession { get; set; }
        public string AdvancedSearch { get; set; }
    }
}