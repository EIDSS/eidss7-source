using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VectorTypeSampleTypeMatrixViewModel : BaseModel
    {
        public long idfSampleTypeForVectorType { get; set; }
        public long idfsVectorType { get; set; }
        public string strVectorTypeName { get; set; }
        public long idfsSampleType { get; set; }
        public string strSampleTypeName { get; set; }
    }
}

