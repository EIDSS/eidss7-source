using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class MatrixGetRequestModel : BaseGetRequestModel
    {
        [MapToParameter("idfVersion")]
        public long MatrixId { get; set; }

        // Why are these two properties in this model?
        public long IdfsBaseReference { get; set; }
        public int IntHACode { get; set; }
    }
}
