using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class VectorTypeSampleTypeMatrixSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfSampleTypeForVectorType { get; set; }

        public string strDuplicatedField { get; set; }

    }
}
