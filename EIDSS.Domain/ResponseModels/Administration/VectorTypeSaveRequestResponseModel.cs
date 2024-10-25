using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class VectorTypeSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfsVectorType { get; set; }
        public string strDuplicatedField { get; set; }

    }
}
