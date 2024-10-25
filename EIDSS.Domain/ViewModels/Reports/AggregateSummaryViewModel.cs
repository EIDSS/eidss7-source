using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class AggregateSummaryViewModel
    {
        public string ParameterName { get; set; }
        public string strSpecies { get; set; }
        public long? idfsParameter { get; set; }
        public int? ParameterOrder { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string strDefault { get; set; }
        public string strOIECode { get; set; }
        public string strAction { get; set; }
        public int? intNumRow { get; set; }
        public string strActionCode { get; set; }
        public string varValue { get; set; }
    }
}