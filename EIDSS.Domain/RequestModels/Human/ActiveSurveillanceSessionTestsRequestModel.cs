using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionTestsRequestModel : BaseGetRequestModel
    {
        public long? idfMonitoringSession { get; set; }
        public string AdvancedSearch { get; set; }
    }
}
