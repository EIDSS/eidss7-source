using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class DiseaseReportGetDetailRequestModel : BaseGetRequestModel
    {
        public long DiseaseReportID { get; set; }
        public long UserSiteID { get; set; }
        public long UserOrganizationID { get; set; }
        public long UserEmployeeID { get; set; }
        public bool ApplyFiltrationIndicator { get; set; }
    }
}
