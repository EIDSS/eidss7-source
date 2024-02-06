using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class VectorTypeFieldTestMatrixSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfPensideTestTypeForVectorType { get; set; }

        public string strDuplicatedField { get; set; }


    }
}
