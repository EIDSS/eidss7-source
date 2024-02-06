using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    public class USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailRequestModel
    {
        public long idfsVSSessionSummary { get; set; }
        public string LangID { get; set; }
    }
}
