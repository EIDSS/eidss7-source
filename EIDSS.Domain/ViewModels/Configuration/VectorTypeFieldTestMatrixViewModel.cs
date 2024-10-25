using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VectorTypeFieldTestMatrixViewModel : BaseModel
    {
        public long idfPensideTestTypeForVectorType { get; set; }
        public long idfsVectorType { get; set; }
        public string strVectorTypeName { get; set; }
        public long idfsPensideTestName { get; set; }
        public string strPensideTestName { get; set; }
    }
}

