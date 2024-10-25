using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class USP_VCTS_SESSIONSUMMARYDIAGNOSIS_DELRequestModel
    {
        public long? idfsVSSessionSummaryDiagnosis { get; set; }
    }
}
