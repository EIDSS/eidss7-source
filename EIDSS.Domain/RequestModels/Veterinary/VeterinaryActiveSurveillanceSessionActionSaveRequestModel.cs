using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionActionSaveRequestModel
    {
        public long MonitoringSessionActionID { get; set; }
        public long? MonitoringSessionActionStatusTypeID { get; set; }
        public long? MonitoringSessionActionTypeID { get; set; }
        public long? EnteredByPersonID { get; set; }
        public DateTime? ActionDate { get; set; }
        public string Comments { get; set; }    
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }
    }
}
