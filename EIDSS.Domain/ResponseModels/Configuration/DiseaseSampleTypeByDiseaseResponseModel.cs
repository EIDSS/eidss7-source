using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class DiseaseSampleTypeByDiseaseResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? idfMaterialForDisease { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string strDisease { get; set; }
        public long? idfsSampleType { get; set; }
        public string strSampleType { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
