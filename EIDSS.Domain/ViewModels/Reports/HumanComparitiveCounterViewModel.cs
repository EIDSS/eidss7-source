using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class HumanComparitiveCounterViewModel:BaseModel
    {
        public int? ID { get; set; }
        public string Value { get; set; }
    }
}
