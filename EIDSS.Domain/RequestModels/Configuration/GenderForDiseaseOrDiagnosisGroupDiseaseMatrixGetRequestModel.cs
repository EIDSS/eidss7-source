using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel
    {
        public string? LanguageID { get; set; }
        public long? DiseaseID { get; set; }
    }
}
