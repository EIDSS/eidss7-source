using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class USSP_VCT_SAMPLE_DETAILEDCOLLECTIONS_SETRequestModel
    {
        public string SAMPLEPARAMETERS { get; set; }
        public string AuditUser { get; set; }
    }
}
