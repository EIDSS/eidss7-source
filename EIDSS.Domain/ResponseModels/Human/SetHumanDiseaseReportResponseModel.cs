using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class SetHumanDiseaseReportResponseModel 
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfHumanCase { get; set; }
        public string strHumanCaseID { get; set; }

        public long? idfHuman { get; set; }

        public bool? IsFromWHOExport { get; set; } = false;
        public string Header { get; set; }
    }
}
