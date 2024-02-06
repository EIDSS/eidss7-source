using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class VetDateFieldSourceViewModel: BaseModel 
    {
        public int intDateFieldSource { get; set; }
        public string strDateFieldSource { get; set; }
    }
}
