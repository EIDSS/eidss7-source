using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class StatisticalAgeGroupMatrixSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfDiagnosisAgeGroupToStatisticalAgeGroup { get; set; }
        public string DuplicatedField { get; set; }
    }
}
