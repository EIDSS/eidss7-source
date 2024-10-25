using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{

    public class HumanAggregateCaseMatrixResponseModel : BaseModel
    {
        public long idfVersion { get; set; }
        public long idfsMatrixType { get; set; }
        public string MatrixName { get; set; }
        public DateTime? datStartDate { get; set; }
        public bool blnIsActive { get; set; }
        public bool? blnIsDefault { get; set; }
        public long? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
    }
}
