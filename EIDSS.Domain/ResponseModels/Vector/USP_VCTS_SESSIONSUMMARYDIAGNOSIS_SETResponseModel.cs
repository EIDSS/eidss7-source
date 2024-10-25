using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_SESSIONSUMMARYDIAGNOSIS_SETResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMsg { get; set; }
        public long? idfsVSSessionSummaryDiagnosis { get; set; }
    }
}
