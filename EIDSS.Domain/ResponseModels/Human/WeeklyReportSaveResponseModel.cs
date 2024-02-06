using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class WeeklyReportSaveResponseModel 
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfReportForm { get; set; }
        public string strReportFormID { get; set; }
    }
}

