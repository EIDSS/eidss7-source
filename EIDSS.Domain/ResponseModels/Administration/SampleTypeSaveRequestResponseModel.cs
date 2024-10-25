using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class SampleTypeSaveRequestResponseModel : APIPostResponseModel
    {
        public long IdfsSampleType { get; set; }
        //public IEnumerable<string> Errors { get; set; }
    }
}
