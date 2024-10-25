using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class FarmInventoryGetListRequestModel : BaseGetRequestModel
    {
        public long? DiseaseReportID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public string EIDSSFarmID { get; set; }
    }
}
