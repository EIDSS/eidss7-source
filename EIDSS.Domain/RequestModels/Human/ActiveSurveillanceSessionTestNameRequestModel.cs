using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionTestNameRequestModel: BaseGetRequestModel
    {
        public string DiseaseIDList { get; set; }
    }
}
