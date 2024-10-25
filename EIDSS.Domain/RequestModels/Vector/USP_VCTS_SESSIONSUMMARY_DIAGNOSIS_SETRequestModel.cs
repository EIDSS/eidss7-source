using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class USP_VCTS_SESSIONSUMMARY_DIAGNOSIS_SETRequestModel
    {
        public long? idfsVSSessionSummaryDiagnosis { get; set; }
        public long? idfsVSSessionSummary { get; set; }
        public long? idfsDiagnosis { get; set; }
        public long? intPositiveQuantity { get; set; }

    }
}
