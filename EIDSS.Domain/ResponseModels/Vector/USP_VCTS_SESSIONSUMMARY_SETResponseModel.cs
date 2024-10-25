using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_SESSIONSUMMARY_SETResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMesssage { get; set; }
        public long? idfsVSSessionSummary { get; set; }
        public string strVSSessionSummaryID { get; set; }
    }
}
