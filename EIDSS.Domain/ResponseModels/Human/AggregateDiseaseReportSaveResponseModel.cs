using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class AggregateDiseaseReportSaveResponseModel : APIPostResponseModel
    {
        public long? idfAggrCase { get; set; }
        public long? idfVersion { get; set; }
        public string strCaseID { get; set; }
        public string DuplicateMessage { get; set; }
    }
}
