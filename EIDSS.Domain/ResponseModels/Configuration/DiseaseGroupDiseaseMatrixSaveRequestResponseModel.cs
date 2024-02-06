using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class DiseaseGroupDiseaseMatrixSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfDiagnosisToDiagnosisGroup { get; set; }
    }
}
