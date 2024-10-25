using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class DiseaseLabTestMatrixGetRequestResponseModel
    {
        public long idfTestForDisease { get; set; }
        public long idfsDiagnosis { get; set; }
        public string strDisease { get; set; }
        public long? idfsTestName { get; set; }
        public string strTestName { get; set; }
        public long? idfsTestCategory { get; set; }
        public string strTestCategory { get; set; }
        public long? idfsSampleType { get; set; }
        public string strSampleType { get; set; }
    }
}
