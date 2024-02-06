using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class MeasuresSaveRequestResponseModel : APIPostResponseModel
    {
        public long IdfsBaseReference { get; set; }
        public string StrDuplicatedField { get; set; }
    }
}
