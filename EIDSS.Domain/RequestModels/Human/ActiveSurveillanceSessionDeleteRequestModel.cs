using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class ActiveSurveillanceSessionDeleteRequestModel
    {
        public long? MonitoringSessionID { get; set; }
    }
}
