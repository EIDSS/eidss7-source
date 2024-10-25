using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class SampleTypeDerivativeMatrixViewModel : BaseModel
    {
        public long IdfDerivativeForSampleType { get; set; }
        public long IdfsSampleType { get; set; }
        public string StrSampleType { get; set; }
        public long IdfsDerivativeType { get; set; }
        public string StrDerivative { get; set; }
    }
}
