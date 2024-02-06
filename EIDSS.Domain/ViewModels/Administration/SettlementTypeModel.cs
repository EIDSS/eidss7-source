using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class SettlementTypeModel
    {
        public long? idfsReference { get; set; }
        public string name { get; set; }
        public int intRowStatus { get; set; }
        public string strDefault { get; set; }
        public int intOrder { get; set; }
        public int RowCount { get; set; }
    }

}

