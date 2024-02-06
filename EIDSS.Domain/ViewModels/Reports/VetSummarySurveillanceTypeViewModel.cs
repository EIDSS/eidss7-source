using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class VetSummarySurveillanceTypeViewModel:BaseModel
    {
        public int idfsSurveillance { get; set; }
        public string StrName { get; set; }
    }
}
