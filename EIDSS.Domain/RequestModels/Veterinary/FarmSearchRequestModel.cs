using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
 public   class FarmSearchRequestModel : BaseGetRequestModel
    {
        public long? FarmID { get; set; }
        public string EIDSSFarmID { get; set; }
        public string LegacyFarmID { get; set; }
        public long? FarmTypeID { get; set; }
        public IEnumerable<long> SelectedFarmTypes { get; set; }
        public string FarmName { get; set; }
        public string FarmOwnerFirstName { get; set; }
        public string FarmOwnerLastName { get; set; }
        public string EIDSSPersonID { get; set; }
        public string EIDSSFarmOwnerID { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? RegionID { get; set; }
        public long? RayonID { get; set; }
        public long? SettlementID  { get; set; }
        public long? SettlementTypeID { get; set; }
        public long? MonitoringSessionID { get; set; }
        
        public long? TimeIntervalTypeID { get; set; }

        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? StartDate { get; set; }

        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? EndDate { get; set; }

        public long? AdministrativeUnitTypeID { get; set; }
        public long? IdfsLocation { get; set; }
    }
}
