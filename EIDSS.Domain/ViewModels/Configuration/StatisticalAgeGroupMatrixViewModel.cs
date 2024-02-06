using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class StatisticalAgeGroupMatrixViewModel : BaseModel
    {
        public long IdfDiagnosisAgeGroupToStatisticalAgeGroup {get; set;}
        public long IdfsDiagnosisAgeGroup { get; set; }
        public string StrDiagnosisAgeGroupName { get; set; }
        public long IdfsStatisticalAgeGroup { get; set; }
        public string StrStatisticalAgeGroupName { get; set; }

    }
}
