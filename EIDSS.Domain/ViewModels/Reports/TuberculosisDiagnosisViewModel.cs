using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class TuberculosisDiagnosisViewModel : BaseModel
    {
        public long idfsReference { get; set; }
        public string strName { get; set; }
        public int? intOrder { get; set; }
    }
}
