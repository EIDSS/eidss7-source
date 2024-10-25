using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class BaseReferenceCheckForDuplicatesResponseModel
    {
        public long IdfsBaseReference { get; set; }
        public long IdfsReferenceType { get; set; }
        public string StrDefault { get; set; }
        public string AlphaOnly { get; set; }
    }
}
