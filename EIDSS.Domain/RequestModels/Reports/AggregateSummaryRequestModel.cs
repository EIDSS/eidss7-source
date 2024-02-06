using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Reports
{
    public class AggregateSummaryRequestModel
    {
        public string LangID { get; set; }
        public string idfAggrCaseList { get; set; }
        public string idfsAggrCaseType { get; set; }
    }
}