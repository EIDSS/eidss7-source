using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
 public   class FarmGetRequestModel : BaseGetRequestModel
    {

        public long? FarmID { get; set; }
        public string EIDSSFarmID { get; set; }
        public long? FarmTypeID  { get; set; }
        public string FarmName  { get; set; }
        public string FarmOwnerFirstName  { get; set; }
        public string FarmOwnerLastName  { get; set; }
        public string EIDSSPersonID  { get; set; }
        public long? FarmOwnerID  { get; set; }
        public long? RegionID  { get; set; }
        public long? RayonID  { get; set; }
        public long? IdfsLocation { get; set; }
        public long? SettlementTypeID  { get; set; }
        public long? SettlementID  { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public long? MonitoringSessionID  { get; set; }
        public int? PaginationSet  { get; set; }
        public int? MaxPagesPerFetch { get; set; }
        public string? FarmAvian { get; set; }
        public string? FarmLivestock  { get; set; }

        public long FarmKey { get; set; }
        
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int? Order { get; set; }
        public string AddressString { get; set; }
        public string OrganizationTypeName { get; set; }
        public int AccessoryCode { get; set; }
        public long? SiteID { get; set; }
        public int RowStatus { get; set; }
        public int? RowCount { get; set; }
    }
}
