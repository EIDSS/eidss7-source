using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class WhoMeaslesRubellaDiagnosisViewModel : BaseModel
    {
        public long idfsDiagnosis { get; set; }
        public string strDiagnosis { get; set; }
    }
}
