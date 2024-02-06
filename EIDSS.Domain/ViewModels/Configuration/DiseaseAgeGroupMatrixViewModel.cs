using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class DiseaseAgeGroupMatrixViewModel : BaseModel
    {
        public long? IdfDiagnosisAgeGroupToDiagnosis { get; set; }
        public long? IdfsDiagnosis { get; set; }
        public string StrDiseaseDefault { get; set; }
        public string StrDiseaseName { get; set; }
        public long? IdfsDiagnosisAgeGroup { get; set; }
        public string StrAgeGroupDefault { get; set; }
        public string StrAgeGroupName { get; set; }
    }
}
