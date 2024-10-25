using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VectorTypeCollectionMethodMatrixViewModel : BaseModel
    {
        public long? idfCollectionMethodForVectorType { get; set; }
        public long? idfsVectorType { get; set; }
        public string strVectorTypeDefault { get; set; }
        public string strVectorTypeName { get; set; }
        public long? idfsCollectionMethod { get; set; }
        public string strDefault { get; set; }
        public string strName { get; set; }
    }
}

