using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class VectorSessionDeleteRequestModel
    {
        public long idfVectorSurveillanceSession { get; set; }
    }
}
