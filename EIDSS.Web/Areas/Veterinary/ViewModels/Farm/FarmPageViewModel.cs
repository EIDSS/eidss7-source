using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{
    public class FarmPageViewModel
    {


        long? FarmID { get; set; }
        string EIDSSFarmID { get; set; }
        long? FarmTypeID { get; set; }
        string FarmName { get; set; }
        string FarmOwnerFirstName { get; set; }
        string FarmOwnerLastName { get; set; }
        string EIDSSPersonID { get; set; }
        long? FarmOwnerID { get; set; }
        long? RegionID { get; set; }
        long? RayonID { get; set; }
        long? SettlementTypeID { get; set; }
        long? SettlementID { get; set; }
        long? MonitoringSessionID { get; set; }
    }
}
