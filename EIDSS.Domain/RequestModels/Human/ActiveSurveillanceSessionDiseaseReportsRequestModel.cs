using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionDiseaseReportsRequestModel : BaseGetRequestModel
    {
        public long? SessionKey { get; set; }
        public bool? ApplySiteFiltrationIndicator { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserEmployeeID { get; set; }
    }
}