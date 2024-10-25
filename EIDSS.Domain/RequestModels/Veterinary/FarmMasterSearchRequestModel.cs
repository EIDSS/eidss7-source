using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class FarmMasterSearchRequestModel : BaseGetRequestModel
    {
        public long? FarmMasterID { get; set; }
        public string EIDSSFarmID { get; set; }
        public string LegacyFarmID { get; set; }
        public long? FarmTypeID { get; set; }
        public string FarmName { get; set; }
        public string FarmOwnerFirstName { get; set; }
        public string FarmOwnerLastName { get; set; }
        public string EIDSSPersonID { get; set; }
        public string EIDSSFarmOwnerID { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? IdfsLocation { get; set; }
        public long? SettlementTypeID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public bool? RecordIdentifierSearchIndicator { get; set; }
    }
}
